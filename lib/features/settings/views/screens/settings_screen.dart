import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coded_gp/core/routes/app_routes.dart';
import 'package:coded_gp/features/settings/views/screens/notifications_screen.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/duck1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              // Back button and logo container
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: Row(
                  children: [
                    const CustomBackButton(),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/CodedLogo1.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Settings title and content container
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    _buildSection(
                      'Account',
                      [
                        _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
                        _buildMenuItem(Icons.lock_outline, 'Privacy'),
                      ],
                    ),
                    _buildSection(
                      'Support & About',
                      [
                        _buildMenuItem(Icons.help_outline, 'Help & Support'),
                        _buildMenuItem(Icons.description_outlined, 'Terms and Policies'),
                        _buildMenuItem(Icons.info_outline, 'About Us'),
                      ],
                    ),
                    _buildSection(
                      'Actions',
                      [
                        _buildMenuItem(Icons.flag_outlined, 'Report a problem'),
                        _buildMenuItem(Icons.logout, 'Log out'),
                      ],
                    ),
                    _buildSection(
                      'Resources',
                      [
                        _buildMenuItem(Icons.language, 'IAU Website'),
                        _buildMenuItem(Icons.school_outlined, 'SIS'),
                        _buildMenuItem(Icons.computer, 'E-library'),
                        _buildMenuItem(Icons.menu_book_outlined, 'Blackboard'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          } else if (index == 1) {
            Get.toNamed('/chatbot');
          } else if (index == 2) {
            Get.offAllNamed('/calendar');
          }
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black45,
      ),
      onTap: () {
        switch (title) {
          case 'Notifications':
            Get.toNamed(AppRoutes.notifications);
            break;
          case 'Privacy':
            Get.toNamed(AppRoutes.privacy);
            break;
          case 'Help & Support':
            Get.toNamed(AppRoutes.helpSupport);
            break;
          case 'About Us':
            Get.toNamed(AppRoutes.about);
            break;
          case 'Terms and Policies':
            Get.toNamed(AppRoutes.termsPolicies);
            break;
          case 'Report a problem':
            _showReportDialog();
            break;
          case 'Log out':
            _logoutWithoutContext();
            break;
          // Resources section
          case 'IAU Website':
            _launchURL('https://www.iau.edu.sa/');
            break;
          case 'SIS':
            _launchURL('https://sis.iau.edu.sa/');
            break;
          case 'E-library':
            _launchURL('https://library.iau.edu.sa/');
            break;
          case 'Blackboard':
            _launchURL('https://vle.iau.edu.sa');
            break;
        }
      },
    );
  }

  // Helper methods for different actions
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add your logout logic here
              FirebaseAuth.instance.signOut().then((_) {
                Get.offAllNamed('/signin');
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report a Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe the problem...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add your report submission logic here
              Get.back();
              Get.snackbar(
                'Success',
                'Your report has been submitted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch $url',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _logoutWithoutContext() {
    // Implementation of logoutWithoutContext method
  }
}
