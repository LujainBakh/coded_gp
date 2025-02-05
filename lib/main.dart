import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:coded_gp/core/common/utils/text_scale_wrapper.dart';
import 'package:coded_gp/core/controllers/theme_controllers.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/config/theme/app_theme.dart';
import 'package:coded_gp/core/routes/app_routes.dart';
import 'package:coded_gp/features/splash/controllers/splash_controllers.dart';
import 'package:coded_gp/features/onboarding/controllers/onboarding_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Get.putAsync(() async => ThemeController());
  Get.put(OnboardingController());
  Get.put(SplashController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return TextScaleWrapper(
      child: GetMaterialApp(
        title: 'Coded GP',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeController.to.themeMode,
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
      ),
    );
  }
}
