import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/readinglist/models/readinglist_entry.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/screens/login.dart';
import 'package:olrggmobile/screens/news_detail.dart';
import 'package:olrggmobile/models/news_entry.dart';

class ReadingListPage extends StatefulWidget {
  const ReadingListPage({super.key});

  @override
  State<ReadingListPage> createState() => _ReadingListPageState();
}

class _ReadingListPageState extends State<ReadingListPage> {
  // Variabel untuk menyimpan hasil fetch agar bisa direfresh tanpa rebuild halaman penuh
  late Future<List<ReadingListEntry>> _readingListFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    // Cek Authorization saat inisialisasi
    if (!request.loggedIn) {
      // Jika belum login, redirect ke halaman login di frame berikutnya
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
    _readingListFuture = fetchReadingLists(request);
  }

  // Logic Fetch Data API
  Future<List<ReadingListEntry>> fetchReadingLists(
    CookieRequest request,
  ) async {
    final response = await request.get(
      'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/json/',
    );

    List<ReadingListEntry> list = [];
    for (var d in response) {
      if (d != null) {
        list.add(ReadingListEntry.fromJson(d));
      }
    }
    return list;
  }

  // Fungsi refresh data
  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _readingListFuture = fetchReadingLists(request);
    });
  }

  // Logic Create List
  Future<void> _createList(String name) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/lists/create/",
        jsonEncode({"name": name}),
      );

      if (response['message'] == 'List created') {
        _showSnackBar("List '$name' created successfully", true);
        _refreshData(); // Refresh UI
      } else {
        _showSnackBar(response['message'] ?? "Failed to create list", false);
      }
    } catch (e) {
      _showSnackBar("Error: $e", false);
    }
  }

  //  Logic Rename List
  Future<void> _renameList(String listId, String newName) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/lists/$listId/rename/",
        jsonEncode({"name": newName}),
      );

      if (response['message'] == 'List renamed') {
        _showSnackBar("List renamed successfully", true);
        _refreshData();
      } else {
        _showSnackBar(response['message'] ?? "Failed to rename list", false);
      }
    } catch (e) {
      _showSnackBar("Error: $e", false);
    }
  }

  // Logic Delete List
  Future<void> _deleteList(String listId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/lists/$listId/delete/",
        {},
      );

      if (response['message'] == 'List deleted') {
        _showSnackBar("List deleted successfully", true);
        _refreshData();
      } else {
        _showSnackBar(response['message'] ?? "Failed to delete list", false);
      }
    } catch (e) {
      _showSnackBar("Error: $e", false);
    }
  }

  Future<void> _removeNewsFromList(String listId, String newsId) async {
    final request = context.read<CookieRequest>();
    try {
      // Endpoint add_remove berfungsi sebagai toggle.
      // Karena item sudah ada di list, ini akan menghapusnya.
      final response = await request.postJson(
        "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/add_remove/$newsId/",
        jsonEncode({"list_id": listId}),
      );

      if (response['status'] == 'REMOVED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("News removed from list"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI setelah hapus
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to remove"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markAsRead(int itemId) async {
    final request = context.read<CookieRequest>();
    try {
      // URL: /readinglist/items/<item_id>/toggle-read/
      final response = await request.post(
        "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/items/$itemId/toggle-read/",
        {},
      );

      if (response['success'] == true) {
        // Jika sukses, refresh data agar UI berubah jadi centang hijau
        _refreshData();
      }
    } catch (e) {
      debugPrint("Gagal update status read: $e");
    }
  }

  // Helper untuk menampilkan pesan error/sukses
  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  // Dialog Helpers
  void _showCreateDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New List"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "List Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _createList(_controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(String listId, String currentName) {
    final TextEditingController _controller = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename List"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "New Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _renameList(listId, _controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String listId, String listName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete List"),
        content: Text("Are you sure you want to delete '$listName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _deleteList(listId);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // HIde UI jika belum login
    if (!request.loggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Reading Lists',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog, // Pastikan fungsi ini ada di kode Anda
        label: const Text("Create New List"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(), // Pastikan fungsi ini ada
        child: FutureBuilder<List<ReadingListEntry>>(
          future: fetchReadingLists(request),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.collections_bookmark_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No reading lists yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Create your first list to start organizing news.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              // UI LISTVIEW
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  ReadingListEntry listEntry = snapshot.data![index];
                  bool isFavorites = listEntry.name == 'Favorites';

                  // LOGIKA WARNA (Match Web Design)
                  Color headerColor = isFavorites
                      ? Colors.red.shade50
                      : Colors.grey.shade50;
                  Color borderColor = isFavorites
                      ? Colors.red.shade500
                      : Colors.grey.shade200;
                  Color iconColor = isFavorites
                      ? Colors.red.shade600
                      : Colors.blue.shade600;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // LIST HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: headerColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isFavorites
                                        ? Icons.favorite
                                        : Icons.bookmark,
                                    color: iconColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    listEntry.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[600],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${listEntry.items.length}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Tombol Edit/Delete List (Disembunyikan untuk Favorites)
                              if (!isFavorites)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _showRenameDialog(
                                        listEntry.id,
                                        listEntry.name,
                                      ),
                                      tooltip: "Rename List",
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _showDeleteConfirmDialog(
                                        listEntry.id,
                                        listEntry.name,
                                      ),
                                      tooltip: "Delete List",
                                    ),
                                  ],
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    border: Border.all(color: Colors.red[200]!),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        size: 12,
                                        color: Colors.red[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Protected",
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // LIST ITEMS
                        if (listEntry.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 48,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "No items in this list yet",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            physics:
                                const NeverScrollableScrollPhysics(), // Scroll mengikuti parent
                            shrinkWrap: true,
                            itemCount: listEntry.items.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (context, itemIndex) {
                              final item = listEntry.items[itemIndex];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(item.news.thumbnail)}',
                                      ),
                                      onError: (exception, stackTrace) {},
                                    ),
                                    color: Colors.grey[300],
                                  ),
                                  child: item.news.thumbnail.isEmpty
                                      ? const Icon(Icons.image)
                                      : null,
                                ),
                                title: Text(
                                  item.news.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  item.news.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),

                                // ACTION BUTTONS (Status & Delete)
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: item.isRead ? "Read" : "Unread",
                                      child: Icon(
                                        item.isRead
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: item.isRead
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: "Remove from list",
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Remove News"),
                                            content: const Text(
                                              "Are you sure you want to remove this news from the list?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _removeNewsFromList(
                                                    listEntry.id,
                                                    item.news.id,
                                                  );
                                                },
                                                child: const Text(
                                                  "Remove",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                // ON TAP (Mark as Read & Navigate)
                                onTap: () async {
                                  if (!item.isRead) {
                                    await _markAsRead(item.id);
                                  }

                                  NewsEntry newsData = NewsEntry(
                                    id: item.news.id,
                                    title: item.news.title,
                                    thumbnail: item.news.thumbnail,
                                    category: item.news.category,
                                    content: item.news.content,
                                    createdAt: item.news.createdAt,
                                    userUsername: item.news.userUsername,
                                    userId: item.news.userId.toString(),
                                    isFeatured: false,
                                    ratingCount: 0,
                                  );

                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewsDetailPage(news: newsData),
                                      ),
                                    ).then((_) {
                                      // Refresh data when returning from NewsDetailPage
                                      _refreshData();
                                    });
                                  }
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
