import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/forum/models/forum_entry.dart';
import 'package:olrggmobile/forum/screens/forum_entry_list.dart';
import 'package:olrggmobile/forum/screens/forum_edit_form.dart'; 

class ForumEntryCard extends StatelessWidget {
  final ForumEntry forum;
  final VoidCallback onTap;

  const ForumEntryCard({
    super.key,
    required this.forum,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    final currentUser = request.jsonData["user_username"]; 
    final role = request.jsonData["role"]; 

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          color: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        forum.category.toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(forum.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  forum.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  forum.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          forum.userUsername,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    
                    // === BAGIAN TOMBOL EDIT DAN DELETE ===
                    Row(
                      children: [
                        // Tombol Edit: Hanya untuk Pemilik Post
                        if (forum.userUsername == currentUser)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForumEditPage(forum: forum),
                                ),
                              );
                            },
                          ),

                        // Tombol Delete: Pemilik ATAU Admin
                        if (forum.userUsername == currentUser || 
                            (role != null && role.toString().toLowerCase() == 'admin'))
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
                          )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}