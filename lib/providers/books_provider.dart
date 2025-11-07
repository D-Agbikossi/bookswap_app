import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';

class BooksProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  List<Book> browseBooks = [];

  BooksProvider() {
    _fs.browseBooksStream().listen((list) {
      browseBooks = list;
      notifyListeners();
    });
  }

  Future<String> createBook(Map<String, dynamic> data) => _fs.createBook(data);
  Future<void> updateBook(String id, Map<String, dynamic> data) =>
      _fs.updateBook(id, data);
  Future<void> deleteBook(String id) => _fs.deleteBook(id);
}
