import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/timer/controllers/timer_controller.dart';

class TimerSettingsDialog extends StatelessWidget {
  final TimerController controller;

  const TimerSettingsDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTimeSettingRow(
              'Focus length',
              controller.focusLength,
            ),
            const SizedBox(height: 16),
            _buildTimeSettingRow(
              'Short break length',
              controller.shortBreakLength,
            ),
            const SizedBox(height: 16),
            _buildTimeSettingRow(
              'Long break length',
              controller.longBreakLength,
            ),
            const SizedBox(height: 24),
            _buildToggleRow(
              'Sound',
              controller.soundEnabled,
            ),
            const SizedBox(height: 16),
            _buildToggleRow(
              'Notifications',
              controller.notificationsEnabled,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.updateSettings(
                    focus: controller.focusLength.value,
                    shortBreak: controller.shortBreakLength.value,
                    longBreak: controller.longBreakLength.value,
                    sound: controller.soundEnabled.value,
                    notifications: controller.notificationsEnabled.value,
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBBDE4E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettingRow(String label, RxInt value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Obx(() => Text(
                  '${value.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => value.value = (value.value + 1).clamp(1, 60),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.arrow_drop_up, size: 20),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    InkWell(
                      onTap: () => value.value = (value.value - 1).clamp(1, 60),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.arrow_drop_down, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String label, RxBool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Obx(() => Switch(
          value: value.value,
          onChanged: (newValue) => value.value = newValue,
          activeColor: const Color(0xFFBBDE4E),
        )),
      ],
    );
  }
} 