import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:coded_gp/core/services/notification_service.dart';

enum TimerMode {
  focus,
  shortBreak,
  longBreak,
}

class TimerController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final Rx<TimerMode> currentMode = TimerMode.focus.obs;
  final RxInt timeLeft = 0.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool isRunning = false.obs;
  Timer? _timer;

  // Settings
  final RxInt focusLength = 25.obs;
  final RxInt shortBreakLength = 5.obs;
  final RxInt longBreakLength = 15.obs;
  final RxBool soundEnabled = true.obs;
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _notificationService.initialize();
    setMode(TimerMode.focus);
  }

  String _getModeMessage(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'Focus session completed! Time for a break.';
      case TimerMode.shortBreak:
        return 'Short break completed! Ready to focus again?';
      case TimerMode.longBreak:
        return 'Long break completed! Let\'s get back to work.';
    }
  }

  void updateSettings({
    int? focus,
    int? shortBreak,
    int? longBreak,
    bool? sound,
    bool? notifications,
  }) {
    if (focus != null) focusLength.value = focus;
    if (shortBreak != null) shortBreakLength.value = shortBreak;
    if (longBreak != null) longBreakLength.value = longBreak;
    if (sound != null) soundEnabled.value = sound;
    if (notifications != null) notificationsEnabled.value = notifications;
    
    // Update current timer if needed
    setMode(currentMode.value);
  }

  void setMode(TimerMode mode) {
    currentMode.value = mode;
    int minutes;
    switch (mode) {
      case TimerMode.focus:
        minutes = focusLength.value;
        break;
      case TimerMode.shortBreak:
        minutes = shortBreakLength.value;
        break;
      case TimerMode.longBreak:
        minutes = longBreakLength.value;
        break;
    }
    timeLeft.value = minutes * 60;
    progress.value = 1.0;
    stopTimer();
  }

  String get timeString {
    int minutes = timeLeft.value ~/ 60;
    int seconds = timeLeft.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void toggleTimer() {
    if (isRunning.value) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (timeLeft.value <= 0) {
      resetTimer();
      return;
    }
    
    isRunning.value = true;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
        _updateProgress();
      } else {
        stopTimer();
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() async {
    // Get the appropriate message based on the completed mode
    String message = '';
    switch (currentMode.value) {
      case TimerMode.focus:
        message = 'Good work, Start a short break';
        break;
      case TimerMode.shortBreak:
        message = 'Break time is over, Let\'s focus again!';
        break;
      case TimerMode.longBreak:
        message = 'Long break completed! Ready for another session?';
        break;
    }

    // Show system notification if enabled
    if (notificationsEnabled.value) {
      await _notificationService.scheduleEventNotification(
        id: DateTime.now().millisecondsSinceEpoch.hashCode,
        title: 'CodEd',
        body: message,
        scheduledTime: DateTime.now(),
      );
    }
    
    // Show the in-app banner
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.snackbar(
        '',  // Empty title since we're using titleText
        '',  // Empty message since we're using messageText
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.all(10),
        borderRadius: 15,
        duration: const Duration(seconds: 4),
        icon: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset(
            'assets/images/Duck-01.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        titleText: const Text(
          'CodEd',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        overlayBlur: 0,
        overlayColor: Colors.transparent,
        snackStyle: SnackStyle.FLOATING,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
        animationDuration: const Duration(milliseconds: 500),
      );
    });

    // Automatically switch to the next appropriate mode
    switch (currentMode.value) {
      case TimerMode.focus:
        setMode(TimerMode.shortBreak);
        break;
      case TimerMode.shortBreak:
        setMode(TimerMode.focus);
        break;
      case TimerMode.longBreak:
        setMode(TimerMode.focus);
        break;
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void stopTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    setMode(currentMode.value);
  }

  void _updateProgress() {
    int totalSeconds;
    switch (currentMode.value) {
      case TimerMode.focus:
        totalSeconds = focusLength.value * 60;
        break;
      case TimerMode.shortBreak:
        totalSeconds = shortBreakLength.value * 60;
        break;
      case TimerMode.longBreak:
        totalSeconds = longBreakLength.value * 60;
        break;
    }
    progress.value = 1 - (timeLeft.value / totalSeconds);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
} 