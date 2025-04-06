import 'package:get/get.dart';
import 'package:coded_gp/features/filemanager/views/screens/add_folder_screen.dart';

class AppPages {
  static final routes = [
    // ... other routes ...
    GetPage(
      name: '/add-folder',
      page: () => const AddFolderScreen(),
    ),
  ];
}
