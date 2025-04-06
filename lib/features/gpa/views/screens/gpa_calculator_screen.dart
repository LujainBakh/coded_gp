import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  State<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final List<CourseEntry> courses = [];
  double? calculatedGPA;

  final Map<String, double> gradePoints = {
    'A+': 5.0,
    'A': 4.75,
    'B+': 4.5,
    'B': 4.0,
    'C+': 3.5,
    'C': 3.0,
    'D+': 2.5,
    'D': 2.0,
    'F': 1.0,
  };

  void addCourse() {
    setState(() {
      courses.add(
        CourseEntry(
          key: UniqueKey(),
          onDelete: deleteCourse,
        ),
      );
    });
  }

  void deleteCourse(CourseEntry course) {
    setState(() {
      courses.remove(course);
    });
  }

  void clearAll() {
    setState(() {
      courses.clear();
      calculatedGPA = null;
    });
  }

  void calculateGPA() {
    if (courses.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one course',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    double totalPoints = 0;
    double totalCredits = 0;

    for (var course in courses) {
      if (course.grade.isEmpty || course.credits == 0) {
        Get.snackbar(
          'Error',
          'Please fill all course information',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      double gradePoint = gradePoints[course.grade] ?? 0;
      totalPoints += gradePoint * course.credits;
      totalCredits += course.credits;
    }

    setState(() {
      calculatedGPA = totalPoints / totalCredits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Coded_bg3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with just back button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                child: Row(
                  children: [
                    const CustomBackButton(),
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

              // Main Content
              Expanded(
                child: courses.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Course Name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1a457b),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: const Center(
                                        child: Text(
                                          'Grade',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1a457b),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: const Center(
                                        child: Text(
                                          'Credits',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1a457b),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: courses,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Show GPA if calculated
                              if (calculatedGPA != null)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 187, 222, 78),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Your GPA: ${calculatedGPA!.toStringAsFixed(2)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Always show Calculate button
                              Container(
                                width: double.infinity,
                                height: 50,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: ElevatedButton(
                                  onPressed: calculateGPA,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1a457b),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Calculate',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Always show Add Course and Clear All buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: addCourse,
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFF1a457b),
                                    ),
                                    label: const Text(
                                      'Add Course',
                                      style: TextStyle(
                                        color: Color(0xFF1a457b),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  TextButton.icon(
                                    onPressed: clearAll,
                                    icon: const Icon(
                                      Icons.clear_all,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
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
            Get.offAllNamed('/main');
          } else if (index == 1) {
            Get.toNamed('/chatbot');
          } else if (index == 2) {
            Get.offAllNamed('/main', arguments: 2);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Duck-01.png',
            height: 120,
          ),
          const SizedBox(height: 20),
          const Text(
            'Please add courses to start\ncalculating your GPA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () => addCourse(),
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF1a457b),
            ),
            label: const Text(
              'Add Course',
              style: TextStyle(
                color: Color(0xFF1a457b),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseEntry extends StatefulWidget {
  final void Function(CourseEntry) onDelete;
  final _CourseEntryState _state = _CourseEntryState();

  CourseEntry({
    super.key,
    required this.onDelete,
  });

  String get grade => _state.grade;
  double get credits => _state.credits;

  @override
  State<CourseEntry> createState() => _state;
}

class _CourseEntryState extends State<CourseEntry> {
  String grade = '';
  double credits = 0;
  final TextEditingController courseNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: courseNameController,
              decoration: InputDecoration(
                hintText: 'Enter course name',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1a457b)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: DropdownButtonFormField<String>(
              value: grade.isEmpty ? null : grade,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1a457b)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  grade = newValue ?? '';
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: DropdownButtonFormField<int>(
              value: credits == 0 ? null : credits.toInt(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1a457b)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  credits = newValue?.toDouble() ?? 0;
                });
              },
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 24,
            ),
            onPressed: () => widget.onDelete(widget),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    courseNameController.dispose();
    super.dispose();
  }
}
