import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/forum/models/forum_entry.dart';
import 'package:olrggmobile/forum/screens/forum_entry_list.dart';

class ForumEditPage extends StatefulWidget {
  final ForumEntry forum;

  const ForumEditPage({super.key, required this.forum});

  @override
  State<ForumEditPage> createState() => _ForumEditPageState();
}

class _ForumEditPageState extends State<ForumEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _category;
  late String _content;

  final List<String> _categories = [
    'soccer', 'football', 'basketball', 'volleyball', 'hockey', 'baseball',
  ];

  @override
  void initState() {
    super.initState();
    // Isi form dengan data lama
    _title = widget.forum.title;
    _category = widget.forum.category;
    _content = widget.forum.content;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Edit Diskusi'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: "Judul Diskusi",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onChanged: (String? value) {
                  setState(() { _title = value!; });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) return "Judul tidak boleh kosong!";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Kategori",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                value: _category,
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat[0].toUpperCase() + cat.substring(1)),
                )).toList(),
                onChanged: (String? newValue) {
                  setState(() { _category = newValue!; });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _content,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: "Isi Diskusi",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  alignLabelWithHint: true,
                ),
                onChanged: (String? value) {
                  setState(() { _content = value!; });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) return "Isi tidak boleh kosong!";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                        // URL Edit sesuai views.py
                        final response = await request.postJson(
                            "http://localhost:8000/forum/ajax/edit-post/${widget.forum.id}/",
                            jsonEncode({
                                "title": _title,
                                "content": _content,
                                "category": _category,
                            }),
                        );

                        if (context.mounted) {
                            if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Diskusi berhasil diupdate!")),
                                );
                                // Kembali ke list dan refresh
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ForumEntryListPage()),
                                );
                            } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Gagal update diskusi.")),
                                );
                            }
                        }
                    }
                },
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}