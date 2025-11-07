import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../widgets/book_tile.dart';
import '../models/book.dart';
import '../providers/auth_provider.dart';
import '../providers/swaps_provider.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final Map<String, bool> _loadingSwaps = {};

  @override
  Widget build(BuildContext context) {
    final booksProv = Provider.of<BooksProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final swapsProv = Provider.of<SwapsProvider>(context, listen: false);

    // Filter available books (show user's own books even if unavailable)
    final availableBooks = booksProv.browseBooks.where((b) {
      return b.isAvailable || b.ownerId == authProv.firebaseUser?.uid;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Browse Listings')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/post'),
      ),
      body: availableBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No books available yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to post a book!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: availableBooks.length,
              itemBuilder: (context, i) {
                final Book b = availableBooks[i];
                final isLoading = _loadingSwaps[b.id] ?? false;
                final isOwnBook = b.ownerId == authProv.firebaseUser?.uid;

                return BookTile(
                  book: b,
                  trailing: !isOwnBook
                      ? isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: b.isAvailable
                                  ? () async {
                                      setState(() {
                                        _loadingSwaps[b.id] = true;
                                      });
                                      try {
                                        final sender = authProv.firebaseUser!.uid;
                                        await swapsProv.createSwap(
                                            b.id, sender, b.ownerId);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                        'Swap request sent!'),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.error_outline,
                                                      color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                        'Failed to send swap request. Please try again.'),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _loadingSwaps[b.id] = false;
                                          });
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: b.isAvailable
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(b.isAvailable ? 'Swap' : 'Unavailable'),
                            )
                      : null,
                  onTap: () {},
                );
              },
            ),
    );
  }
}
