import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/swap_offer.dart';

class SwapsProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  List<SwapOffer> myReceived = [];
  List<SwapOffer> mySent = [];
  StreamSubscription<List<SwapOffer>>? _receivedSubscription;
  StreamSubscription<List<SwapOffer>>? _sentSubscription;
  String? _boundUserId;

  void bind(String userId) {
    // Only bind if not already bound to this user
    if (_boundUserId == userId) return;
    
    // Cancel existing subscriptions
    _receivedSubscription?.cancel();
    _sentSubscription?.cancel();
    
    _boundUserId = userId;
    
    _receivedSubscription = _fs.myOffersStream(userId).listen((list) {
      myReceived = list;
      notifyListeners();
    });
    
    _sentSubscription = _fs.sentOffersStream(userId).listen((list) {
      mySent = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _receivedSubscription?.cancel();
    _sentSubscription?.cancel();
    super.dispose();
  }

  Future<String> createSwap(
    String bookId,
    String senderId,
    String receiverId,
  ) => _fs.createSwap(bookId, senderId, receiverId);

  Future<void> updateSwapStatus(String swapId, String status) =>
      _fs.updateSwapStatus(swapId, status);
}
