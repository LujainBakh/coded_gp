import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coded_gp/features/filemanager/controllers/folder_controller.dart';

class AddFolderScreen extends StatefulWidget {
  const AddFolderScreen({super.key});

  @override
  State<AddFolderScreen> createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final TextEditingController _titleController = TextEditingController();
  int selectedColorIndex = 0;
  final FolderController folderController = Get.find<FolderController>();

  final List<Color> folderColors = [
    const Color(0xFF738BAD), // Blue
    const Color(0xFFD9D9D9), // Grey
    const Color(0xFFBADE4E), // Green
    const Color(0xFFFEECA0), // Yellow
    const Color(0xFFFFA8A8), // Pink
    const Color(0xFFD5C1FE), // Purple
  ];

  // Add mapping for folder icons
  final List<String> folderIcons = [
    'assets/images/folder_icons/folder_blue.png',
    'assets/images/folder_icons/folder_grey.png',
    'assets/images/folder_icons/folder_green.png',
    'assets/images/folder_icons/folder_yellow.png',
    'assets/images/folder_icons/folder_pink.png',
    'assets/images/folder_icons/folder_purple.png',
  ];

  Future<void> createFolder() async {
    if (_titleController.text.isEmpty) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('Error: No user logged in');
        return;
      }

      final folderRef = FirebaseFirestore.instance
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc();

      // Create the folder document
      await folderRef.set({
        'name': _titleController.text,
        'iconUrl': folderIcons[selectedColorIndex],
        'createdAt': FieldValue.serverTimestamp(),
        'path': userId,
      });

      // Create an empty files collection for this folder
      final filesCollectionRef = folderRef.collection('files');
      await filesCollectionRef.add({});

      // Refresh folders and then go back
      await folderController.getFolders(userId);
      Get.offAllNamed('/file-manager');
    } catch (e) {
      print('Error creating folder: $e');
      // Add error handling/user feedback here
    }
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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomBackButton(
                      useNavigator: false,
                      onPressed: () => Get.offNamed('/file-manager'),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 40), // Offset for the back button
                        child: const Text(
                          'New Folder',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Title Section
                const Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    hintText: 'Enter folder name',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Color(0xFF1A237E), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // Color Selection Section
                Center(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: folderColors.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => selectedColorIndex = index),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: folderColors[index],
                                shape: BoxShape.circle,
                                border: selectedColorIndex == index
                                    ? Border.all(
                                        color: const Color(0xFF1A237E),
                                        width: 2)
                                    : Border.all(color: Colors.white, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a folder name'),
                            backgroundColor: Color(0xFF1A237E),
                          ),
                        );
                        return;
                      }
                      createFolder();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Create Folder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
