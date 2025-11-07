import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';

class ChatsProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  // For simplicity we don't maintain many chat lists here; streaming per chat is done in screen.
  Stream<List<Message>> messagesStream(String chatId) =>
      _fs.chatMessagesStream(chatId);
  Future<void> sendMessage(String chatId, String senderId, String text) =>
      _fs.sendMessage(chatId, senderId, text);
}
