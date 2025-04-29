import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:coded_gp/features/flashcards/views/screens/flashcard_congrats_screen.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';

class PracticeFlashcardsScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;
  final String setTitle;

  const PracticeFlashcardsScreen({
    super.key,
    required this.flashcards,
    required this.setTitle,
  });

  @override
  State<PracticeFlashcardsScreen> createState() => _PracticeFlashcardsScreenState();
}

class _PracticeFlashcardsScreenState extends State<PracticeFlashcardsScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool showAnswer = false;
  int correctCount = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _nextFlashcard(bool knewIt) {
    if (knewIt) {
      correctCount++;
    }

    if (currentIndex < widget.flashcards.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
      _controller.reset();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardCongratsScreen(
            setTitle: widget.setTitle,
            flashcards: widget.flashcards,
            correctCount: correctCount,
            totalCount: widget.flashcards.length,
          ),
        ),
      );
    }
  }

  void _showSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Practice Completed!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You knew $correctCount out of ${widget.flashcards.length} flashcards.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // DONE button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).pop(); // go back to set
                      Navigator.of(context).pop(); // go back to flashcard homepage
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBBDE4E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),

                  // RETAKE button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      setState(() {
                        currentIndex = 0;
                        correctCount = 0;
                        showAnswer = false;
                        _controller.reset();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1a457b)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(
                        color: Color(0xFF1a457b),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.flashcards[currentIndex];
    print('Current flashcard: $flashcard'); // Debug print

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
                      Center(
                        child: Text(
                          widget.setTitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomBackButton(
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _flipCard,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final angle = _controller.value * pi;
                        final isFront = angle < pi / 2;
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          alignment: Alignment.center,
                          child: isFront
                              ? _buildCard(flashcard['question'] ?? '', true)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: _buildCard(flashcard['answer'] ?? '', false),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _nextFlashcard(true),
                    icon: const Icon(Icons.check),
                    label: const Text('I knew it'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _nextFlashcard(false),
                    icon: const Icon(Icons.close),
                    label: const Text('I didn\'t know'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String text, bool isFront) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isFront ? const Color(0xFFF5E6D3) : const Color(0xFFBBDE4E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            text.trim().isNotEmpty ? text : (isFront ? "No Question" : "No Answer"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isFront ? Colors.black87 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 