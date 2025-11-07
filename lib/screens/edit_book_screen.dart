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
  final ImagePicker _picker = ImagePicker();
  Book? _book;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _author = TextEditingController();
    condition = 'Good';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Book) {
        _book = args;
        _title.text = _book!.title;
        _author.text = _book!.author;
        condition = _book!.condition;
        _initialized = true;
      }
    }
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
    if (!_initialized || _book == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Listing')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final booksProv = Provider.of<BooksProvider>(context, listen: false);
    final storage = StorageService();

    return Scaffold(
      appBar: AppBar(title: Text('Edit Listing')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _author,
              decoration: InputDecoration(
                labelText: 'Author *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an author';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: condition,
              decoration: InputDecoration(
                labelText: 'Condition',
                prefixIcon: Icon(Icons.star),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => condition = v!),
              items: [
                'New',
                'Like New',
                'Good',
                'Used',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            ),
            SizedBox(height: 24),
            Text(
              'Book Cover',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_file!, height: 200, fit: BoxFit.cover),
                  )
                : _book!.coverUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _book!.coverUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(Icons.broken_image,
                                    size: 48, color: Colors.grey[400]),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 48, color: Colors.grey[400]),
                            SizedBox(height: 8),
                            Text(
                              'No image selected',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('Change Cover Image'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (_title.text.trim().isEmpty ||
                          _author.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => loading = true);
                      try {
                        final updates = {
                          'title': _title.text.trim(),
                          'author': _author.text.trim(),
                          'condition': condition,
                        };
                        await booksProv.updateBook(_book!.id, updates);
                        if (_file != null) {
                          final url =
                              await storage.uploadBookCover(_book!.id, _file!);
                          await booksProv.updateBook(
                              _book!.id, {'coverUrl': url});
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Book updated successfully!'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                        'Failed to update book. Please try again.'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => loading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
