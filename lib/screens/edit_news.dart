import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/models/news_entry.dart';
import 'package:olrggmobile/screens/news_entry_list.dart';

class EditNewsPage extends StatefulWidget {
  final NewsEntry news;

  const EditNewsPage({super.key, required this.news});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _content;
  String? _category;
  late String _thumbnail;
  late bool _isFeatured;

  final List<String> _categories = [
    'basketball',
    'volleyball',
    'football',
    'baseball',
    'hockey',
    'soccer',
  ];

  InputDecoration inputStyle(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _title = widget.news.title;
    _content = widget.news.content;
    _category = widget.news.category.isNotEmpty ? widget.news.category : null;
    _thumbnail = widget.news.thumbnail;
    _isFeatured = widget.news.isFeatured;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit News"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Edit News",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Update your news and share with the community",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 32),

                      TextFormField(
                        initialValue: _title,
                        decoration: inputStyle("Title", "Enter news title"),
                        validator: (v) =>
                        (v == null || v.isEmpty) ? "Title cannot be empty" : null,
                        onChanged: (v) => _title = v,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: _content,
                        maxLines: 5,
                        decoration: inputStyle("Content", "Enter news content"),
                        validator: (v) =>
                        (v == null || v.isEmpty) ? "Content cannot be empty" : null,
                        onChanged: (v) => _content = v,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: inputStyle("Category", "Choose a category"),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              "Choose a category",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ..._categories.map(
                                (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c[0].toUpperCase() + c.substring(1)),
                            ),
                          ),
                        ],
                        validator: (v) =>
                        v == null ? "Choose Category" : null,
                        onChanged: (v) {
                          setState(() {
                            _category = v;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: _thumbnail,
                        decoration: inputStyle(
                          "Thumbnail URL",
                          "https://example.com/image.jpg",
                        ),
                        onChanged: (v) => _thumbnail = v,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.2,
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "Featured News",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: _isFeatured,
                          activeThumbColor: Colors.blue.shade700,
                          activeTrackColor: Colors.blue.shade200,
                          inactiveThumbColor: Colors.grey.shade700,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (val) {
                            setState(() {
                              _isFeatured = val;
                            });
                          },
                        ),
                      ),
                      const Divider(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                final response = await request.postJson(
                                  "http://localhost:8000/news/${widget.news.id}/edit-flutter/",
                                  jsonEncode({
                                    "title": _title,
                                    "content": _content,
                                    "category": _category,
                                    "thumbnail": _thumbnail,
                                    "is_featured": _isFeatured,
                                  }),
                                );

                                if (context.mounted) {
                                  if (response["status"] == "success") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Berita berhasil diedit!")),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => NewsEntryListPage()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Gagal mengedit, coba lagi.")),
                                    );
                                  }
                                }
                              },
                              child: const Text("Save"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}