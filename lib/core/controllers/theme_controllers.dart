import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  final _themeMode = ThemeMode.system.obs;
  final _prefs = SharedPreferences.getInstance();

  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await _prefs;
    final savedThemeMode = prefs.getString('themeMode');
    if (savedThemeMode != null) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.name == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    final prefs = await _prefs;
    await prefs.setString('themeMode', mode.toString());
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode == ThemeMode.dark;
  }
}
