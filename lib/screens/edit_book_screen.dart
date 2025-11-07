import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';
import '../services/storage_service.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key});
  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late final TextEditingController _title;
  late final TextEditingController _author;
  late String condition;
  File? _file;
  bool loading = false;
  bool _initialized = false;
  final ImagePicker _picker = ImagePicker();
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = ModalRoute.of(context)!.settings.arguments as Book;
    _title = TextEditingController(text: _book.title);
    _author = TextEditingController(text: _book.author);
    condition = _book.condition;
    _initialized = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final XFile? x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (x != null) setState(() => _file = File(x.path));
  }

  @override
  Widget build(BuildContext context) {

    final booksProv = Provider.of<BooksProvider>(context, listen: false);
    final storage = StorageService();

    return Scaffold(
      appBar: AppBar(title: Text('Edit Listing')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _author,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            DropdownButton<String>(
              value: condition,
              onChanged: (v) => setState(() => condition = v!),
              items: [
                'New',
                'Like New',
                'Good',
                'Used',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            ),
            SizedBox(height: 10),
            _file != null
                ? Image.file(_file!, height: 120)
                : _book.coverUrl.isNotEmpty
                    ? Image.network(_book.coverUrl, height: 120)
                    : Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: Center(child: Text('No image')),
                      ),
            ElevatedButton(onPressed: pickImage, child: Text('Change Cover')),
            ElevatedButton(
              onPressed: () async {
                setState(() => loading = true);
                final updates = {
                  'title': _title.text.trim(),
                  'author': _author.text.trim(),
                  'condition': condition,
                };
                await booksProv.updateBook(_book.id, updates);
                if (_file != null) {
                  final url = await storage.uploadBookCover(_book.id, _file!);
                  await booksProv.updateBook(_book.id, {'coverUrl': url});
                }
                setState(() => loading = false);
                Navigator.pop(context);
              },
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
