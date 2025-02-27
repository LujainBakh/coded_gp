import 'package:flutter/material.dart';
import 'package:coded_gp/core/config/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool isVisible;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? AppColors.kBackgroundDarkColor : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 0,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              const SizedBox(width: 1),
              _buildNavItem(Icons.calendar_today_outlined, 'Calendar', 2),
            ],
          ),
        ),
        Positioned(
          top: -30,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              height: 65,
              width: 65,
              child: FloatingActionButton(
                elevation: 2,
                backgroundColor: AppColors.kSecondaryColor,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () => onTap(1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: currentIndex == index
                ? AppColors.kSecondaryColor
                : Colors.grey[400],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index
                  ? AppColors.kSecondaryColor
                  : Colors.grey[400],
              fontSize: 13,
              fontWeight:
                  currentIndex == index ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
