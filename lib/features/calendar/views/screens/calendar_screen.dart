import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final _firstDay = DateTime.now().subtract(const Duration(days: 1000));
  final _lastDay = DateTime.now().add(const Duration(days: 1000));

  // Add this to store all event type labels
  final List<Map<String, dynamic>> eventTypes = [
    {'label': 'Holiday', 'color': Colors.purple},
    {'label': 'Quiz', 'color': Colors.green},
    {'label': 'Event', 'color': Colors.blue},
  ];

  // Add this to store events
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  // Add this method to get events for a specific day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Add this method to create event markers
  List<EventMarker> _getEventMarkersForDay(DateTime day) {
    final events = _getEventsForDay(day);
    return events.map((event) {
      final eventTypeData = eventTypes.firstWhere(
        (type) => type['label'] == event['eventType'],
        orElse: () => {'label': 'Event', 'color': Colors.blue},
      );
      return EventMarker(color: eventTypeData['color'] as Color);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Check if a date was passed as argument
    final arguments = Get.arguments;
    if (arguments != null && arguments is DateTime) {
      _focusedDay = arguments;
      _selectedDay = arguments;
    } else {
      _focusedDay = DateTime.now();
    }
    // Initialize example events with proper event types
    _events[DateTime(2025, 9, 17)] = [
      {
        'title': 'ROBOTICS CAMP',
        'eventType': 'Event',
        'subtitle': 'ARTIFICIAL INTELLIGENCE CLUB',
        'time': '11:30 AM - 12:30 PM',
      },
    ];
    _events[DateTime(2025, 9, 19)] = [
      {
        'title': 'FLUTTER WORKSHOP',
        'eventType': 'Quiz',
        'subtitle': 'MOBILE DEVELOPMENT SOCIETY',
        'time': '2:00 PM - 4:00 PM',
      },
    ];
    _events[DateTime(2025, 9, 20)] = [
      {
        'title': 'CYBERSECURITY SEMINAR',
        'eventType': 'Holiday',
        'subtitle': 'INFORMATION SECURITY CLUB',
        'time': '10:00 AM - 11:30 AM',
      },
    ];
    // Add more events as needed...
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/coded_bg3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Month header with navigation ducks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            _focusedDay.day,
                          );
                        });
                      },
                      child: Transform.scale(
                        scaleX: -1, // Flip the left duck
                        child: Image.asset('assets/images/Duck-01.png', height: 40),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          DateFormat('MMMM').format(_focusedDay),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          DateFormat('yyyy').format(_focusedDay),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            _focusedDay.day,
                          );
                        });
                      },
                      child: Image.asset('assets/images/Duck-01.png', height: 40),
                    ),
                  ],
                ),
              ),
              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E78D), // Updated to your specified green
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onDayLongPressed: (selectedDay, focusedDay) {
                    _showEventsForDay(context, selectedDay);
                  },
                  onPageChanged: _onPageChanged,
                  eventLoader: _getEventsForDay,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                            width: 35,
                            height: 15,
                            child: Center(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: events.length > 3 ? 3 : events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index] as Map<String, dynamic>;
                                  final eventTypeData = eventTypes.firstWhere(
                                    (type) => type['label'] == event['eventType'],
                                    orElse: () => {'label': 'Event', 'color': Colors.blue},
                                  );
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: eventTypeData['color'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: true,
                    outsideTextStyle: const TextStyle(color: Colors.grey),
                    weekendTextStyle: const TextStyle(color: Color(0xFF000080)),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                    todayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    cellPadding: const EdgeInsets.all(6),
                    markersAlignment: Alignment.bottomCenter,
                    markerSize: 6,
                    markersMaxCount: 3,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    headerPadding: EdgeInsets.zero,
                    headerMargin: EdgeInsets.zero,
                    titleTextStyle: TextStyle(fontSize: 0), // Hide title by making it size 0
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                    weekendStyle: TextStyle(
                      color: Color(0xFF000080),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Events list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Events',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () => _showAddEventDialog(context),
                            color: Theme.of(context).primaryColor,
                            iconSize: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '5 Events',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 80),
                          children: [
                            _buildEventCard(
                              title: 'ROBOTICS CAMP',
                              subtitle: 'ARTIFICIAL INTELLIGENCE CLUB',
                              dateTime: 'Mon, 17 Sep 2025',
                              time: '11:30 AM - 12:30 PM',
                              eventType: 'Event',
                              location: 'Room A11',
                              notes: 'Bring your laptop and robotics kit',
                            ),
                            const SizedBox(height: 12),
                            _buildEventCard(
                              title: 'FLUTTER WORKSHOP',
                              subtitle: 'MOBILE DEVELOPMENT SOCIETY',
                              dateTime: 'Wed, 19 Sep 2025',
                              time: '2:00 PM - 4:00 PM',
                              eventType: 'Quiz',
                            ),
                            const SizedBox(height: 12),
                            _buildEventCard(
                              title: 'CYBERSECURITY SEMINAR',
                              subtitle: 'INFORMATION SECURITY CLUB',
                              dateTime: 'Thu, 20 Sep 2025',
                              time: '10:00 AM - 11:30 AM',
                              eventType: 'Event',
                            ),
                            const SizedBox(height: 12),
                            _buildEventCard(
                              title: 'GAME JAM 2025',
                              subtitle: 'GAME DEVELOPMENT CLUB',
                              dateTime: 'Sat, 22 Sep 2025',
                              time: '9:00 AM - 9:00 PM',
                              eventType: 'Event',
                            ),
                            const SizedBox(height: 12),
                            _buildEventCard(
                              title: 'AWS CLOUD WORKSHOP',
                              subtitle: 'CLOUD COMPUTING SOCIETY',
                              dateTime: 'Mon, 24 Sep 2025',
                              time: '1:00 PM - 3:00 PM',
                              eventType: 'Event',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AppBottomNavBar(
          currentIndex: 2, // Calendar is at index 2
          onTap: (index) {
            if (index != 2) { // If not current screen
              Get.back(); // Go back to main screen which will handle the navigation
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, {DateTime? initialDate}) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final dateController = TextEditingController(
      // If initialDate is provided, use it; otherwise leave empty
      text: initialDate != null ? DateFormat('MMM d, yyyy').format(initialDate) : '',
    );
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    bool remindMe = false;
    String selectedEventType = 'Event';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Event',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Event name*',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Type the note here...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Date',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDay ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2025, 12, 31),
                          );
                          if (date != null) {
                            dateController.text = DateFormat('MMM d, yyyy').format(date);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: timeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Time',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                suffixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  timeController.text = time.format(context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: locationController,
                              decoration: InputDecoration(
                                hintText: 'Location',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                suffixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remind me',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: remindMe,
                            onChanged: (value) {
                              setState(() {
                                remindMe = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8, // Add vertical spacing between wrapped rows
                        children: [
                          // Generate radio buttons for all event types
                          ...eventTypes.map((type) => _buildEventTypeRadio(
                            type['label'],
                            type['color'],
                            selectedEventType,
                            (value) {
                              setState(() => selectedEventType = value!);
                            },
                          )).toList(),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          _showAddLabelDialog(context, (newLabel) {
                            setState(() {
                              // Add the new label with a random color and select it
                              eventTypes.add({
                                'label': newLabel,
                                'color': Colors.primaries[
                                  eventTypes.length % Colors.primaries.length
                                ],
                              });
                              selectedEventType = newLabel;
                            });
                          });
                        },
                        child: Text(
                          '+ Add new',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final date = DateFormat('MMM d, yyyy').parse(dateController.text);
                            final eventData = {
                              'title': titleController.text,
                              'subtitle': titleController.text,
                              'time': timeController.text,
                              'eventType': selectedEventType,
                              'location': locationController.text,
                              'notes': noteController.text,
                            };

                            setState(() {
                              if (_events[date] == null) {
                                _events[date] = [];
                              }
                              _events[date]!.add(eventData);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4789),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Event',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventTypeRadio(String label, Color color, String selectedValue, Function(String?) onChanged) {
    // Don't allow deletion of default labels
    bool isDefaultLabel = ['Holiday', 'Quiz', 'Event'].contains(label);

    return GestureDetector(
      onLongPress: isDefaultLabel ? null : () {
        _showDeleteLabelDialog(context, label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selectedValue == label ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedValue == label ? color : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: label,
              groupValue: selectedValue,
              onChanged: onChanged,
              activeColor: color,
            ),
            Text(
              label,
              style: TextStyle(
                color: selectedValue == label ? color : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method to show delete confirmation
  void _showDeleteLabelDialog(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Label'),
          content: Text('Are you sure you want to delete "$label"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  eventTypes.removeWhere((type) => type['label'] == label);
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddLabelDialog(BuildContext context, Function(String) onLabelAdded) {
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add New Label',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    hintText: 'Enter label name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (labelController.text.isNotEmpty) {
                          onLabelAdded(labelController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Update the _buildEventCard method to include onTap
  Widget _buildEventCard({
    required String title,
    required String subtitle,
    required String dateTime,
    required String time,
    required String eventType,
    String? location,
    String? notes,
  }) {
    final eventTypeData = eventTypes.firstWhere(
      (type) => type['label'] == eventType,
      orElse: () => {'label': 'Event', 'color': Colors.blue},
    );
    final color = eventTypeData['color'] as Color;

    return GestureDetector(
      onTap: () => _showEventDetailsDialog(
        context,
        title: title,
        subtitle: subtitle,
        dateTime: dateTime,
        time: time,
        location: location,
        notes: notes,
        eventType: eventType,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF).withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            eventType,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$dateTime    $time',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update the event details dialog to show the event type
  void _showEventDetailsDialog(BuildContext context, {
    required String title,
    required String subtitle,
    required String dateTime,
    required String time,
    required String eventType,
    String? location,
    String? notes,
  }) {
    // Find the color for this event type
    final eventTypeData = eventTypes.firstWhere(
      (type) => type['label'] == eventType,
      orElse: () => {'label': 'Event', 'color': Colors.blue},
    );
    final color = eventTypeData['color'] as Color;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              eventType,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.check,
                        color: color,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$dateTime\n$time',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Notes:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close details dialog
                        _showDeleteConfirmation(context, title);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditEventDialog(context,
                          title: title,
                          subtitle: subtitle,
                          dateTime: dateTime,
                          time: time,
                          location: location ?? '',
                          notes: notes ?? '',
                          eventType: eventType,
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this method to show delete confirmation
  void _showDeleteConfirmation(BuildContext context, String eventTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Event'),
          content: Text('Are you sure you want to delete "$eventTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add delete functionality here
                Navigator.pop(context);
                // Show confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add this new method for editing events
  void _showEditEventDialog(BuildContext context, {
    required String title,
    required String subtitle,
    required String dateTime,
    required String time,
    required String location,
    required String notes,
    required String eventType,
  }) {
    final titleController = TextEditingController(text: title);
    final noteController = TextEditingController(text: notes);
    final dateController = TextEditingController(text: dateTime);
    final timeController = TextEditingController(text: time);
    final locationController = TextEditingController(text: location);
    bool remindMe = false;
    String selectedEventType = eventType;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Event',  // Changed from 'Add New Event'
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Event name*',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Type the note here...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Date',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDay ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2025, 12, 31),
                          );
                          if (date != null) {
                            dateController.text = DateFormat('MMM d, yyyy').format(date);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: timeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Time',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                suffixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  timeController.text = time.format(context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: locationController,
                              decoration: InputDecoration(
                                hintText: 'Location',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                suffixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remind me',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: remindMe,
                            onChanged: (value) {
                              setState(() {
                                remindMe = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8, // Add vertical spacing between wrapped rows
                        children: [
                          // Generate radio buttons for all event types
                          ...eventTypes.map((type) => _buildEventTypeRadio(
                            type['label'],
                            type['color'],
                            selectedEventType,
                            (value) {
                              setState(() => selectedEventType = value!);
                            },
                          )).toList(),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          _showAddLabelDialog(context, (newLabel) {
                            setState(() {
                              // Add the new label with a random color and select it
                              eventTypes.add({
                                'label': newLabel,
                                'color': Colors.primaries[
                                  eventTypes.length % Colors.primaries.length
                                ],
                              });
                              selectedEventType = newLabel;
                            });
                          });
                        },
                        child: Text(
                          '+ Add new',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Save changes functionality
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4789),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',  // Changed from 'Create Event'
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Add this method to show events for a specific day
  void _showEventsForDay(BuildContext context, DateTime day) {
    final events = _getEventsForDay(day);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(day);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
        onPressed: () {
                        Navigator.pop(context); // Close current dialog
                        _showAddEventDialog(
                          context,
                          initialDate: day, // Pass the selected day
                        );
                      },
                      color: Theme.of(context).primaryColor,
                      iconSize: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (events.isEmpty)
                  const Text(
                    'No events scheduled for this day',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: events.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return ListTile(
                          title: Text(
                            event['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event['subtitle'] as String),
                              Text(event['time'] as String),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: eventTypes
                                  .firstWhere(
                                    (type) => type['label'] == event['eventType'],
                                    orElse: () => {'color': Colors.blue},
                                  )['color']
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event['eventType'] as String,
                              style: TextStyle(
                                color: eventTypes
                                    .firstWhere(
                                      (type) => type['label'] == event['eventType'],
                                      orElse: () => {'color': Colors.blue},
                                    )['color'],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Close the dialog
                            _showEventDetailsDialog(
                              context,
                              title: event['title'] as String,
                              subtitle: event['subtitle'] as String,
                              dateTime: formattedDate,
                              time: event['time'] as String,
                              eventType: event['eventType'] as String,
                              location: event['location'] as String?,
                              notes: event['notes'] as String?,
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Add this class for custom event markers
class EventMarker extends StatelessWidget {
  final Color color;

  const EventMarker({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
