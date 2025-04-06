import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/folder_model.dart';

// Add the enum definition here
enum SortOption {
  alphabetical,
  newest,
  oldest,
}

class FolderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Folder> folders = <Folder>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<SortOption> currentSort = SortOption.newest.obs;

  void setSortOption(SortOption option) {
    currentSort.value = option;
    _sortFolders();
  }

  void _sortFolders() {
    switch (currentSort.value) {
      case SortOption.alphabetical:
        folders.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.newest:
        folders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        folders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
  }

  Future<void> getFolders(String userId) async {
    try {
      isLoading.value = true;
      final folderSnapshot = await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .get();

      folders.value = folderSnapshot.docs
          .map((doc) => Folder.fromMap(doc.id, doc.data()))
          .toList();

      _sortFolders(); // Sort according to current sort option
    } catch (e) {
      print('Error fetching folders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createFolder(String userId, String name) async {
    try {
      await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .add({
        'name': name,
        'path': '',
        'iconUrl':
            'assets/images/folder_icons/default_folder.png', // Set default icon path
        'createdAt': Timestamp.now(),
      });

      await getFolders(userId);
    } catch (e) {
      print('Error creating folder: $e');
    }
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    try {
      await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .delete();

      await getFolders(userId);
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }
}
