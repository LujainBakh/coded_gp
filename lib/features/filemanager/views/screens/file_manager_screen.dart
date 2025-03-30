import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/app_bottom_nav_bar.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';
import 'package:coded_gp/features/filemanager/controllers/folder_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coded_gp/features/filemanager/models/folder_model.dart';
import 'package:coded_gp/features/filemanager/views/screens/add_folder_screen.dart';

class FileManagerScreen extends StatelessWidget {
  FileManagerScreen({super.key});

  final FolderController folderController = Get.put(FolderController());

  void _navigateToAddScreen() {
    Get.to(
        () => const AddFolderScreen()); // Direct navigation to AddFolderScreen
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Alphabetical'),
              onTap: () {
                folderController.setSortOption(SortOption.alphabetical);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Newest First'),
              onTap: () {
                folderController.setSortOption(SortOption.newest);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Oldest First'),
              onTap: () {
                folderController.setSortOption(SortOption.oldest);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch folders when screen loads
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      folderController.getFolders(userId);
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/coded_bg2.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        const CustomBackButton(),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'File Manager',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Add Filter Button
                        InkWell(
                          onTap: () => _showSortOptions(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.filter_list),
                          ),
                        ),
                        // Existing Add Button
                        InkWell(
                          onTap: _navigateToAddScreen,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (folderController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 0.85,
                        children: folderController.folders
                            .map((folder) => _buildFolderItem(folder))
                            .toList(),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: AppBottomNavBar(
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
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(Folder folder) {
    return GestureDetector(
      onLongPress: () {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: const Text('Delete Folder'),
              content:
                  Text('Are you sure you want to delete "${folder.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    folderController.deleteFolder(userId, folder.id);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                folder.iconUrl.startsWith('/')
                    ? folder.iconUrl.substring(1)
                    : folder.iconUrl,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading folder icon: $error');
                  return const Icon(
                    Icons.folder,
                    size: 120,
                    color: Colors.blue,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  folder.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
