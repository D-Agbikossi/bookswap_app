import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostBookScreen extends StatefulWidget {
  const PostBookScreen({super.key});
  @override
  _PostBookScreenState createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String condition = 'Good';
  File? _file;
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

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
    if (x != null) {
      setState(() => _file = File(x.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksProv = Provider.of<BooksProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final storage = StorageService();

    return Scaffold(
      appBar: AppBar(title: Text('Post a Book')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                label: Text('Pick Cover Image'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          try {
                            final bookData = {
                              'ownerId': authProv.firebaseUser!.uid,
                              'title': _title.text.trim(),
                              'author': _author.text.trim(),
                              'condition': condition,
                              'coverUrl': '',
                              'isAvailable': true,
                              'createdAt': FieldValue.serverTimestamp(),
                            };
                            final id = await booksProv.createBook(bookData);
                            if (_file != null) {
                              final url = await storage.uploadBookCover(id, _file!);
                              await booksProv.updateBook(id, {'coverUrl': url});
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text('Book posted successfully!'),
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
                                        child: Text('Failed to post book. Please try again.'),
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
                    : Text('Post Listing', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
