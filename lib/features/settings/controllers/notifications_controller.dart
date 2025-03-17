import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController extends GetxController {
  final _generalNotification = true.obs;
  final _sound = false.obs;
  final _vibrate = true.obs;
  final _appUpdates = false.obs;
  final _assignmentReminder = true.obs;
  final _examNotification = true.obs;
  final _registrationReminder = false.obs;
  final _newServiceAvailable = false.obs;
  final _newTipsAvailable = true.obs;

  // Getters
  bool get generalNotification => _generalNotification.value;
  bool get sound => _sound.value;
  bool get vibrate => _vibrate.value;
  bool get appUpdates => _appUpdates.value;
  bool get assignmentReminder => _assignmentReminder.value;
  bool get examNotification => _examNotification.value;
  bool get registrationReminder => _registrationReminder.value;
  bool get newServiceAvailable => _newServiceAvailable.value;
  bool get newTipsAvailable => _newTipsAvailable.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load saved settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _generalNotification.value = prefs.getBool('generalNotification') ?? true;
    _sound.value = prefs.getBool('sound') ?? false;
    _vibrate.value = prefs.getBool('vibrate') ?? true;
    _appUpdates.value = prefs.getBool('appUpdates') ?? false;
    _assignmentReminder.value = prefs.getBool('assignmentReminder') ?? true;
    _examNotification.value = prefs.getBool('examNotification') ?? true;
    _registrationReminder.value = prefs.getBool('registrationReminder') ?? false;
    _newServiceAvailable.value = prefs.getBool('newServiceAvailable') ?? false;
    _newTipsAvailable.value = prefs.getBool('newTipsAvailable') ?? true;
  }

  // Update settings
  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    switch (key) {
      case 'generalNotification':
        _generalNotification.value = value;
        break;
      case 'sound':
        _sound.value = value;
        break;
      case 'vibrate':
        _vibrate.value = value;
        break;
      case 'appUpdates':
        _appUpdates.value = value;
        break;
      case 'assignmentReminder':
        _assignmentReminder.value = value;
        break;
      case 'examNotification':
        _examNotification.value = value;
        break;
      case 'registrationReminder':
        _registrationReminder.value = value;
        break;
      case 'newServiceAvailable':
        _newServiceAvailable.value = value;
        break;
      case 'newTipsAvailable':
        _newTipsAvailable.value = value;
        break;
    }
  }
} 