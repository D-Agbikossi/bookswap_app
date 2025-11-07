import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String ownerId;
  final String title;
  final String author;
  final String condition; // New | Like New | Good | Used
  final String coverUrl;
  final bool isAvailable;
  final Timestamp createdAt;

  Book({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.author,
    required this.condition,
    required this.coverUrl,
    required this.isAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'author': author,
      'condition': condition,
      'coverUrl': coverUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }

  factory Book.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      ownerId: d['ownerId'] ?? '',
      title: d['title'] ?? '',
      author: d['author'] ?? '',
      condition: d['condition'] ?? 'Used',
      coverUrl: d['coverUrl'] ?? '',
      isAvailable: d['isAvailable'] ?? true,
      createdAt: d['createdAt'] ?? Timestamp.now(),
    );
  }
}
