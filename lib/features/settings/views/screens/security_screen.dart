import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool biometricEnabled = false;
  bool rememberMe = true;
  bool twoFactorAuth = false;

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
              // Security content container
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
                          'Security',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Authentication Section
                      _buildSection(
                        'Authentication',
                        [
                          _buildSwitchTile(
                            'Biometric Login',
                            'Enable fingerprint or face recognition',
                            biometricEnabled,
                            (value) => setState(() => biometricEnabled = value),
                          ),
                          _buildSwitchTile(
                            'Remember Me',
                            'Stay logged in',
                            rememberMe,
                            (value) => setState(() => rememberMe = value),
                          ),
                          _buildSwitchTile(
                            'Two-Factor Authentication',
                            'Add an extra layer of security',
                            twoFactorAuth,
                            (value) => setState(() => twoFactorAuth = value),
                          ),
                        ],
                      ),
                      const Divider(),
                      
                      // Account Actions
                      _buildSection(
                        'Account',
                        [
                          _buildActionTile(
                            'Change Password',
                            'Update your password regularly',
                            Icons.lock_outline,
                            () => _showChangePasswordDialog(),
                          ),
                          _buildActionTile(
                            'Connected Devices',
                            'Manage devices with access to your account',
                            Icons.devices_outlined,
                            () => _showConnectedDevices(),
                          ),
                          _buildActionTile(
                            'Login History',
                            'Review your account access',
                            Icons.history_outlined,
                            () => _showLoginHistory(),
                          ),
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

  Widget _buildSection(String title, List<Widget> items) {
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
        const SizedBox(height: 16),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black45,
      ),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
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
              // Implement password change logic here
              Get.back();
              Get.snackbar(
                'Success',
                'Password updated successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showConnectedDevices() {
    // Implement connected devices screen
    Get.snackbar(
      'Coming Soon',
      'Connected devices feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showLoginHistory() {
    // Implement login history screen
    Get.snackbar(
      'Coming Soon',
      'Login history feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 