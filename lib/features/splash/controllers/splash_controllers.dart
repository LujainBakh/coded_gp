import 'package:get/get.dart';
import 'package:coded_gp/core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  static SplashController get to => Get.find();

  Future<String> determineInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      if (isFirstTime) {
        return AppRoutes.onboarding;
      } else {
        return AppRoutes.signin;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: determining initial route $e');
      return AppRoutes.signin;
    }
  }
}
