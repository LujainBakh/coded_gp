import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              // Back button and logo container
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                      alignment: Alignment.centerLeft,
                    ),
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
              // FAQ content container
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Frequently Asked Questions:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildExpandableFAQ(
                        'Can CODED help me plan my study schedule?',
                        'Yes! CODED offers a smart scheduling system that helps you:\n'
                        '• Create personalized study timetables\n'
                        '• Set reminders for assignments and exams\n'
                        '• Balance your study time across different courses\n'
                        '• Adapt your schedule based on your learning preferences',
                        Colors.lightGreen.shade100,
                      ),
                      
                      _buildExpandableFAQ(
                        'How does CODED differ from Blackboard or SIS?',
                        'CODED complements Blackboard and SIS by providing:\n'
                        '• AI-powered study assistance and instant answers\n'
                        '• Smart calendar integration for better time management\n'
                        '• Personalized notifications for important deadlines\n'
                        '• Easy access to all university resources in one place\n'
                        '• User-friendly interface designed specifically for IAU students',
                        Colors.lightGreen.shade100,
                      ),
                      
                      _buildExpandableFAQ(
                        'Questions related to support:',
                        'Here\'s how you can get help:\n'
                        '• Email support: support@coded.com\n'
                        '• Phone support: +966 456 7890\n'
                        '• Report issues through the app\'s "Report a Problem" feature\n'
                        '• Check our help documentation in the Help & Support section',
                        Colors.lightGreen.shade100,
                      ),
                      
                      _buildExpandableFAQ(
                        'Questions related to this app:',
                        'Common app-related information:\n'
                        '• Updates are automatic through your app store\n'
                        '• Requires iOS 13+ or Android 8+\n'
                        '• Manage notifications in the Settings menu\n'
                        '• Basic features work offline, but chatbot requires internet\n'
                        '• Data is securely stored and backed up regularly',
                        Colors.lightGreen.shade100,
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
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

  Widget _buildExpandableFAQ(String title, String content, Color backgroundColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

} 