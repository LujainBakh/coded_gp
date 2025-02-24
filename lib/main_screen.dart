import 'package:flutter/material.dart';
import 'package:coded_gp/features/home/views/screens/homescreen.dart';
import 'package:coded_gp/features/chatbot/views/screens/chatbot_screen.dart';
import 'package:coded_gp/features/calendar/views/screens/calendar_screen.dart';
import 'package:coded_gp/features/profile/views/screens/profile_screen.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatbotScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : Colors.grey.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        ),
      ),
    );
  }
}
