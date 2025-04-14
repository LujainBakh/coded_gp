import 'package:flutter/material.dart';
import 'package:coded_gp/features/home/views/screens/homescreen.dart';
import 'package:coded_gp/features/chatbot/views/screens/chatbot_screen.dart';
import 'package:coded_gp/features/calendar/views/screens/calendar_screen.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  bool _isChatbotVisible = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
            ).then((_) {
              // When returning from chatbot, ensure we're on the previous screen
              setState(() {
                _currentIndex = _currentIndex == 1 ? 0 : _currentIndex;
              });
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        isVisible: true,
      ),
    );
  }
}
