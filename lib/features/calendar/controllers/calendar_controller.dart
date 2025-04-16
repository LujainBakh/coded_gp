import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../../../core/services/notification_service.dart';

class CalendarController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  
  final selectedDate = DateTime.now().obs;
  final events = <String, List<EventModel>>{}.obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedEventTypes = RxList<String>([]);

  @override
  void onInit() {
    super.onInit();
    _notificationService.initialize();
    fetchEvents();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  // Fetch all events from Firestore
  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      
      // Check authentication
      final user = _auth.currentUser;
      if (user == null) {
        print('Error: User not authenticated');
        Get.snackbar('Error', 'Please sign in to view events');
        return;
      }

      print('Debug: Current user ID: ${user.uid}');
      print('Debug: Current user email: ${user.email}');
      
      print('Debug: Starting to fetch events from Firestore...');
      
      // Fetch admin events
      final adminSnapshot = await _firestore
          .collection('Events_DB')
          .where('type', isEqualTo: 'Admin')
          .get();
      
      print('Debug: Found ${adminSnapshot.docs.length} admin events');
      
      // Fetch user's personal events
      final userSnapshot = await _firestore
          .collection('Events_DB')
          .where('ownerId', isEqualTo: user.uid)
          .get();
      
      print('Debug: Found ${userSnapshot.docs.length} user events');
      
      final newEvents = <String, List<EventModel>>{};
      
      // Process admin events
      for (var doc in adminSnapshot.docs) {
        try {
          print('Debug: Processing admin document ID: ${doc.id}');
          final event = EventModel.fromFirestore(doc);
          final date = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          ).toString();
          
          if (newEvents[date] != null) {
            newEvents[date]!.add(event);
          } else {
            newEvents[date] = [event];
          }
        } catch (docError) {
          print('Error processing admin document ${doc.id}: $docError');
          continue;
        }
      }
      
      // Process user events
      for (var doc in userSnapshot.docs) {
        try {
          print('Debug: Processing user document ID: ${doc.id}');
          final event = EventModel.fromFirestore(doc);
          final date = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          ).toString();
          
          if (newEvents[date] != null) {
            newEvents[date]!.add(event);
          } else {
            newEvents[date] = [event];
          }
        } catch (docError) {
          print('Error processing user document ${doc.id}: $docError');
          continue;
        }
      }
      
      events.value = newEvents;
      print('Debug: Final events map contains ${events.length} dates');
      print('Debug: Total events: ${events.values.fold(0, (sum, list) => sum + list.length)}');
      
    } catch (e) {
      print('Error fetching events: $e');
      print('Debug: Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Failed to load events. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new event to Firestore
  Future<void> addEvent(EventModel event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      isLoading.value = true;
      
      // Set event type and owner
      final eventWithOwner = EventModel(
        id: '',  // Empty ID for new event
        title: event.title,
        subtitle: event.subtitle,
        startTime: event.startTime,
        endTime: event.endTime,
        type: 'User',
        eventType: event.eventType,
        ownerId: user.uid,
        location: event.location,
        note: event.note,
        remindMe: event.remindMe,
      );

      // Add to Firestore and get the document reference
      final docRef = await _firestore.collection('Events_DB').add(eventWithOwner.toFirestore());
      
      // Schedule notification if remindMe is true
      if (eventWithOwner.remindMe) {
        await _notificationService.scheduleEventNotification(
          id: docRef.id.hashCode,
          title: 'Upcoming Event: ${eventWithOwner.title}',
          body: 'Event starts at ${eventWithOwner.startTime.toString()}',
          scheduledTime: eventWithOwner.startTime.subtract(const Duration(minutes: 30)),
          payload: docRef.id,
        );
      }

      await fetchEvents();
      Get.snackbar('Success', 'Event added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing event in Firestore
  Future<void> updateEvent(EventModel event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Check if user owns the event or if it's an admin event
      if (event.ownerId != user.uid && event.type != 'Admin') {
        Get.snackbar('Error', 'You do not have permission to update this event');
        return;
      }

      isLoading.value = true;
      
      await _firestore.collection('Events_DB').doc(event.id).update(event.toFirestore());
      
      // Cancel existing notification and schedule new one if remindMe is true
      await _notificationService.cancelNotification(event.id.hashCode);
      if (event.remindMe) {
        await _notificationService.scheduleEventNotification(
          id: event.id.hashCode,
          title: 'Upcoming Event: ${event.title}',
          body: 'Event starts at ${event.startTime.toString()}',
          scheduledTime: event.startTime.subtract(const Duration(minutes: 30)),
          payload: event.id,
        );
      }

      await fetchEvents();
      Get.snackbar('Success', 'Event updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an event from Firestore
  Future<void> deleteEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Get event to check ownership
      final eventDoc = await _firestore.collection('Events_DB').doc(eventId).get();
      if (!eventDoc.exists) {
        Get.snackbar('Error', 'Event not found');
        return;
      }

      final event = EventModel.fromFirestore(eventDoc);
      if (event.ownerId != user.uid && event.type != 'Admin') {
        Get.snackbar('Error', 'You do not have permission to delete this event');
        return;
      }

      isLoading.value = true;
      
      await _firestore.collection('Events_DB').doc(eventId).delete();
      
      // Cancel notification if it exists
      await _notificationService.cancelNotification(eventId.hashCode);

      await fetchEvents();
      Get.snackbar('Success', 'Event deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get filtered events for the entire year
  List<EventModel> getFilteredEvents() {
    final allEvents = events.values.expand((list) => list).toList();
    
    return allEvents.where((event) {
      // Search query filter
      final matchesSearch = searchQuery.value.isEmpty ||
          event.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (event.subtitle?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      
      // Event type filter - show only events of the selected type
      final matchesType = selectedEventTypes.isEmpty || 
          selectedEventTypes.contains(event.eventType);
      
      return matchesSearch && matchesType;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get filtered events for a specific day (used by calendar)
  List<EventModel> getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day).toString();
    final dayEvents = events[date] ?? [];
    
    // Apply the same filtering logic as getFilteredEvents
    return dayEvents.where((event) {
      // Search query filter
      final matchesSearch = searchQuery.value.isEmpty ||
          event.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (event.subtitle?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      
      // Event type filter - show only events of the selected type
      final matchesType = selectedEventTypes.isEmpty || 
          selectedEventTypes.contains(event.eventType);
      
      return matchesSearch && matchesType;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get upcoming events (used by home screen)
  List<EventModel> getUpcomingEvents() {
    final now = DateTime.now();
    return getFilteredEvents().where((event) => 
      event.startTime.isAfter(now.subtract(const Duration(days: 1)))
    ).toList();
  }

  // Get all events across all days
  List<EventModel> getAllEvents() {
    return getFilteredEvents();
  }

  // Toggle event type filter
  void toggleEventType(String eventType) {
    print('Toggling event type: $eventType');
    print('Before toggle - Selected types: ${selectedEventTypes.toString()}');
    
    if (selectedEventTypes.contains(eventType)) {
      selectedEventTypes.remove(eventType);
    } else {
      selectedEventTypes.clear();
      selectedEventTypes.add(eventType);
    }
    
    print('After toggle - Selected types: ${selectedEventTypes.toString()}');
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
}
