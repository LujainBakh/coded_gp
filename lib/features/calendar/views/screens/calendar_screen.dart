import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/features/calendar/controllers/calendar_controller.dart';
import 'package:coded_gp/features/calendar/models/event_model.dart';

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
  final CalendarController _calendarController = Get.find<CalendarController>();
  final _searchController = TextEditingController();

  // Add this to store all event type labels
  final List<Map<String, dynamic>> eventTypes = [
    {'label': 'Holiday', 'color': Colors.purple},
    {'label': 'Quiz', 'color': Colors.green},
    {'label': 'Event', 'color': Colors.blue},
    {'label': 'Meeting', 'color': Colors.orange},
    {'label': 'Task', 'color': Colors.red},
  ];

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
    // Fetch events when screen initializes
    _calendarController.fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _showAllEventsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                        const Text(
                          'All Events in Database',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            await _calendarController.fetchEvents();
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showAllEventsDialog(context);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Obx(() {
                          final allEvents = _calendarController.getAllEvents();
                          if (_calendarController.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (allEvents.isEmpty) {
                            return const Center(
                              child: Text('No events found in database'),
                            );
                          }
                          
                          return Column(
                            children: allEvents.map((event) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: EventModel.eventTypeColors[event.eventType] ?? Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${event.id}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Title: ${event.title}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Type: ${event.eventType}'),
                                  Text('Owner: ${event.ownerId}'),
                                  Text('Date: ${DateFormat('MMM d, yyyy').format(event.startTime)}'),
                                  Text('Time: ${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}'),
                                ],
                              ),
                            )).toList(),
                          );
                        }),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/vibrantskybg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search and Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search events...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _calendarController.setSearchQuery('');
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                              ),
                              onChanged: (value) {
                                _calendarController.setSearchQuery(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 40,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(() {
                            return Row(
                              children: EventModel.availableEventTypes.map((type) {
                                final isSelected = _calendarController.selectedEventTypes.contains(type);
                                final color = EventModel.eventTypeColors[type] ?? Colors.blue;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: RawChip(
                                    label: Text(
                                      type,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : color,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      _calendarController.toggleEventType(type);
                                    },
                                    selectedColor: color.withOpacity(1.0),
                                    backgroundColor: Colors.white,
                                    checkmarkColor: Colors.white,
                                    showCheckmark: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: color,
                                        width: 1.5,
                                      ),
                                    ),
                                    elevation: isSelected ? 4 : 0,
                                    pressElevation: 6,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
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
                          scaleX: -1,
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
                    color: const Color(0xFFD1E78D),
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
                      _showEventsForDay(context, selectedDay);
                    },
                    onDayLongPressed: (selectedDay, focusedDay) {
                      _showAddEventDialog(context, initialDate: selectedDay);
                    },
                    onPageChanged: _onPageChanged,
                    eventLoader: (day) => _calendarController.getEventsForDay(day),
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
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return null;
                        final eventTypes = events.map((e) => (e as EventModel).eventType).toSet();
                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: eventTypes.map((type) {
                              final color = EventModel.eventTypeColors[type] ?? Colors.blue;
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronVisible: false,
                      rightChevronVisible: false,
                      headerPadding: EdgeInsets.zero,
                      headerMargin: EdgeInsets.zero,
                      titleTextStyle: TextStyle(fontSize: 0),
                    ),
                  ),
                ),
                // Events list
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        if (_calendarController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final filteredEvents = _calendarController.getFilteredEvents();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${filteredEvents.length} Events',
                                  style: const TextStyle(
                                    fontSize: 16,
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
                            const SizedBox(height: 16),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 5 * 110.0, // Approximate height for 5 events
                              ),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: filteredEvents.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final event = filteredEvents[index];
                                    return _buildEventCard(
                                      title: event.title,
                                      subtitle: event.subtitle,
                                      dateTime: DateFormat('MMM d, yyyy').format(event.startTime),
                                      time: '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                                      eventType: event.eventType,
                                      location: event.location,
                                      notes: event.note,
                                      onDelete: () => _calendarController.deleteEvent(event.id),
                                      onEdit: () => _showEditEventDialog(
                                        context,
                                        event: event,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String subtitle,
    required String dateTime,
    required String time,
    required String eventType,
    String? location,
    String? notes,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    final color = EventModel.eventTypeColors[eventType] ?? Colors.blue;
    final icon = _getEventTypeIcon(eventType);

    return Container(
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
                        Container(
              width: 48,
              height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                icon,
                  color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
                      const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                dateTime,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (location != null && location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                  Row(
                    children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
                ],
              ),
            ),
            Column(
                  children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  color: Colors.blue,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(context, onDelete),
                        color: Colors.red,
                  iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'quiz':
        return Icons.quiz;
      case 'holiday':
        return Icons.beach_access;
      case 'event':
        return Icons.event;
      default:
        return Icons.calendar_today;
    }
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
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

  void _showAddEventDialog(BuildContext context, {DateTime? initialDate}) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final noteController = TextEditingController();
    final locationController = TextEditingController();
    final dateController = TextEditingController(
      text: initialDate != null ? DateFormat('MMM d, yyyy').format(initialDate) : '',
    );
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    String selectedEventType = 'Event';

    // Add validation state variables
    bool isTitleEmpty = false;
    bool isDateEmpty = false;
    bool isStartTimeEmpty = false;

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
                padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                      'Add New Event',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 24),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                        labelText: 'Title*',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        errorText: isTitleEmpty ? 'Title is required' : null,
                        errorBorder: isTitleEmpty ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ) : null,
                        focusedErrorBorder: isTitleEmpty ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ) : null,
                      ),
                      onChanged: (value) {
                        if (isTitleEmpty && value.isNotEmpty) {
                          setState(() {
                            isTitleEmpty = false;
                          });
                        }
                      },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                      controller: subtitleController,
                        decoration: InputDecoration(
                        labelText: 'Subtitle',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                        labelText: 'Date*',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        errorText: isDateEmpty ? 'Date is required' : null,
                        errorBorder: isDateEmpty ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ) : null,
                        focusedErrorBorder: isDateEmpty ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ) : null,
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: initialDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                          setState(() {
                            dateController.text = DateFormat('MMM d, yyyy').format(date);
                            isDateEmpty = false;
                          });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                              labelText: 'Start Time*',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              suffixIcon: const Icon(Icons.access_time),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              errorText: isStartTimeEmpty ? 'Required' : null,
                              errorBorder: isStartTimeEmpty ? OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ) : null,
                              focusedErrorBorder: isStartTimeEmpty ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ) : null,
                              ),
                              onTap: () async {
                              final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                              if (time != null) {
                                setState(() {
                                  startTimeController.text = time.format(context);
                                  isStartTimeEmpty = false;
                                });
                                }
                              },
                            ),
                          ),
                        const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              readOnly: true,
                              decoration: InputDecoration(
                              labelText: 'End Time',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              suffixIcon: const Icon(Icons.access_time),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onTap: () async {
                              final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                              if (time != null) {
                                setState(() {
                                  endTimeController.text = time.format(context);
                                });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                        labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: const Icon(Icons.location_on),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedEventType,
                      decoration: InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: eventTypes.map((type) {
                        final color = type['color'] as Color;
                        return DropdownMenuItem<String>(
                          value: type['label'] as String,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEventType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: () {
                        // Validate all required fields
                            setState(() {
                          isTitleEmpty = titleController.text.isEmpty;
                          isDateEmpty = dateController.text.isEmpty;
                          isStartTimeEmpty = startTimeController.text.isEmpty;
                        });

                        if (isTitleEmpty || isDateEmpty || isStartTimeEmpty) {
                          return;
                        }

                        // Parse the date and times
                        final date = DateFormat('MMM d, yyyy').parse(dateController.text);
                        final startTime = TimeOfDay.fromDateTime(
                          DateFormat('h:mm a').parse(startTimeController.text),
                        );
                        DateTime endDateTime;
                        if (endTimeController.text.isNotEmpty) {
                          final endTime = TimeOfDay.fromDateTime(
                            DateFormat('h:mm a').parse(endTimeController.text),
                          );
                          endDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            endTime.hour,
                            endTime.minute,
                          );
                        } else {
                          // If no end time is specified, set it to 1 hour after start time
                          endDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            startTime.hour,
                            startTime.minute,
                          ).add(const Duration(hours: 1));
                        }

                        // Create DateTime objects for start time
                        final startDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          startTime.hour,
                          startTime.minute,
                        );

                        // Create new event
                        final newEvent = EventModel(
                          id: '', // This will be set by Firestore
                          title: titleController.text,
                          subtitle: subtitleController.text,
                          startTime: startDateTime,
                          endTime: endDateTime,
                          location: locationController.text,
                          note: noteController.text,
                          eventType: selectedEventType,
                          remindMe: false,
                          type: 'User', // Set as user-created event
                          ownerId: '', // This will be set by the controller
                        );

                        // Add event to database
                        _calendarController.addEvent(newEvent);
                        Navigator.pop(context);
                      },
                      child: const Text('Save Event'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, {required EventModel event}) {
    final titleController = TextEditingController(text: event.title);
    final subtitleController = TextEditingController(text: event.subtitle);
    final noteController = TextEditingController(text: event.note);
    final locationController = TextEditingController(text: event.location);
    final dateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(event.startTime),
    );
    final startTimeController = TextEditingController(
      text: DateFormat('h:mm a').format(event.startTime),
    );
    final endTimeController = TextEditingController(
      text: DateFormat('h:mm a').format(event.endTime),
    );
    String selectedEventType = event.eventType;

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
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Edit Event',
                            style: TextStyle(
                        fontSize: 24,
                              fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title*',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date*',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: event.startTime,
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
                            controller: startTimeController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Start Time*',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(event.startTime),
                              );
                              if (time != null) {
                                startTimeController.text = time.format(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(event.endTime),
                              );
                              if (time != null) {
                                endTimeController.text = time.format(context);
                              }
                            },
                        ),
                      ),
                    ],
                  ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.location_on),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedEventType,
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: eventTypes.map((type) {
                        final color = type['color'] as Color;
                        return DropdownMenuItem<String>(
                          value: type['label'] as String,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEventType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty ||
                            dateController.text.isEmpty ||
                            startTimeController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please fill in all required fields',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // Parse the date and times
                        final date = DateFormat('MMM d, yyyy').parse(dateController.text);
                        final startTime = TimeOfDay.fromDateTime(
                          DateFormat('h:mm a').parse(startTimeController.text),
                        );
                        DateTime endDateTime;
                        if (endTimeController.text.isNotEmpty) {
                          final endTime = TimeOfDay.fromDateTime(
                            DateFormat('h:mm a').parse(endTimeController.text),
                          );
                          endDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            endTime.hour,
                            endTime.minute,
                          );
                        } else {
                          // If no end time is specified, set it to 1 hour after start time
                          endDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            startTime.hour,
                            startTime.minute,
                          ).add(const Duration(hours: 1));
                        }

                        // Create DateTime objects for start time
                        final startDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          startTime.hour,
                          startTime.minute,
                        );

                        // Create updated event
                        final updatedEvent = EventModel(
                          id: event.id,
                          title: titleController.text,
                          subtitle: subtitleController.text,
                          startTime: startDateTime,
                          endTime: endDateTime,
                          location: locationController.text,
                          note: noteController.text,
                          eventType: selectedEventType,
                          remindMe: false,
                          type: event.type,
                          ownerId: event.ownerId,
                        );

                        // Update event in database
                        _calendarController.updateEvent(updatedEvent);
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEventsForDay(BuildContext context, DateTime day) {
    final events = _calendarController.getEventsForDay(day);
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
                        Navigator.pop(context);
                        _showAddEventDialog(context, initialDate: day);
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
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.subtitle),
                              Text(DateFormat('h:mm a').format(event.startTime)),
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
                                    (type) => type['label'] == event.eventType,
                                    orElse: () => {'color': Colors.blue},
                                  )['color']
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.eventType,
                              style: TextStyle(
                                color: eventTypes
                                    .firstWhere(
                                      (type) => type['label'] == event.eventType,
                                      orElse: () => {'color': Colors.blue},
                                    )['color'],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showEventDetailsDialog(
                              context,
                              title: event.title,
                              subtitle: event.subtitle,
                              dateTime: formattedDate,
                              time: DateFormat('h:mm a').format(event.startTime),
                              eventType: event.eventType,
                              location: event.location,
                              notes: event.note,
                              event: event,
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

  void _showEventDetailsDialog(BuildContext context, {
    required String title,
    required String subtitle,
    required String dateTime,
    required String time,
    required String eventType,
    String? location,
    String? notes,
    required EventModel event,
  }) {
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
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, () => _calendarController.deleteEvent(event.id));
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
                        _showEditEventDialog(context, event: event);
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
}
