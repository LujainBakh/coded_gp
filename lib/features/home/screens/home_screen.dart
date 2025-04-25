import 'package:flutter/material.dart';
import 'package:coded_gp/features/home/widgets/feature_button.dart';
import 'package:coded_gp/features/flashcards/views/screens/flashcards_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/coded_bg3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      FeatureButton(
                        icon: Icons.timer,
                        label: 'Timer',
                        onTap: () {
                          // TODO: Navigate to Timer screen
                        },
                      ),
                      FeatureButton(
                        icon: Icons.style, // or Icons.card_membership
                        label: 'Flashcards',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FlashcardsScreen(),
                            ),
                          );
                        },
                      ),
                      FeatureButton(
                        icon: Icons.quiz,
                        label: 'Quiz',
                        onTap: () {
                          // TODO: Navigate to Quiz screen
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 