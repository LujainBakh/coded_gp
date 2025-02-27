import 'package:coded_gp/features/home/Widgets/home_app_bar.dart';
import 'package:coded_gp/features/home/Widgets/home_search_bar.dart';
import 'package:coded_gp/features/home/Widgets/services_section.dart';
import 'package:coded_gp/features/home/Widgets/ads_carousel.dart';
import 'package:coded_gp/features/home/Widgets/events_section.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
State<HomeScreen > createState() => _HomeScreenState();  
}

class _HomeScreenState extends State<HomeScreen> {
String _searchQuery = '';
bool get  _isSearching => _searchQuery.isNotEmpty;
final List<Map<String, dynamic>> services = [
  {
    'icon': Icons.calculate,
    'color': Colors.deepPurple,
    'title': 'Calculator'
  },
  {
    'icon': Icons.file_copy,
    'color': Colors.pink,
    'title': 'Documents'
  },
  {
    'icon': Icons.summarize,
    'color': Colors.blue,
    'title': 'Summary'
  },
  {
    'icon': Icons.timer,
    'color': Colors.green,
    'title': 'Schedule'
  },
  {
    'icon': Icons.question_answer,
    'color': Colors.orange,
    'title': 'Q&A'
  },
  {
    'icon': Icons.card_giftcard,
    'color': Colors.purple,
    'title': 'Rewards'
  },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HomeAppBar(),
      drawer: const Drawer(),
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
                  onViewAllTap: (context) {},
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
