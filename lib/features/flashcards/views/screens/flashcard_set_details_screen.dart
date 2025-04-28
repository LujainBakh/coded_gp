import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/flashcards/views/screens/practice_flashcards_screen.dart';
import 'package:coded_gp/features/flashcards/views/screens/edit_flashcard_set_screen.dart';
import 'package:coded_gp/features/flashcards/controllers/flashcards_controller.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';

class FlashcardSetDetailsScreen extends StatefulWidget {
  final String setId;
  final String initialTitle;
  final List<Map<String, String>> initialFlashcards;

  const FlashcardSetDetailsScreen({
    Key? key,
    required this.setId,
    required this.initialTitle,
    required this.initialFlashcards,
  }) : super(key: key);

  @override
  State<FlashcardSetDetailsScreen> createState() => _FlashcardSetDetailsScreenState();
}

class _FlashcardSetDetailsScreenState extends State<FlashcardSetDetailsScreen> {
  late String setTitle;
  late List<Map<String, String>> flashcards;
  final FlashcardsController _flashcardsController = Get.find<FlashcardsController>();

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
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _flashcardsController.deleteFlashcardSet(widget.setId);
                  Get.back(result: {'delete': true});
                } catch (e) {
                  Get.snackbar('Error', 'Failed to delete flashcard set');
                }
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/vibrantskybg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered Title
                      Center(
                        child: Text(
                          setTitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Back button (left)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomBackButton(
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Edit and Delete (right)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () async {
                                final updated = await Get.to(() => EditFlashcardSetScreen(
                                      setId: widget.setId,
                                      initialTitle: setTitle,
                                      initialFlashcards: flashcards,
                                    ));

                                if (updated != null) {
                                  try {
                                    await _flashcardsController.updateFlashcardSet(
                                      widget.setId,
                                      updated['title'],
                                      List<Map<String, String>>.from(updated['flashcards']),
                                    );
                                    setState(() {
                                      setTitle = updated['title'];
                                      flashcards = List<Map<String, String>>.from(updated['flashcards']);
                                    });
                                  } catch (e) {
                                    Get.snackbar('Error', 'Failed to update flashcard set');
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              onPressed: _showDeleteConfirmationDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
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
              if (flashcards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32, top: 8),
                  child: Center(
                    child: SizedBox(
                      width: 280,
                      height: 56,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          print('Flashcards being passed to practice: $flashcards');
                          Get.to(() => PracticeFlashcardsScreen(
                            flashcards: flashcards,
                            setTitle: setTitle,
                          ));
                        },
                        backgroundColor: const Color(0xFFBBDE4E),
                        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                        label: const Text(
                          'Practice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 