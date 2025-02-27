import 'package:flutter/material.dart';

class HomeSearchBar extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final bool isSearching;

  const HomeSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(77) : Colors.black.withAlpha(7),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded( 
            child: TextField(
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                suffixIcon: widget.isSearching ?
                IconButton(
                  onPressed: widget.onClearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ) : null
              ),
              onChanged: widget.onSearchChanged,
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}