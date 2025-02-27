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

  @override
  Widget build(BuildContext context) {
    // Get the current route name
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            // Navigate to ChatbotScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatbotScreen(),
                settings: const RouteSettings(name: '/chatbot'), // Add route name
              ),
            );
          }
        },
        // Hide bottom nav bar when in ChatbotScreen
        isVisible: currentRoute != '/chatbot',
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 2:
        return const CalendarScreen();
      default:
        return const HomeScreen();
    }
  }
} 