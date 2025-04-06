import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  final String id;
  final String name;
  final String path;
  final String iconUrl;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.path,
    required this.iconUrl,
    required this.createdAt,
  });

  factory Folder.fromMap(String id, Map<String, dynamic> map) {
    // Handle different types of createdAt field
    DateTime parseCreatedAt(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateFormat("MMMM d, y 'at' h:mm:ss a 'UTC'Z").parse(value);
        } catch (e) {
          print('Error parsing date: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Folder(
      id: id,
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      createdAt: parseCreatedAt(map['createdAt']),
    );
  }
}
