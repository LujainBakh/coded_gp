import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
              // Privacy Policy content container
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
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        '1. Types data we collect',
                        'We collect the following types of information to provide you with the best academic experience:',
                        [
                          'Personal Information: Name, student ID, email address, and university login credentials.',
                          'Academic Data: GPA, course schedules, assignment deadlines, and transcripts (if uploaded).',
                          'Usage Data: Interaction patterns with the app to enhance user experience and recommend features.',
                        ],
                      ),
                      _buildSection(
                        '2. Use of your personal data',
                        'Your personal data is used for:',
                        [
                          'Organizing and managing your academic schedule effectively.',
                          'Providing personalized reminders and notifications.',
                          'Enabling the chatbot to offer accurate and tailored responses to your queries.',
                          'Improving CODED\'s features and performance through user feedback.',
                        ],
                      ),
                      _buildSection(
                        '3. Disclosure of your personal data',
                        'We do not share your data with third parties unless:',
                        [
                          'Required by law or university regulations.',
                          'Necessary for technical support (with limited and secure access).',
                          'Approved explicitly by you for sharing with academic staff or advisors.',
                        ],
                      ),
                      _buildSection(
                        '3. Contact Us',
                        'If you have questions about our privacy policy, contact us at:',
                        [
                          'Email: support@coded.com',
                          'Phone: +966 456 7890',
                        ],
                      ),
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

  Widget _buildSection(String title, String subtitle, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
} 