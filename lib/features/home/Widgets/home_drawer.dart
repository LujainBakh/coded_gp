import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/config/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coded_gp/core/routes/app_routes.dart';

// Add this global key at the top of the file
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomeDrawer extends StatelessWidget {
  final Color? primaryAccentColor;
  final Color? secondaryAccentColor;

  const HomeDrawer({
    super.key,
    this.primaryAccentColor,
    this.secondaryAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use app theme colors by default
    final primaryColor = primaryAccentColor ?? AppColors.kPrimaryColor;
    final secondaryColor = secondaryAccentColor ?? AppColors.kSecondaryColor;

    return Column(
      children: [
        SizedBox(
            height:
                screenHeight * 0.1), // Add space at the top to push drawer down
        Container(
          width: screenWidth * 0.75,
          height: screenHeight * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean header with just the duck
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Image.asset(
                      'assets/images/duck-walking.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Menu items with improved spacing
              const SizedBox(height: 16),

              _buildMenuItem(
                context: context,
                icon: Icons.question_mark_rounded,
                title: 'FAQs',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to FAQs
                  Get.toNamed('/faqs');
                },
                iconColor: primaryColor,
                textColor: primaryColor,
              ),

              _buildMenuItem(
                context: context,
                icon: Icons.share_rounded,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  // Handle share functionality
                  _shareApp();
                },
                iconColor: primaryColor,
                textColor: primaryColor,
              ),

              _buildMenuItem(
                context: context,
                icon: Icons.settings_rounded,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                  Get.toNamed('/settings');
                },
                iconColor: primaryColor,
                textColor: primaryColor,
              ),

              _buildMenuItem(
                context: context,
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () {
                  Navigator.pop(context);
                  // Handle logout
                  _showLogoutConfirmation(context);
                },
                iconColor: primaryColor,
                textColor: primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.kPrimaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.kPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  void _shareApp() {
    // You can use a package like share_plus to implement sharing
    // For example: Share.share('Check out this awesome app: https://yourapplink.com');
    Get.snackbar(
      'Share',
      'Sharing functionality will be implemented here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the confirmation dialog first
                Navigator.of(dialogContext).pop();

                // Use a completely different approach
                _logoutWithoutContext();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Logout without using any context
  void _logoutWithoutContext() {
    // Sign out from Firebase
    FirebaseAuth.instance.signOut().then((_) {
      // Use GetX navigation which doesn't require context
      Get.offAllNamed(AppRoutes.signin);
    }).catchError((error) {
      print("Error during logout: $error");
      Get.snackbar(
        'Logout Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    });
  }
}
