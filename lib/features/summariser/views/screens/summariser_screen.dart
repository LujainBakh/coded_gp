import 'package:flutter/material.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';
import 'package:coded_gp/features/chatbot/views/screens/chatbot_screen.dart';
import 'package:coded_gp/main_screen.dart';

class SummariserScreen extends StatelessWidget {
  const SummariserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: Row(
                  children: [
                    CustomBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/CodedLogo1.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Summariser',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a457b),
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            // For chatbot, push as a new screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChatbotScreen(),
                fullscreenDialog: true,
              ),
            );
          } else {
            // For home and calendar, replace with MainScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: index),
              ),
            );
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }
}
