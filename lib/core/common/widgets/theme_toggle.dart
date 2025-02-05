import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/controllers/theme_controllers.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = ThemeController.to;
      return PopupMenuButton<ThemeMode>(
        initialValue: controller.themeMode,
        onSelected: controller.setThemeMode,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: ThemeMode.system,
            child: Text('System Theme'),
          ),
          const PopupMenuItem(
            value: ThemeMode.light,
            child: Text('Light Theme'),
          ),
          const PopupMenuItem(
            value: ThemeMode.dark,
            child: Text('Dark Theme'),
          ),
        ],
        child: ListTile(
          leading: Icon(
            controller.isDarkMode
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
          ),
          title: const Text('Theme'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      );
    });
  }
}
