import 'package:coded_gp/features/home/Widgets/home_app_bar.dart';
import 'package:coded_gp/features/home/Widgets/home_search_bar.dart';
import 'package:coded_gp/features/home/Widgets/services_section.dart';
import 'package:coded_gp/features/home/Widgets/ads_carousel.dart';
import 'package:coded_gp/features/home/Widgets/events_section.dart';
import 'package:flutter/material.dart';
import 'package:coded_gp/features/home/Widgets/home_drawer.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/routes/app_routes.dart';
import 'package:coded_gp/features/flashcards/views/screens/flashcards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool get _isSearching => _searchQuery.isNotEmpty;
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.calculate,
      'color': Colors.deepPurple,
      'title': 'GPA Calculator',
      'route': AppRoutes.gpaCalculator,
    },
    {
      'icon': Icons.file_copy,
      'color': Colors.pink,
      'title': 'File Manager',
      'route': AppRoutes.fileManager,
    },
    {
      'icon': Icons.summarize,
      'color': Colors.blue,
      'title': 'Summary',
      'route': AppRoutes.summariser
    },
    {
      'icon': Icons.timer,
      'color': Colors.green,
      'title': 'Timer',
      'route': AppRoutes.timer,
    },
    {
      'icon': Icons.style, 
      'color': Colors.orange, 
      'title': 'Flashcards',
      'isFlashcards': true,  // Special flag for Flashcards
    },
    {'icon': Icons.quiz, 'color': Colors.purple, 'title': 'Quiz'},
  ]; // or populate with your actual services

  List<Map<String, dynamic>> get filteredServices => services
      .where((service) => service['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
      .toList();

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  void _handleServiceTap(Map<String, dynamic> service) {
    if (service['isFlashcards'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FlashcardsScreen(),
        ),
      );
    } else if (service['route'] != null) {
      Navigator.pushNamed(context, service['route']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomeAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const HomeDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg2.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeSearchBar(
                  searchQuery: _searchQuery,
                  isSearching: _isSearching,
                  onSearchChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  onClearSearch: _clearSearch,
                ),
                const SizedBox(height: 8),
                Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 0),
                ServicesSection(
                  services: filteredServices,
                  onServiceTap: _handleServiceTap,
                ),
                Row(
                  children: [
                    Text(
                      'News',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Handle view all news
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const AdsCarousel(),
                const SizedBox(height: 16),
                const EventsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
