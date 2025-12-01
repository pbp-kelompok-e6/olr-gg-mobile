import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
  late String _category;
  late String _thumbnail;
  late bool _isFeatured;

  final List<String> _categories = [
    'basketball',
    'baseball',
    'football',
    'volleyball',
    'hockey',
    'soccer',
  ];

  @override
  void initState() {
    super.initState();

    // preload data lama
    _title = widget.news.title;
    _content = widget.news.content;
    _category = widget.news.category;
    _thumbnail = widget.news.thumbnail;
    _isFeatured = widget.news.isFeatured;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        title: const Text(
          "Edit Berita",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [

              // TITLE
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: "Judul",
                  filled: true,
                ),
                onChanged: (v) => _title = v,
                validator: (v) =>
                (v == null || v.isEmpty) ? "Judul tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              // CONTENT
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(
                  labelText: "Konten",
                  filled: true,
                ),
                maxLines: 5,
                onChanged: (v) => _content = v,
                validator: (v) =>
                (v == null || v.isEmpty) ? "Konten tidak boleh kosong" : null,
              ),
              const SizedBox(height: 12),

              // CATEGORY
              DropdownButtonFormField(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c[0].toUpperCase() + c.substring(1)),
                ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _category = v!);
                },
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),

              // THUMBNAIL
              TextFormField(
                initialValue: _thumbnail,
                decoration: const InputDecoration(
                  labelText: "Thumbnail URL",
                  filled: true,
                ),
                onChanged: (v) => _thumbnail = v,
              ),
              const SizedBox(height: 12),

              // FEATURED SWITCH
              SwitchListTile(
                title: const Text("Featured"),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              const SizedBox(height: 16),

              // SUBMIT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
                        const SnackBar(
                            content: Text("Gagal mengedit, coba lagi.")),
                      );
                    }
                  }
                },
                child: const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
