import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/swaps_provider.dart';
import '../widgets/book_tile.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import 'post_book_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BooksProvider>(context);
    final user = Provider.of<AuthProvider>(context).firebaseUser;
    final swaps = Provider.of<SwapsProvider>(context);

    final myBooks = books.browseBooks
        .where((b) => b.ownerId == user?.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Listings', icon: Icon(Icons.book)),
            Tab(text: 'My Offers', icon: Icon(Icons.swap_horiz)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/post'),
        child: Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Listings Tab
          myBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No listings yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first book!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: myBooks
                      .map(
                        (b) => BookTile(
                          book: b,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => Navigator.pushNamed(
                                    context, '/edit',
                                    arguments: b),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => books.deleteBook(b.id),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
          // My Offers Tab
          swaps.myReceived.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No swap offers yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'When someone requests to swap your book,\nit will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: swaps.myReceived.length,
                  itemBuilder: (context, index) {
                    final offer = swaps.myReceived[index];
                    final book = books.browseBooks
                        .firstWhere((b) => b.id == offer.bookId,
                            orElse: () => Book(
                                  id: offer.bookId,
                                  ownerId: offer.receiverId,
                                  title: 'Loading...',
                                  author: '',
                                  condition: 'Used',
                                  coverUrl: '',
                                  isAvailable: false,
                                  createdAt: Timestamp.now(),
                                ));
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: ListTile(
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${book.author} • ${book.condition}'),
                            SizedBox(height: 4),
                            Chip(
                              label: Text(
                                offer.status.toUpperCase(),
                                style: TextStyle(fontSize: 10),
                              ),
                              backgroundColor: offer.status == 'pending'
                                  ? Colors.orange[100]
                                  : offer.status == 'accepted'
                                      ? Colors.green[100]
                                      : Colors.red[100],
                            ),
                          ],
                        ),
                        trailing: offer.status == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () async {
                                      await swaps.updateSwapStatus(
                                          offer.id, 'accepted');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Swap accepted!')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () async {
                                      await swaps.updateSwapStatus(
                                          offer.id, 'rejected');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Swap rejected')),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
