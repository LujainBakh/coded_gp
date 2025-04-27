import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String fileId;
  final String fileName;
  final int fileSize;
  final String fileType;
  final String fileUrl;
  final DateTime uploadedAt;
  final String folderId;

  FileModel({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.fileUrl,
    required this.uploadedAt,
    required this.folderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt,
      'folderId': folderId,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      fileId: map['fileId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedAt: map['uploadedAt'] != null
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      folderId: map['folderId'] ?? '',
    );
  }
}
