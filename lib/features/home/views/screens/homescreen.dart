import 'package:coded_gp/features/home/Widgets/home_app_bar.dart';
import 'package:coded_gp/features/home/Widgets/home_search_bar.dart';
import 'package:coded_gp/features/home/Widgets/services_section.dart';
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HomeAppBar(),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              HomeSearchBar(
                searchQuery: _searchQuery,
                isSearching: _isSearching,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                onClearSearch: _clearSearch,
              ),
              ServicesSection(
                services: filteredServices,
                onViewAllTap: (context) {},
              ),
              ],
          ),
        ),
      ),

    );
  }
}
