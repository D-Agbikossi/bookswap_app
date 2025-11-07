import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBookCover(String bookId, File file) async {
    final ref = _storage.ref().child('book_covers/$bookId.jpg');
    final uploadTask = ref.putFile(file);
    final snap = await uploadTask;
    final url = await snap.ref.getDownloadURL();
    return url;
  }
}
