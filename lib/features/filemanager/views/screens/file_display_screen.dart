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

  @override
  void initState() {
    super.initState();
    final client = Client()
      ..setEndpoint(AppwriteConfig.endpoint)
      ..setProject(AppwriteConfig.projectId);
    service = AppwriteStorageService(
      client: client,
      bucketId: AppwriteConfig.bucketId,
    );
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      // Fetch file metadata using Firestore
      List<FileModel> files =
          await service.listFiles(folderId: widget.folderId);
      fileModel = files.firstWhere(
        (f) => f.fileId == widget.fileId,
        orElse: () => throw Exception('File not found'),
      );

      // Download file bytes
      final url = await service.getFileDownload(widget.fileId, widget.folderId);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
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
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  bool _isImage(String ext) =>
      ['jpg', 'jpeg', 'png', 'gif'].contains(ext.toLowerCase());
  bool _isPdfLike(String ext) =>
      ['pdf', 'docx', 'pptx'].contains(ext.toLowerCase());
  bool _isHtml(String ext) => ext.toLowerCase() == 'html';

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('File Display')),
        body: Center(child: Text('Error: $error')),
      );
    }
    final ext = fileModel!.fileType.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(fileModel!.fileTitle),
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
      return Center(child: Image.memory(fileBytes!));
    } else if (_isPdfLike(ext)) {
      if (localFilePath == null) {
        return const Center(child: Text('PDF not available'));
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
      return Html(data: String.fromCharCodes(fileBytes!));
    } else {
      return const Center(child: Text('Unsupported file type for preview.'));
    }
  }
}
