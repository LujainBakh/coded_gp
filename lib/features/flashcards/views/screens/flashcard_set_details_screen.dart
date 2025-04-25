import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/flashcards/views/screens/practice_flashcards_screen.dart';
import 'package:coded_gp/features/flashcards/views/screens/edit_flashcard_set_screen.dart';

class FlashcardSetDetailsScreen extends StatefulWidget {
  final String initialTitle;
  final List<Map<String, String>> initialFlashcards;

  const FlashcardSetDetailsScreen({
    Key? key,
    required this.initialTitle,
    required this.initialFlashcards,
  }) : super(key: key);

  @override
  State<FlashcardSetDetailsScreen> createState() => _FlashcardSetDetailsScreenState();
}

class _FlashcardSetDetailsScreenState extends State<FlashcardSetDetailsScreen> {
  late String setTitle;
  late List<Map<String, String>> flashcards;

  @override
  void initState() {
    super.initState();
    setTitle = widget.initialTitle;
    flashcards = widget.initialFlashcards;
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Flashcard Set'),
          content: const Text('Are you sure you want to delete this flashcard set?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                Get.back(result: {'delete': true});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building FlashcardSetDetailsScreen');
    print('Title: $setTitle');
    print('Flashcards: $flashcards');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          setTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1a457b),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Get.to(() => EditFlashcardSetScreen(
                    initialTitle: setTitle,
                    initialFlashcards: flashcards,
                  ));

              if (updated != null) {
                setState(() {
                  setTitle = updated['title'];
                  flashcards = List<Map<String, String>>.from(updated['flashcards']);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Colors.white],
          ),
        ),
        child: flashcards.isEmpty
            ? const Center(
                child: Text(
                  'No flashcards added yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8E9AAF),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = flashcards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFF5F9FF)],
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          flashcard['question'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3F84),
                          ),
                        ),
                        subtitle: Text(
                          flashcard['answer'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF8E9AAF),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: flashcards.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                print('Flashcards being passed to practice: $flashcards');
                Get.to(() => PracticeFlashcardsScreen(
                  flashcards: flashcards,
                  setTitle: setTitle,
                ));
              },
              backgroundColor: const Color(0xFFBBDE4E),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Practice',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
} 