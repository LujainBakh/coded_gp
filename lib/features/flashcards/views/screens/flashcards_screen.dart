import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/main_screen.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/features/flashcards/views/screens/add_flashcard_set_screen.dart';
import 'package:coded_gp/features/flashcards/views/screens/flashcard_set_details_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Map<String, dynamic>> flashcardSets = [];
  String searchQuery = '';

  Future<void> _navigateToAddSet() async {
    final result = await Get.to(() => const AddFlashcardSetScreen());

    print('Received result from AddFlashcardSetScreen:');
    print(result);

    if (result != null && result is Map<String, dynamic>) {
      print('Adding new flashcard set to list');
      print('Current sets: $flashcardSets');
      setState(() {
        flashcardSets.add(result);
      });
      print('Updated sets: $flashcardSets');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSets = flashcardSets
        .where((set) =>
            set['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg2.png'), // your ducky bg!
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                    const Spacer(),
                    const Text(
                      'Flashcards',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _navigateToAddSet,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // List of Flashcard Sets
              Expanded(
                child: filteredSets.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Duck-01.png',
                            height: 120,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Please add flashcard sets to start practicing',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextButton.icon(
                            onPressed: _navigateToAddSet,
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1a457b)),
                            label: const Text(
                              'Add Flashcard Set',
                              style: TextStyle(
                                color: Color(0xFF1a457b),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: List.generate(filteredSets.length, (index) {
                            final set = filteredSets[index];
                            final offset = index * -8.0; // shifts slightly up for stack illusion

                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: GestureDetector(
                                onTap: () async {
                                  print('Opening flashcard set:');
                                  print('Title: ${set['title']}');
                                  print('Flashcards: ${set['flashcards']}');
                                  final result = await Get.to(() => FlashcardSetDetailsScreen(
                                        initialTitle: set['title'],
                                        initialFlashcards: List<Map<String, String>>.from(set['flashcards']),
                                      ));

                                  if (result != null && result['delete'] == true) {
                                    setState(() {
                                      flashcardSets.removeAt(index);
                                    });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7E3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  width: double.infinity,
                                  height: 130,
                                  alignment: Alignment.center,
                                  child: Text(
                                    set['title'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Pacifico',
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/chatbot');
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(initialIndex: index),
              ),
            );
          }
        },
      ),
    );
  }
} 