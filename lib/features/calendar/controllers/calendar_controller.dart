import 'package:get/get.dart';

class CalendarController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final events = <DateTime, List<String>>{}.obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void addEvent(DateTime date, String event) {
    if (events[date] != null) {
      events[date]!.add(event);
    } else {
      events[date] = [event];
    }
    events.refresh();
  }
} 