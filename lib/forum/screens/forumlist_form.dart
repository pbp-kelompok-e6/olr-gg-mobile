import 'package:flutter/material.dart';
import 'package:olrggmobile/widgets/left_drawer.dart'; // Import Drawer
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/forum/screens/forum_entry_list.dart';

class ForumFormPage extends StatefulWidget {
  const ForumFormPage({super.key});

  @override
  State<ForumFormPage> createState() => _ForumFormPageState();
}

class _ForumFormPageState extends State<ForumFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _category = "football";
  String _content = "";

  final List<String> _categories = [
    'soccer', 
    'football', 
    'basketball', 
    'volleyball', 
    'hockey', 
    'baseball',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Buat Diskusi Baru'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      // INI YANG KAMU MINTA:
      drawer: const LeftDrawer(), 
      
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              TextFormField(
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
                        // [DEBUG] Cek apakah tombol terpencet
                        print("Tombol ditekan, mengirim request...");

                        try {
                            final response = await request.postJson(
                                "http://localhost:8000/forum/ajax/create-post/",
                                jsonEncode({
                                    "title": _title,
                                    "content": _content,
                                    "category": _category,
                                }),
                            );

                            // [DEBUG] Cek response dari server
                            print("Response server: $response");

                            if (context.mounted) {
                                if (response['status'] == 'success') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Diskusi berhasil dibuat!")),
                                    );
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ForumEntryListPage()),
                                    );
                                } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Gagal membuat diskusi.")),
                                    );
                                }
                            }
                        } catch (e) {
                            // [DEBUG] Tangkap error koneksi/server
                            print("Terjadi Error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                            );
                        }
                    }
                },
                  child: const Text("Posting Diskusi", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}