import 'package:flutter/material.dart';
import 'package:olrggmobile/forum/models/forum_entry.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/forum/screens/forum_edit_form.dart';
import 'package:olrggmobile/forum/screens/forum_entry_list.dart';

class ForumDetailPage extends StatelessWidget {
  final ForumEntry forum;

  const ForumDetailPage({super.key, required this.forum});

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Ambil request dan user data
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                forum.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              forum.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(forum.createdAt),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  forum.userUsername,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              forum.content,
              style: const TextStyle(
                fontSize: 16.0,
                height: 1.6,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 40),

            // === BAGIAN TOMBOL EDIT & DELETE DI DETAIL PAGE ===
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Tombol di kanan
              children: [
                // Tombol Edit: Hanya untuk Pemilik Post
                if (forum.userUsername == currentUser)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForumEditPage(forum: forum),
                          ),
                        );
                      },
                    ),
                  ),

                // Tombol Delete: Pemilik ATAU Admin
                if (forum.userUsername == currentUser || 
                    (role != null && role.toString().toLowerCase() == 'admin'))
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Hapus Post"),
                            content: const Text("Yakin ingin menghapus diskusi ini?"),
                            actions: [
                              TextButton(
                                child: const Text("Batal"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text("Hapus"),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        final response = await request.post(
                          "http://localhost:8000/forum/ajax/delete-post/${forum.id}/",
                          {},
                        );
                        
                        if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Post berhasil dihapus")),
                              );
                              // Balik ke list setelah delete sukses
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const ForumEntryListPage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['message'] ?? "Gagal menghapus")),
                              );
                            }
                        }
                      }
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}