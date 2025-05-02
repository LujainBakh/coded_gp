import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/features/settings/controllers/notifications_controller.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

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
                    CustomBackButton(
                      onPressed: () => Navigator.of(context).pop(),
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
              // Notifications content container
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
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Common',
                        [
                          Obx(() => _buildSwitchTile(
                                'General Notification',
                                controller.generalNotification,
                                (value) => controller.updateSetting(
                                    'generalNotification', value),
                              )),
                          Obx(() => _buildSwitchTile(
                                'Sound',
                                controller.sound,
                                (value) =>
                                    controller.updateSetting('sound', value),
                              )),
                          Obx(() => _buildSwitchTile(
                                'Vibrate',
                                controller.vibrate,
                                (value) =>
                                    controller.updateSetting('vibrate', value),
                              )),
                        ],
                      ),
                      const Divider(),
                      _buildSection(
                        'System & services update',
                        [
                          Obx(() => _buildSwitchTile(
                                'App Updates',
                                controller.appUpdates,
                                (value) => controller.updateSetting(
                                    'appUpdates', value),
                              )),
                          Obx(() => _buildSwitchTile(
                                'Assignment Reminder',
                                controller.assignmentReminder,
                                (value) => controller.updateSetting(
                                    'assignmentReminder', value),
                              )),
                          Obx(() => _buildSwitchTile(
                                'Exam Notification',
                                controller.examNotification,
                                (value) => controller.updateSetting(
                                    'examNotification', value),
                              )),
                          Obx(() => _buildSwitchTile(
                                'Registration Reminder',
                                controller.registrationReminder,
                                (value) => controller.updateSetting(
                                    'registrationReminder', value),
                              )),
                        ],
                      ),
                      const Divider(),
                      _buildSection(
                        'Others',
                        [
                          Obx(() => _buildSwitchTile(
                                'New Service Available',
                                controller.newServiceAvailable,
                                (value) => controller.updateSetting(
                                    'newServiceAvailable', value),
                              )),
                          Obx(() => _buildSwitchTile(
                                'New Tips Available',
                                controller.newTipsAvailable,
                                (value) => controller.updateSetting(
                                    'newTipsAvailable', value),
                              )),
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
        const SizedBox(height: 8),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
