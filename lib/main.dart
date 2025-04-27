import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/controllers/theme_controllers.dart';
import 'package:coded_gp/features/onboarding/controllers/onboarding_controller.dart';
import 'package:coded_gp/features/splash/controllers/splash_controllers.dart';
import 'package:coded_gp/core/config/theme/app_theme.dart';
import 'package:coded_gp/core/routes/app_routes.dart';
import 'package:coded_gp/features/settings/controllers/notifications_controller.dart';
import 'package:coded_gp/features/calendar/controllers/calendar_controller.dart';
import 'package:coded_gp/features/timer/controllers/timer_controller.dart';
import 'package:coded_gp/features/flashcards/controllers/flashcards_controller.dart';
// Import other necessary controllers and utilities

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Get.putAsync(() async => ThemeController());
  Get.put(OnboardingController());
  Get.put(SplashController());
  Get.put(NotificationsController());
  Get.put(CalendarController());
  Get.put(TimerController());
  Get.put(FlashcardsController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Coded GP',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController.to.themeMode,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
