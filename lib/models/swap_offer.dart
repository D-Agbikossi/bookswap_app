import 'package:cloud_firestore/cloud_firestore.dart';

class SwapOffer {
  final String id;
  final String bookId;
  final String senderId;
  final String receiverId;
  final String status; // pending, accepted, rejected
  final Timestamp createdAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory SwapOffer.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SwapOffer(
      id: doc.id,
      bookId: d['bookId'] ?? '',
      senderId: d['senderId'] ?? '',
      receiverId: d['receiverId'] ?? '',
      status: d['status'] ?? 'pending',
      createdAt: d['createdAt'] ?? Timestamp.now(),
    );
  }
}
