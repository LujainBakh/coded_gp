import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/onboarding/controllers/onboarding_controller.dart';
import 'package:coded_gp/features/onboarding/models/onboarding_item.dart';
import 'package:coded_gp/core/config/theme/app_colors.dart';

class OnBoardingScreen extends GetView<OnboardingController> {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: Stack(
        children: [
          PageView.builder(
              controller: controller.pageController,
              itemCount: controller.items.length,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (context, index) {
                return _buildPage(context, controller.items[index]);
              }), // PageView.builder
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.items.length,
                    (index) => Obx(
                      () => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: controller.currentPage.value == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppColors.kPrimaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ), // BoxDecoration
                      ),
                    ), // AnimatedContainer // Obx
                  ), // List.generate
                ), // Row

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => controller.currentPage.value != 0
                            ? TextButton(
                                onPressed: controller.previousPage,
                                child: const Text('Previous'),
                              ) // TextButton
                            : const SizedBox(width: 80),
                      ), // Obx

                      Obx(() {
                        final isLastPage = controller.currentPage.value ==
                            controller.items.length - 1;
                        return ElevatedButton(
                          onPressed: isLastPage
                              ? controller.finishOnboarding
                              : controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimaryColor,
                            minimumSize: const Size(120, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ), // Rounded RectangleBorder
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                            ), //TextStyle
                          ), //Text
                        ); //ElevatedButton
                      }), //Obx
                    ],
                  ),
                ), //Padding
              ],
            ), // Column
          ), // Positioned
        ],
      ), // Stack
    ); // Scaffold
  }
}

Widget _buildPage(BuildContext context, OnboardingItem item) {
  return Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(item.image, height: 300),
        const SizedBox(height: 40),
        Text(
          item.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          item.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : AppColors.kTextLightColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    ),
  );
}
