import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/timer/controllers/timer_controller.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';
import 'package:coded_gp/features/timer/views/widgets/timer_settings_dialog.dart';

// Helper function for calculating duck position
Offset _getDuckOffset(double centerX, double centerY, double radius, double angle, double size) {
  return Offset(
    centerX + radius * cos(angle - pi / 2) - size / 2,
    centerY + radius * sin(angle - pi / 2) - size / 2,
  );
}

class TimerRingWithDuck extends StatelessWidget {
  final double progress;
  final String timeText;
  final Color baseColor;
  final Color progressColor;

  const TimerRingWithDuck({
    super.key,
    required this.progress,
    required this.timeText,
    required this.baseColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    const double ringSize = 240;
    const double duckSize = 50;
    const double strokeWidth = 16;

    // Make room for duck on all sides
    const double totalWidth = ringSize + duckSize;
    const double totalHeight = ringSize + duckSize;

    final double centerX = ringSize / 2;
    final double centerY = totalHeight / 2;
    final double radius = (ringSize - strokeWidth) / 2;

    final double angle = 2 * pi * progress;
    final double duckX = centerX + radius * cos(angle - pi / 2) - duckSize / 2;
    final double duckY = centerY + radius * sin(angle - pi / 2) - duckSize / 2;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        children: [
          // Ring (centered lower)
          Positioned(
            top: duckSize / 2,
            left: duckSize / 2,
            child: SizedBox(
              width: ringSize,
              height: ringSize,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  baseColor: baseColor,
                  progressColor: progressColor,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          ),

          // Duck
          Positioned(
            left: duckX,
            top: duckY,
            child: SizedBox(
              width: duckSize,
              height: duckSize,
              child: Image.asset(
                'assets/images/Duck-01.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Time
          Positioned(
            top: duckSize / 2,
            left: duckSize / 2,
            right: duckSize / 2,
            child: SizedBox(
              height: ringSize,
              child: Center(
                child: Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => true;
}

class TimerScreen extends GetView<TimerController> {
  TimerScreen({super.key}) {
    if (!Get.isRegistered<TimerController>()) {
      Get.put(TimerController());
    }
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TimerSettingsDialog(controller: controller),
    );
  }

  Color _getTimerColor(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return const Color(0xFF1A4B8C); // Blue
      case TimerMode.shortBreak:
        return const Color(0xFFBBDE4E); // Light green
      case TimerMode.longBreak:
        return Colors.grey[700]!; // Dark gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CustomBackButton(
                      onPressed: () => Get.offAllNamed('/home'),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Study Timer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () => _showSettings(context),
                    ),
                  ],
                ),
              ),
              
              // Timer Mode Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _buildModeButton('Focus', TimerMode.focus),
                      _buildModeButton('Short break', TimerMode.shortBreak),
                      _buildModeButton('Long break', TimerMode.longBreak),
                    ],
                  ),
                ),
              ),
              
              // Timer Display with Duck
              Expanded(
                child: Center(
                  child: Obx(() {
                    const double ringSize = 240;
                    const double duckSize = 50;
                    const double strokeWidth = 16;

                    const double extraPadding = duckSize; // padding on all sides

                    final double totalWidth = ringSize + extraPadding;
                    final double totalHeight = ringSize + extraPadding;

                    final double centerX = totalWidth / 2;
                    final double centerY = totalHeight / 2;
                    final double radius = (ringSize - strokeWidth) / 2;

                    final double angle = 2 * pi * controller.progress.value;
                    final Offset duckOffset = _getDuckOffset(centerX, centerY, radius, angle, duckSize);

                    return SizedBox(
                      width: totalWidth,
                      height: totalHeight,
                      child: Stack(
                        children: [
                          // Background ring
                          Positioned(
                            left: extraPadding / 2,
                            top: extraPadding / 2,
                            child: SizedBox(
                              width: ringSize,
                              height: ringSize,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: strokeWidth,
                                valueColor: AlwaysStoppedAnimation(
                                  _getTimerColor(controller.currentMode.value).withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),

                          // Progress ring
                          Positioned(
                            left: extraPadding / 2,
                            top: extraPadding / 2,
                            child: SizedBox(
                              width: ringSize,
                              height: ringSize,
                              child: CircularProgressIndicator(
                                value: controller.progress.value,
                                strokeWidth: strokeWidth,
                                valueColor: AlwaysStoppedAnimation(
                                  _getTimerColor(controller.currentMode.value),
                                ),
                              ),
                            ),
                          ),

                          // Duck
                          Positioned(
                            left: duckOffset.dx,
                            top: duckOffset.dy,
                            child: SizedBox(
                              width: duckSize,
                              height: duckSize,
                              child: Image.asset(
                                'assets/images/Duck-01.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          // Timer Text
                          Positioned(
                            left: 0,
                            right: 0,
                            top: extraPadding / 2,
                            bottom: extraPadding / 2,
                            child: Center(
                              child: Text(
                                controller.timeString,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _getTimerColor(controller.currentMode.value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              
              // Control Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          controller.isRunning.value ? 'Pause' : 'Start',
                          controller.isRunning.value ? const Color(0xFFFFF8E7) : const Color(0xFFBBDE4E),
                          controller.isRunning.value ? Icons.pause : Icons.play_arrow,
                          controller.isRunning.value ? Colors.black87 : Colors.white,
                          () => controller.toggleTimer(),
                          size: 100,
                        ),
                        _buildControlButton(
                          'Reset',
                          Colors.white,
                          Icons.refresh,
                          const Color(0xFF1A4B8C),
                          () => controller.resetTimer(),
                          size: 60,
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, TimerMode mode) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.currentMode.value == mode;
        return GestureDetector(
          onTap: () => controller.setMode(mode),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFBBDE4E) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildControlButton(
    String label,
    Color color,
    IconData icon,
    Color iconColor,
    VoidCallback onTap, {
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Icon(icon, color: iconColor, size: size * 0.4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 