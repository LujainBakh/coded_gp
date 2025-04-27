import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coded_gp/features/filemanager/models/file_model.dart';
import 'dart:io';

class AppwriteStorageService {
  final Storage _storage;
  final String bucketId;
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppwriteStorageService({
    required Client client,
    required this.bucketId,
  }) : _storage = Storage(client);

  Future<String> uploadFile({
    required String fileId,
    required String filePath,
    required String fileName,
    required String folderId,
  }) async {
    try {
      // Get file metadata
      final fileType = fileName.split('.').last.toLowerCase();
      final fileSize = File(filePath).lengthSync();
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('Attempting to upload file:');
      debugPrint('File ID: $fileId');
      debugPrint('File Name: $fileName');
      debugPrint('File Type: $fileType');
      debugPrint('File Size: $fileSize bytes');
      debugPrint('File Path: $filePath');
      debugPrint('Folder ID: $folderId');
      debugPrint('User ID: $userId');

      // Check if file exists
      if (!File(filePath).existsSync()) {
        throw Exception('File does not exist at path: $filePath');
      }

      // Upload to Appwrite storage
      try {
        final file = await _storage.createFile(
          bucketId: bucketId,
          fileId: fileId,
          file: InputFile.fromPath(
            path: filePath,
            filename: fileName,
          ),
        );
        debugPrint('File upload successful to Appwrite: ${file.$id}');
      } catch (e) {
        debugPrint('Appwrite upload error details:');
        debugPrint('Error type: ${e.runtimeType}');
        debugPrint('Error message: $e');
        if (e is AppwriteException) {
          debugPrint('Appwrite error code: ${e.code}');
          debugPrint('Appwrite error message: ${e.message}');
          debugPrint('Appwrite error type: ${e.type}');
        }
        rethrow;
      }

      // Get file download URL
      final fileUrl = _storage
          .getFileDownload(
            bucketId: bucketId,
            fileId: fileId,
          )
          .toString();

      debugPrint('File download URL: $fileUrl');

      // Create file model
      final fileModel = FileModel(
        fileId: fileId,
        fileName: fileName,
        fileSize: fileSize,
        fileType: fileType,
        fileUrl: fileUrl,
        uploadedAt: DateTime.now(),
        folderId: folderId,
      );

      // Save to Firebase
      try {
        // Save file metadata to the specific folder's files collection
        debugPrint(
            'Writing file metadata to: Users_DB/$userId/folders/$folderId/files/$fileId');
        debugPrint('File data: \\n${fileModel.toMap()}');
        await _firestore
            .collection('Users_DB')
            .doc(userId)
            .collection('folders')
            .doc(folderId)
            .collection('files')
            .doc(fileId)
            .set(fileModel.toMap());

        debugPrint('File metadata saved successfully to Firebase');
      } catch (e) {
        debugPrint('Error saving to Firebase: $e');
        // If Firebase save fails, we should delete the file from Appwrite
        try {
          await _storage.deleteFile(
            bucketId: bucketId,
            fileId: fileId,
          );
          debugPrint('Deleted file from Appwrite due to Firebase error');
        } catch (deleteError) {
          debugPrint('Error deleting file from Appwrite: $deleteError');
        }
        rethrow;
      }

      return fileId;
    } catch (e) {
      debugPrint('Error in uploadFile: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String fileId, String folderId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get file metadata from Firestore
      final fileDoc = await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .doc(fileId)
          .get();

      if (!fileDoc.exists) throw Exception('File not found');

      final fileModel = FileModel.fromMap(fileDoc.data()!);

      // Delete from Appwrite storage
      await _storage.deleteFile(
        bucketId: bucketId,
        fileId: fileModel.fileId,
      );

      // Delete from Firestore
      await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .doc(fileId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  Future<void> updateFileName(
      String fileId, String folderId, String newFileName) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get file metadata from Firestore
      final fileDoc = await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .doc(fileId)
          .get();

      if (!fileDoc.exists) throw Exception('File not found');

      final fileModel = FileModel.fromMap(fileDoc.data()!);
      final fileType = fileModel.fileType;

      // Update in Firestore
      await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .doc(fileId)
          .update({
        'fileName': '$newFileName.$fileType',
      });
    } catch (e) {
      debugPrint('Error updating file name: $e');
      rethrow;
    }
  }

  Future<String> getFileDownload(String fileId, String folderId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Get file metadata from Firestore
      final fileDoc = await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .doc(fileId)
          .get();

      if (!fileDoc.exists) throw Exception('File not found');

      final fileModel = FileModel.fromMap(fileDoc.data()!);

      // Get file download URL from Appwrite
      final result = await _storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileModel.fileId,
      );
      return result.toString();
    } catch (e) {
      debugPrint('Error getting file download: $e');
      rethrow;
    }
  }

  Future<List<FileModel>> listFiles({required String folderId}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      debugPrint('Fetching files for folder: $folderId');

      final querySnapshot = await _firestore
          .collection('Users_DB')
          .doc(userId)
          .collection('folders')
          .doc(folderId)
          .collection('files')
          .get();

      debugPrint('Found ${querySnapshot.docs.length} files');

      final files = querySnapshot.docs
          .where((doc) =>
              doc.data().containsKey('fileId')) // Only include real files
          .map((doc) {
        debugPrint('Processing file: \\n${doc.data()}');
        return FileModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      debugPrint('Successfully converted ${files.length} files to FileModel');
      return files;
    } catch (e) {
      debugPrint('Error listing files: $e');
      rethrow;
    }
  }
}
