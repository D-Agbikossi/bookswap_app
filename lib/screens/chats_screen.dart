import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chats_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/swaps_provider.dart';
import '../providers/books_provider.dart';
import '../models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String? selectedChatId;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final swaps = Provider.of<SwapsProvider>(context);
    final books = Provider.of<BooksProvider>(context);
    final cp = Provider.of<ChatsProvider>(context, listen: false);
    final userId = auth.firebaseUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chats')),
        body: Center(child: Text('Please log in to view chats')),
      );
    }

    // Combine sent and received swaps to show all chats
    final allSwaps = [...swaps.mySent, ...swaps.myReceived];

    if (selectedChatId == null) {
      // Show list of chats (swaps)
      return Scaffold(
        appBar: AppBar(title: Text('Chats')),
        body: allSwaps.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No chats yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start a swap to begin chatting!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: allSwaps.length,
                itemBuilder: (context, index) {
                  final swap = allSwaps[index];
                  final book = books.browseBooks.firstWhere(
                    (b) => b.id == swap.bookId,
                    orElse: () => Book(
                      id: swap.bookId,
                      ownerId: swap.receiverId,
                      title: 'Book',
                      author: '',
                      condition: 'Used',
                      coverUrl: '',
                      isAvailable: false,
                      createdAt: Timestamp.now(),
                    ),
                  );
                  final isSender = swap.senderId == userId;

                  return ListTile(
                    leading: book.coverUrl.isNotEmpty
                        ? Image.network(
                            book.coverUrl,
                            width: 48,
                            height: 64,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48,
                            height: 64,
                            color: Colors.grey[300],
                          ),
                    title: Text(book.title),
                    subtitle: Text(
                      'Swap ${swap.status} • ${isSender ? "You offered" : "You received"}',
                    ),
                    trailing: Chip(
                      label: Text(swap.status.toUpperCase()),
                      backgroundColor: swap.status == 'pending'
                          ? Colors.orange[100]
                          : swap.status == 'accepted'
                              ? Colors.green[100]
                              : Colors.red[100],
                    ),
                    onTap: () {
                      setState(() {
                        selectedChatId = swap.id;
                      });
                    },
                  );
                },
              ),
      );
    }

    // Show chat messages for selected swap
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedChatId = null;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: cp.messagesStream(selectedChatId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final msgs = snapshot.data!;
                if (msgs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: msgs.length,
                  itemBuilder: (c, i) {
                    final m = msgs[i];
                    final mine = m.senderId == userId;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: mine ? Colors.blue[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(color: mine ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (_messageController.text.trim().isEmpty) return;
                      await cp.sendMessage(
                        selectedChatId!,
                        userId,
                        _messageController.text.trim(),
                      );
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
