import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'User' or 'Admin'
  final String eventType; // 'Event', 'Meeting', 'Task', etc.
  final String ownerId; // User's UID
  final String? location;
  final String? note;
  final bool remindMe;

  // Static map for event type colors
  static const Map<String, Color> eventTypeColors = {
    'Holiday': Colors.purple,
    'Quiz': Colors.green,
    'Event': Colors.blue,
    'Meeting': Colors.orange,
    'Task': Colors.red,
  };

  EventModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.eventType,
    required this.ownerId,
    this.location,
    this.note,
    this.remindMe = false,
  });

  // Get color for event type
  Color get color => eventTypeColors[eventType] ?? Colors.blue;

  // Get all available event types
  static List<String> get availableEventTypes => eventTypeColors.keys.toList();

  // Convert Firestore document to EventModel
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? data['Title'] ?? '',
      subtitle: data['subtitle'] ?? data['SubTitle'] ?? '',
      startTime: ((data['startTime'] ?? data['StartTime']) as Timestamp).toDate(),
      endTime: ((data['endTime'] ?? data['EndTime']) as Timestamp).toDate(),
      type: data['type'] ?? data['Type'] ?? 'User',
      eventType: data['eventType'] ?? data['EventType'] ?? 'Event',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? data['Location'],
      note: data['note'] ?? data['Note'],
      remindMe: data['remindMe'] ?? data['RemindMe'] ?? false,
    );
  }

  // Convert EventModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type,
      'eventType': eventType,
      'ownerId': ownerId,
      'location': location,
      'note': note,
      'remindMe': remindMe,
    };
  }
} 