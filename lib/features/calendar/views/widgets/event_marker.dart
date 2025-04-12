import 'package:flutter/material.dart';
import 'package:coded_gp/features/calendar/models/event_model.dart';

class EventMarker extends StatelessWidget {
  final List<EventModel> events;
  final List<Map<String, dynamic>> eventTypes;

  const EventMarker({
    super.key,
    required this.events,
    required this.eventTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(3).map((event) {
          final eventTypeData = eventTypes.firstWhere(
            (type) => type['label'] == event.eventType,
            orElse: () => {'label': 'Event', 'color': Colors.blue},
          );
          
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: eventTypeData['color'] as Color,
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }
} 