import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class TermsPoliciesScreen extends StatelessWidget {
  const TermsPoliciesScreen({super.key});

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
              // Terms and Policies content container
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
                          'Terms and Policies',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSection(
                        'Terms of Use',
                        'By using CODED, you agree to the following terms:',
                        [
                          'The app is intended for IAU students and staff.',
                          'Users must maintain the confidentiality of their account credentials.',
                          'Users are responsible for all activities under their account.',
                          'The app should be used for academic purposes only.',
                          'Users must not misuse or attempt to gain unauthorized access to the system.',
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSection(
                        'Data Usage',
                        'How we handle your data:',
                        [
                          'We collect only necessary academic and user data.',
                          'Your data is stored securely and encrypted.',
                          'We do not share your information with third parties.',
                          'Data is used to provide and improve our services.',
                          'You can request your data deletion at any time.',
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSection(
                        'User Guidelines',
                        'Please follow these guidelines:',
                        [
                          'Respect other users and university policies.',
                          'Do not share inappropriate or harmful content.',
                          'Report any technical issues or violations.',
                          'Keep your app updated for the best experience.',
                          'Use the chatbot responsibly and ethically.',
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildSection(
                        'Updates and Changes',
                        'Policy updates:',
                        [
                          'We may update these terms periodically.',
                          'Users will be notified of significant changes.',
                          'Continued use implies acceptance of new terms.',
                          'Check this section regularly for updates.',
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
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
        )).toList(),
      ],
    );
  }
} 