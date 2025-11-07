import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBookCover(String bookId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('book_covers/$bookId.jpg');
      
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // For web, convert XFile to Uint8List
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // For mobile platforms, use File
        final file = File(imageFile.path);
        if (!await file.exists()) {
          throw Exception('Image file does not exist');
        }
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      // Monitor upload progress
      final snap = await uploadTask;
      
      // Wait for upload to complete
      if (snap.state != TaskState.success) {
        throw Exception('Upload did not complete successfully. State: ${snap.state}');
      }
      
      // Get download URL
      final url = await snap.ref.getDownloadURL();
      
      if (url.isEmpty) {
        throw Exception('Download URL is empty after upload');
      }
      
      return url;
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        throw Exception('Storage permission denied. Please check Firebase Storage rules.');
      } else if (e.code == 'canceled') {
        throw Exception('Upload was canceled');
      } else if (e.code == 'unknown') {
        throw Exception('Unknown error occurred during upload');
      } else {
        throw Exception('Upload failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}
