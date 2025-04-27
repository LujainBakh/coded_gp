import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the current user's ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Get the flashcard sets collection reference
  CollectionReference get _flashcardSetsRef => 
      _firestore.collection('Users_DB').doc(_userId).collection('FlashcardSets');

  // Get all flashcard sets
  Future<List<Map<String, dynamic>>> getFlashcardSets() async {
    try {
      final snapshot = await _flashcardSetsRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'],
          'flashcards': data['flashcards'],
        };
      }).toList();
    } catch (e) {
      print('Error getting flashcard sets: $e');
      return [];
    }
  }

  // Add a new flashcard set
  Future<void> addFlashcardSet(String title, List<Map<String, String>> flashcards) async {
    try {
      await _flashcardSetsRef.add({
        'title': title,
        'flashcards': flashcards,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding flashcard set: $e');
      rethrow;
    }
  }

  // Update a flashcard set
  Future<void> updateFlashcardSet(
    String setId,
    String title,
    List<Map<String, String>> flashcards,
  ) async {
    try {
      await _flashcardSetsRef.doc(setId).update({
        'title': title,
        'flashcards': flashcards,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating flashcard set: $e');
      rethrow;
    }
  }

  // Delete a flashcard set
  Future<void> deleteFlashcardSet(String setId) async {
    try {
      await _flashcardSetsRef.doc(setId).delete();
    } catch (e) {
      print('Error deleting flashcard set: $e');
      rethrow;
    }
  }
} 