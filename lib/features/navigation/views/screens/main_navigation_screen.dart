import 'package:coded_gp/features/calendar/views/screens/calendar_screen.dart';
import 'package:coded_gp/features/home/views/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:coded_gp/features/chatbot/views/screens/chatbot_screen.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatbotScreen(),
    const CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // For chatbot, push as a new screen instead of switching index
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChatbotScreen(),
                fullscreenDialog: true,
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        isVisible: true,
      ),
    );
  }
} 