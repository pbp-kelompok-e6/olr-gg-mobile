import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/forum/models/forum_entry.dart';

class ForumEditDialog extends StatefulWidget {
  final ForumEntry forum;

  const ForumEditDialog({super.key, required this.forum});

  @override
  State<ForumEditDialog> createState() => _ForumEditDialogState();
}

class _ForumEditDialogState extends State<ForumEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _category;
  late String _content;

  final List<String> _categories = [
    'soccer',
    'football',
    'basketball',
    'volleyball',
    'hockey',
    'baseball',
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

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ), // Batasi lebar agar mirip web
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                const Center(
                  child: Text(
                    'Edit Discussion',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Abu gelap
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title Input
                _buildLabel("Title"),
                TextFormField(
                  initialValue: _title,
                  decoration: _inputDecoration(),
                  onChanged: (val) => setState(() => _title = val),
                  validator: (val) =>
                      val!.isEmpty ? "Title cannot be empty" : null,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                _buildLabel("Category"),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration(),
                  value: _categories.contains(_category)
                      ? _category
                      : _categories.first,
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat[0].toUpperCase() + cat.substring(1)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),

                // Description Input
                _buildLabel("Description"),
                TextFormField(
                  initialValue: _content,
                  maxLines: 5,
                  decoration: _inputDecoration(),
                  onChanged: (val) => setState(() => _content = val),
                  validator: (val) =>
                      val!.isEmpty ? "Description cannot be empty" : null,
                ),
                const SizedBox(height: 32),

                // Action Buttons (Save & Cancel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await request.postJson(
                            "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id//forum/ajax/edit-post/${widget.forum.id}/",
                            jsonEncode({
                              "title": _title,
                              "content": _content,
                              "category": _category,
                            }),
                          );
                          if (context.mounted &&
                              response['status'] == 'success') {
                            Navigator.pop(context, true); // Kirim sinyal sukses
                          }
                        }
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ), // Merah saat fokus
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}
