import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:olrggmobile/forum/models/forum_entry.dart';
import 'package:olrggmobile/forum/models/forum_comment.dart'; // Pastikan import model comment
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/forum/screens/forum_edit_form.dart';
import 'package:olrggmobile/forum/screens/forum_entry_list.dart';

// Ubah menjadi StatefulWidget agar bisa refresh state komentar
class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;

  const ForumDetailPage({super.key, required this.forum});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  Future<List<ForumComment>> fetchComments(CookieRequest request) async {
    // Ganti localhost dengan IP jika di emulator Android (misal 10.0.2.2)
    final response = await request.get('http://localhost:8000/forum/json/comments/${widget.forum.id}/');
    
    List<ForumComment> listComments = [];
    for (var d in response) {
      if (d != null) {
        listComments.add(ForumComment.fromJson(d));
      }
    }
    return listComments;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  // Helper untuk format tanggal dari String ISO
  String _formatIsoDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return _formatDate(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currentUser = request.jsonData["user_username"]; 
    final role = request.jsonData["role"];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Forum Detail'),
        backgroundColor: Colors.yellow[700], 
        foregroundColor: Colors.black,
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === BAGIAN DETAIL POST ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                widget.forum.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.forum.title,
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(widget.forum.createdAt),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.forum.userUsername,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              widget.forum.content,
              style: const TextStyle(fontSize: 16.0, height: 1.6, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            
            // Tombol Edit/Delete Post Utama
            const SizedBox(height: 20),
            if (widget.forum.userUsername == currentUser || (role != null && role.toString().toLowerCase() == 'admin'))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   if (widget.forum.userUsername == currentUser)
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit Post"),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => ForumEditPage(forum: widget.forum)));
                      },
                    ),
                   TextButton.icon(
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text("Delete Post", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                         // ... Logika delete post kamu yang sebelumnya ...
                         final response = await request.post("http://localhost:8000/forum/ajax/delete-post/${widget.forum.id}/", {});
                         if (context.mounted && response['status'] == 'success') {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForumEntryListPage()));
                         }
                      },
                    ),
                ],
              ),

            const Divider(thickness: 1, height: 40),

            // === BAGIAN KOMENTAR ===
            const Text("Komentar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            FutureBuilder<List<ForumComment>>(
              future: fetchComments(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Belum ada komentar.", style: TextStyle(color: Colors.grey)),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final comment = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(comment.user, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_formatIsoDate(comment.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(comment.content),
                              
                              // Tombol Edit/Delete Komentar
                              if (comment.user == currentUser)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                      onPressed: () => _showEditCommentDialog(context, request, comment),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                      onPressed: () => _deleteComment(request, comment.id),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),

            // === FORM TAMBAH KOMENTAR ===
            const SizedBox(height: 20),
            if (request.loggedIn)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tambahkan Komentar", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Tulis komentar...",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Komentar tidak boleh kosong";
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response = await request.postJson(
                            "http://localhost:8000/forum/ajax/create-comment/${widget.forum.id}/",
                            jsonEncode({'content': _commentController.text}),
                          );
                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              _commentController.clear();
                              setState(() {}); // Refresh halaman untuk memunculkan komentar baru
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Komentar terkirim!")));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Gagal")));
                            }
                          }
                        }
                      },
                      child: const Text("Kirim"),
                    ),
                  ],
                ),
              )
            else
               const Center(child: Text("Login untuk menambahkan komentar", style: TextStyle(color: Colors.red))),
               const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Fungsi Edit Komentar (Muncul Popup)
  void _showEditCommentDialog(BuildContext context, CookieRequest request, ForumComment comment) {
    TextEditingController editController = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Komentar"),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final response = await request.postJson(
                "http://localhost:8000/forum/ajax/edit-comment/${comment.id}/",
                jsonEncode({'content': editController.text}),
              );
              if (context.mounted) {
                if (response['status'] == 'success') {
                  Navigator.pop(context);
                  setState(() {}); // Refresh UI
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal edit komentar")));
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // Fungsi Hapus Komentar
  void _deleteComment(CookieRequest request, int commentId) async {
    final response = await request.post("http://localhost:8000/forum/ajax/delete-comment/$commentId/", {});
    if (mounted) {
      if (response['status'] == 'success') {
        setState(() {}); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Komentar dihapus")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal hapus komentar")));
      }
    }
  }
}