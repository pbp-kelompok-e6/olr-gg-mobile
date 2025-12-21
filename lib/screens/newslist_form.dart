import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/screens/menu.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _content = "";
  String? _category;
  String _thumbnail = "";
  bool _isFeatured = false;

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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Create News"),
        foregroundColor: Colors.grey,
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),

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
                        "Create News",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Share your football news and stories with the community",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Divider(height: 32),
                      TextFormField(
                        decoration: inputStyle("Title", "Enter news title"),
                        validator: (value) => value == null || value.isEmpty
                            ? "Title cannot be empty"
                            : null,
                        onChanged: (value) => _title = value,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        maxLines: 5,
                        decoration: inputStyle("Content", "Enter news content"),
                        validator: (value) => value == null || value.isEmpty
                            ? "Content cannot be empty"
                            : null,
                        onChanged: (value) => _content = value,
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
                        validator: (value) {
                          if (value == null) {
                            return "Choose Category";
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _category = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: inputStyle(
                          "Thumbnail URL",
                          "https://example.com/image.jpg",
                        ),
                        onChanged: (value) => _thumbnail = value,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1.2),
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
                                foregroundColor: Colors.black,
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final response = await request.postJson(
                                    "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/create-flutter/",
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "News successfully published",
                                          ),
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MyHomePage(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Failed to publish news",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: const Text("Publish News"),
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
