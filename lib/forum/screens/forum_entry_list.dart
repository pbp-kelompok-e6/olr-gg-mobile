import 'package:flutter/material.dart';
import 'package:olrggmobile/forum/models/forum_entry.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/forum/screens/forum_detail.dart';
import 'package:olrggmobile/forum/screens/forumlist_form.dart';
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

  String selectedCategory = 'all';
  final List<String> categories = [
    'all',
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
    showOnlyMyPosts = widget.showOnlyMine;
  }

  Future<List<ForumEntry>> fetchForum(CookieRequest request) async {
    final response = await request.get(
      'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/forum/json/',
    );
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
    final userUsername = request.jsonData["user_username"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
        title: Text(
          showOnlyMyPosts ? "My Discussions" : "Discussion Forum",
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[800], height: 1.0),
        ),
      ),
      drawer: const LeftDrawer(),

      floatingActionButton: request.loggedIn
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForumFormPage(),
                  ),
                );
              },
              label: const Text(
                "New Discussion",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.red[600],
              elevation: 4,
            )
          : null,

      body: Column(
        children: [
          if (request.loggedIn)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _buildMainFilterChip("All", !showOnlyMyPosts, () {
                    setState(() => showOnlyMyPosts = false);
                  }),
                  const SizedBox(width: 8),
                  _buildMainFilterChip("My Forum", showOnlyMyPosts, () {
                    setState(() => showOnlyMyPosts = true);
                  }),
                ],
              ),
            ),

          Container(
            width: double.infinity,
            color: Colors.white,
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat == 'all'
                        ? "All Categories"
                        : cat[0].toUpperCase() + cat.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCategory = cat;
                    });
                  },
                  selectedColor: Colors.red,
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.white! : Colors.transparent,
                    ),
                  ),
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          Expanded(
            child: FutureBuilder(
              future: fetchForum(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                } else if (snapshot.hasError) {
                  final errorMsg = snapshot.error.toString();
                  final isNetworkError =
                      errorMsg.contains('SocketException') ||
                      errorMsg.contains('Connection') ||
                      errorMsg.contains('timeout') ||
                      errorMsg.contains('XMLHttpRequest');

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isNetworkError
                                ? Icons.wifi_off
                                : Icons.error_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isNetworkError
                                ? 'Tidak dapat terhubung ke server'
                                : 'Gagal memuat forum',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isNetworkError
                                ? 'Periksa koneksi internet Anda dan coba lagi.'
                                : 'Silakan coba lagi nanti.',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  List<ForumEntry> forumPosts = snapshot.data!;

                  if (showOnlyMyPosts) {
                    forumPosts = forumPosts
                        .where((p) => p.userUsername == userUsername)
                        .toList();
                  }

                  if (selectedCategory != 'all') {
                    forumPosts = forumPosts
                        .where(
                          (p) =>
                              p.category.toLowerCase() ==
                              selectedCategory.toLowerCase(),
                        )
                        .toList();
                  }

                  if (forumPosts.isEmpty) {
                    return _buildEmptyState(
                      message: "No discussions found in this category.",
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: forumPosts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 0),
                    itemBuilder: (_, index) => ForumEntryCard(
                      forum: forumPosts[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ForumDetailPage(forum: forumPosts[index]),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFilterChip(
    String label,
    bool isSelected,
    VoidCallback onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.red[600],
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.red[600]! : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState({String message = 'No discussions yet.'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
