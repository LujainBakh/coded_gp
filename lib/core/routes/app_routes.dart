import 'package:get/get.dart';
import 'package:coded_gp/features/onboarding/screens/on_boarding_screen.dart';
import 'package:coded_gp/features/auth/views/screens/sign_in_screen.dart';
import 'package:coded_gp/features/splash/screens/splash_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signin = '/signin';
  static const String splash = '/splash';

  static final routes = [
    GetPage(name: onboarding, page: () => const OnBoardingScreen()),
    GetPage(name: signin, page: () => const SignInScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
  ];
}
