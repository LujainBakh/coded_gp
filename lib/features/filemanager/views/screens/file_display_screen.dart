import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:coded_gp/features/filemanager/services/appwrite_storage_service.dart';
import 'package:coded_gp/features/filemanager/models/file_model.dart';
import 'package:appwrite/appwrite.dart';
import 'package:coded_gp/core/config/appwrite_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FileDisplayScreen extends StatefulWidget {
  final String fileId;
  final String folderId;

  const FileDisplayScreen({
    super.key,
    required this.fileId,
    required this.folderId,
  });

  @override
  State<FileDisplayScreen> createState() => _FileDisplayScreenState();
}

class _FileDisplayScreenState extends State<FileDisplayScreen> {
  FileModel? fileModel;
  Uint8List? fileBytes;
  String? localFilePath;
  bool isLoading = true;
  String? error;
  late AppwriteStorageService service;
  int? totalPages;
  int? currentPage;
  bool pdfReady = false;
  late Client _client;

  @override
  void initState() {
    super.initState();
    _client = Client()
      ..setEndpoint(AppwriteConfig.endpoint)
      ..setProject(AppwriteConfig.projectId);
    service = AppwriteStorageService(
      client: _client,
      bucketId: AppwriteConfig.bucketId,
    );
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Fetch file metadata
      List<FileModel> files =
          await service.listFiles(folderId: widget.folderId);
      fileModel = files.firstWhere(
        (f) => f.fileId == widget.fileId,
        orElse: () => throw Exception('File not found'),
      );

      // Get download URL and download file
      final downloadUrl =
          await service.getFileDownload(widget.fileId, widget.folderId);

      // Ensure the URL is properly formatted
      if (!downloadUrl.startsWith('http')) {
        throw Exception('Invalid download URL format');
      }

      debugPrint('Downloading file from URL: $downloadUrl');

      // Get the current user's ID token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();

      // Make the request with proper headers
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'X-Appwrite-Project': AppwriteConfig.projectId,
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      fileBytes = response.bodyBytes;

      // For PDF, DOCX, PPTX: Save to local file for PDFView
      if (_isPdfLike(fileModel!.fileType)) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${fileModel!.fileName}';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes!);
        localFilePath = filePath;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading file: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  bool _isImage(String ext) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(ext.toLowerCase());
  }

  bool _isPdfLike(String ext) {
    final pdfExtensions = ['pdf', 'docx', 'pptx', 'doc', 'ppt'];
    return pdfExtensions.contains(ext.toLowerCase());
  }

  bool _isHtml(String ext) => ext.toLowerCase() == 'html';

  bool _isText(String ext) {
    final textExtensions = ['txt', 'md', 'json', 'xml', 'csv'];
    return textExtensions.contains(ext.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final ext = fileModel!.fileType.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(fileModel!.fileTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isPdfLike(ext) && totalPages != null && currentPage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$currentPage / $totalPages'),
              ),
            ),
        ],
      ),
      body: _buildFileView(ext),
    );
  }

  Widget _buildFileView(String ext) {
    if (_isImage(ext)) {
      return Center(
        child: InteractiveViewer(
          child: Image.memory(
            fileBytes!,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (_isPdfLike(ext)) {
      if (localFilePath == null) {
        return const Center(child: Text('File not available'));
      }
      return PDFView(
        filePath: localFilePath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        defaultPage: currentPage ?? 0,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        onRender: (pages) {
          setState(() {
            totalPages = pages;
            pdfReady = true;
          });
        },
        onError: (error) {
          setState(() {
            this.error = error.toString();
          });
        },
        onPageError: (page, error) {
          setState(() {
            this.error = 'Error on page $page: ${error.toString()}';
          });
        },
        onPageChanged: (page, total) {
          setState(() {
            currentPage = page;
            if (total != null) {
              totalPages = total;
            }
          });
        },
      );
    } else if (_isHtml(ext)) {
      return SingleChildScrollView(
        child: Html(data: String.fromCharCodes(fileBytes!)),
      );
    } else if (_isText(ext)) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          String.fromCharCodes(fileBytes!),
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, size: 64),
            const SizedBox(height: 16),
            const Text(
              'File Preview Not Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'File type: ${ext.toUpperCase()}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement download functionality here
              },
              child: const Text('Download File'),
            ),
          ],
        ),
      );
    }
  }
}
