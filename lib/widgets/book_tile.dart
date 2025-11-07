import 'package:flutter/material.dart';
import '../models/book.dart';

class BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BookTile({super.key, required this.book, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        onTap: onTap,
        leading: book.coverUrl.isNotEmpty
            ? Image.network(
                book.coverUrl,
                width: 48,
                height: 64,
                fit: BoxFit.cover,
              )
            : Container(width: 48, height: 64, color: Colors.grey[300]),
        title: Text(book.title),
        subtitle: Text('${book.author} • ${book.condition}'),
        trailing: trailing,
      ),
    );
  }
}
