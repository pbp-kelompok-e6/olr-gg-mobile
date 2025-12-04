import 'package:flutter/material.dart';
// PERBAIKAN IMPORT MODEL: Tambahkan 'forum/'
import 'package:olrggmobile/forum/models/forum_entry.dart'; 

// IMPORT DRAWER: Ini benar (karena LeftDrawer ada di folder utama widgets)
import 'package:olrggmobile/widgets/left_drawer.dart'; 

// PERBAIKAN IMPORT SCREEN: Tambahkan 'forum/screens/'
import 'package:olrggmobile/forum/screens/forum_detail.dart'; 
import 'package:olrggmobile/forum/screens/forumlist_form.dart';

// PERBAIKAN IMPORT WIDGET: Tambahkan 'forum/widgets/'
import 'package:olrggmobile/forum/widgets/forum_entry_card.dart'; 

import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ForumEntryListPage extends StatefulWidget {
  final bool showOnlyMine;

  const ForumEntryListPage({super.key, this.showOnlyMine = false});

  @override
  State<ForumEntryListPage> createState() => _ForumEntryListPageState();
}

class _ForumEntryListPageState extends State<ForumEntryListPage> {
  late bool showOnlyMyPosts;
  
  @override
  void initState() {
    super.initState();
    showOnlyMyPosts = widget.showOnlyMine;
  }

  Future<List<ForumEntry>> fetchForum(CookieRequest request) async {
    // Pastikan URL ini benar sesuai environment kamu (localhost atau 10.0.2.2)
    final response = await request.get('http://localhost:8000/forum/json/');
    
    var data = response;
    
    List<ForumEntry> listForum = [];
    for (var d in data) {
      if (d != null) {
        listForum.add(ForumEntry.fromJson(d));
      }
    }
    return listForum;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final role = request.jsonData["role"] ?? "reader"; 
    final userUsername = request.jsonData["user_username"];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text(showOnlyMyPosts ? "My Discussions" : "Forum Diskusi"),
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForumFormPage()),
            );
        },
        backgroundColor: Colors.yellow[700],
        child: const Icon(Icons.add_comment),
      ),
      body: Column(
        children: [
          if (role != 'reader') 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text("Semua"),
                  selected: !showOnlyMyPosts,
                  onSelected: (bool selected) {
                    setState(() {
                      showOnlyMyPosts = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Milik Saya"),
                  selected: showOnlyMyPosts,
                  onSelected: (bool selected) {
                    setState(() {
                      showOnlyMyPosts = true;
                    });
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder(
              future: fetchForum(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                   return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada diskusi di Forum.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  } else {
                    List<ForumEntry> forumPosts = snapshot.data!;
                    
                    if (showOnlyMyPosts) {
                      forumPosts = forumPosts
                          .where((p) => p.userUsername == userUsername)
                          .toList();
                    }

                    return ListView.builder(
                      itemCount: forumPosts.length,
                      itemBuilder: (_, index) => ForumEntryCard(
                        forum: forumPosts[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForumDetailPage(
                                forum: forumPosts[index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 