import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../models/message.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = Uuid();

  // Books
  Stream<List<Book>> browseBooksStream() {
    return _db
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromDoc(d)).toList());
  }

  Future<String> createBook(Map<String, dynamic> data) async {
    final doc = await _db.collection('books').add(data);
    return doc.id;
  }

  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    await _db.collection('books').doc(id).update(data);
  }

  Future<void> deleteBook(String id) async {
    await _db.collection('books').doc(id).delete();
  }

  // Swaps
  Stream<List<SwapOffer>> myOffersStream(String userId) {
    return _db
        .collection('swaps')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => SwapOffer.fromDoc(d)).toList());
  }

  Stream<List<SwapOffer>> sentOffersStream(String userId) {
    return _db
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => SwapOffer.fromDoc(d)).toList());
  }

  Future<String> createSwap(
    String bookId,
    String senderId,
    String receiverId,
  ) async {
    final id = _uuid.v4();
    final data = {
      'bookId': bookId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('swaps').doc(id).set(data);
    // mark book as unavailable
    await _db.collection('books').doc(bookId).update({'isAvailable': false});
    return id;
  }

  Future<void> updateSwapStatus(String swapId, String status) async {
    await _db.collection('swaps').doc(swapId).update({'status': status});
    final swapDoc = await _db.collection('swaps').doc(swapId).get();
    final bookId = (swapDoc.data() ?? {})['bookId'];
    if (status == 'rejected') {
      if (bookId != null) {
        await _db.collection('books').doc(bookId).update({'isAvailable': true});
      }
    }
    if (status == 'accepted') {
      // optional: keep unavailable
    }
  }

  // Get all swaps for a user (both sent and received) to show chats
  Stream<List<SwapOffer>> userSwapsStream(String userId) {
    return _db
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => SwapOffer.fromDoc(d)).toList());
  }

  // Chats (simple chat per swap)
  Stream<List<Message>> chatMessagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((s) => s.docs.map((d) => Message.fromDoc(d)).toList());
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final data = {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('chats').doc(chatId).collection('messages').add(data);
  }
}
