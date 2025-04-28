import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/flashcards/views/screens/flashcards_screen.dart';
import 'package:coded_gp/features/flashcards/views/screens/practice_flashcards_screen.dart';

class FlashcardCongratsScreen extends StatelessWidget {
  final String setTitle;
  final List<Map<String, String>> flashcards;
  final int correctCount;
  final int totalCount;

  const FlashcardCongratsScreen({
    super.key, 
    required this.setTitle,
    required this.flashcards,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🐤 Celebratory Duck!
                  Image.asset('assets/images/ggDuck.png', height: 180),
                  const SizedBox(height: 32),
                  const Text(
                    'Great job!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You've finished all the flashcards!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'You knew $correctCount out of $totalCount flashcards!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back to Flashcards button
                      ElevatedButton(
                        onPressed: () {
                          Get.offAll(() => const FlashcardsScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBBDE4E),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Back to Flashcards',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Retake button
                      OutlinedButton(
                        onPressed: () {
                          Get.off(() => PracticeFlashcardsScreen(
                            flashcards: flashcards,
                            setTitle: setTitle,
                          ));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(color: Color(0xFF1a457b)),
                        ),
                        child: const Text(
                          'Retake',
                          style: TextStyle(
                            color: Color(0xFF1a457b),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 