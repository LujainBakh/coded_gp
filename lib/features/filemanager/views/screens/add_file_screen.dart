import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/core/common/widgets/custom_back_button.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:coded_gp/features/filemanager/services/appwrite_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:coded_gp/core/config/appwrite_config.dart';
import 'package:coded_gp/core/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFileScreen extends StatefulWidget {
  const AddFileScreen({super.key});

  @override
  State<AddFileScreen> createState() => _AddFileScreenState();
}

class _AddFileScreenState extends State<AddFileScreen> {
  final TextEditingController _titleController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  late AppwriteStorageService _storageService;
  late String _folderId;

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    final args = Get.arguments;
    if (args is Map && args['folderId'] != null) {
      _folderId = args['folderId'];
    } else if (args is String) {
      _folderId = args;
    } else {
      _folderId = 'root';
    }
  }

  void _initializeAppwrite() {
    final client = Client()
      ..setEndpoint(AppwriteConfig.endpoint)
      ..setProject(AppwriteConfig.projectId);

    _storageService = AppwriteStorageService(
      client: client,
      bucketId: AppwriteConfig.bucketId,
    );
  }

  Future<void> _pickFile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check if file size exceeds 25MB
        if (file.size > 25 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size exceeds 25MB limit'),
              backgroundColor: Color(0xFF1A237E),
            ),
          );
          return;
        }

        setState(() {
          _selectedFile = file;
          // Set the title to the filename if not already set
          if (_titleController.text.isEmpty) {
            _titleController.text = file.name;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          backgroundColor: const Color(0xFF1A237E),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _titleController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${_selectedFile!.name}');
      await tempFile.writeAsBytes(_selectedFile!.bytes!);

      // Use the original file name with extension
      final fileName = _selectedFile!.name;

      // Upload to Appwrite and Firestore
      final fileId = await _storageService.uploadFile(
        fileId: ID.unique(),
        filePath: tempFile.path,
        fileName: fileName, // Use the original file name
        folderId: _folderId,
        fileTitle: _titleController.text, // Pass the user-entered title
      );

      // Clean up temp file
      await tempFile.delete();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Color(0xFF1A237E),
        ),
      );

      // Navigate back
      Get.offAllNamed(
        AppRoutes.viewFiles,
        arguments: {
          'folderId': _folderId,
          'folderName':
              Get.arguments is Map && Get.arguments['folderName'] != null
                  ? Get.arguments['folderName']
                  : 'Files',
        },
      );
    } catch (e) {
      debugPrint('Error uploading file: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: ${e.toString()}'),
          backgroundColor: const Color(0xFF1A237E),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
                    const CustomBackButton(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: const Text(
                          'New File',
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
                    hintText: 'Enter file name',
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

                // File Upload Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _pickFile,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1A237E)),
                              )
                            else
                              Icon(
                                Icons.note_add_outlined,
                                size: 48,
                                color: Colors.green[400],
                              ),
                            const SizedBox(height: 12),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Click to Upload',
                                    style: TextStyle(
                                      color: Colors.green[400],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _selectedFile != null
                                  ? 'Selected: ${_selectedFile!.name}'
                                  : '(Max. File size: 25 MB)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Create File',
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
}
