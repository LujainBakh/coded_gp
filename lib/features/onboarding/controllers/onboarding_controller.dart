import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/onboarding/models/onboarding_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coded_gp/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find();

  final pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingItem> items = [
    const OnboardingItem(
      title: 'Discover Knowledge with Ease',
      description:
          'Find answers to your questions and the resources you need instantly.',
      image: 'assets/images/onboarding/boarding1.png',
    ),
    const OnboardingItem(
      title: 'Stay Connected Anywhere',
      description:
          'Get support for your studies no matter where you are, even on the go.',
      image: 'assets/images/onboarding/boarding2.png',
    ),
    const OnboardingItem(
      title: 'Empower Your Learning Journey',
      description:
          'Explore tools and insights tailored to your academic and personal growth.',
      image: 'assets/images/onboarding/boarding3.png',
    ),
  ];

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    Get.offAllNamed(AppRoutes.signin);
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
