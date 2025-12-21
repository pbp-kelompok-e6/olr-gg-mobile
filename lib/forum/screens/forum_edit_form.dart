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
    _title = widget.forum.title;
    _category = widget.forum.category;
    _content = widget.forum.content;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white, 
    appBar: AppBar(
        title: const Text(
          'Edit Discussion', 
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (val) => setState(() => _title = val),
                validator: (val) => val!.isEmpty ? "Title cannot be empty" : null,
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
                initialValue: _content,
                maxLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (val) => setState(() => _content = val),
                validator: (val) => val!.isEmpty ? "Description cannot be empty" : null,
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
                        final response = await request.postJson(
                            "http://localhost:8000/forum/ajax/edit-post/${widget.forum.id}/",
                            jsonEncode({"title": _title, "content": _content, "category": _category}),
                        );
                        if (context.mounted && response['status'] == 'success') {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForumEntryListPage()));
                        }
                    }
                  },
                  child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}