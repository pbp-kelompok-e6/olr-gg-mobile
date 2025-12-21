import 'package:flutter/material.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
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
    'soccer', 'football', 'basketball', 'volleyball', 'hockey', 'baseball',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
    appBar: AppBar(
        title: const Text(
          'Create New Discussion', 
          style: TextStyle(color: Colors.grey) 
        ),
        backgroundColor: Colors.black, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey), 
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1), 
          child: Container(color: Colors.grey[800], height: 1)
        ),
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (val) => setState(() => _title = val),
                validator: (val) => val == null || val.isEmpty ? "Title cannot be empty!" : null,
              ),
              const SizedBox(height: 20),

              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                value: _category,
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 20),

              const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "Share your thoughts...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (val) => setState(() => _content = val),
                validator: (val) => val == null || val.isEmpty ? "Description cannot be empty!" : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600], 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                        try {
                            final response = await request.postJson(
                                "http://localhost:8000/forum/ajax/create-post/",
                                jsonEncode({"title": _title, "content": _content, "category": _category}),
                            );
                            if (context.mounted && response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Forum created successfully!")));
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForumEntryListPage()));
                            }
                        } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                    }
                  },
                  child: const Text("Post Forum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}