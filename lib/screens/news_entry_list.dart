import 'package:flutter/material.dart';
import 'package:olrggmobile/models/news_entry.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/screens/news_detail.dart';
import 'package:olrggmobile/widgets/news_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/screens/newslist_form.dart';

class NewsEntryListPage extends StatefulWidget {
  final bool showOnlyMine;
  final String? category;

  const NewsEntryListPage({
    super.key,
    this.showOnlyMine = false,
    this.category,
  });

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  late bool showOnlyMyNews;

  String selectedFilter = "all";
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    showOnlyMyNews = widget.showOnlyMine;
    selectedCategory = widget.category;

    if (showOnlyMyNews) selectedFilter = "mine";
  }

  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    final response = await request.get(
      'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/json/',
    );
    var data = response;
    List<NewsEntry> listNews = [];
    for (var d in data) {
      if (d != null) {
        listNews.add(NewsEntry.fromJson(d));
      }
    }
    return listNews;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final role = request.jsonData["role"];
    final currentUser = request.jsonData["user_username"];

    String title = "All News";
    if (selectedFilter == "mine") title = "My News";
    if (selectedFilter == "featured") title = "Featured News";
    if (selectedCategory != null)
      title =
          "${selectedCategory![0].toUpperCase()}${selectedCategory!.substring(1)} News";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(title)),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Latest Sports News",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Stay updated with the latest stories and analysis from around the globe",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (role != "reader")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewsFormPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Create News"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedFilter = "mine";
                        showOnlyMyNews = true;
                      });
                    },
                    child: Text(
                      "My News",
                      style: TextStyle(
                        color: selectedFilter == "mine"
                            ? Colors.white
                            : Colors.grey[800],
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedFilter == "mine"
                          ? Colors.red[600]
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<NewsEntry>>(
              future: fetchNews(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Failed to load news",
                      style: TextStyle(color: Colors.red[600], fontSize: 16),
                    ),
                  );
                } else {
                  List<NewsEntry> news = snapshot.data!;
                  if (selectedCategory != null &&
                      selectedCategory!.isNotEmpty) {
                    news = news
                        .where((p) => p.category == selectedCategory)
                        .toList();
                  }
                  if (showOnlyMyNews) {
                    news = news
                        .where((p) => p.userUsername == currentUser)
                        .toList();
                  }
                  news.sort((a, b) {
                    if (a.isFeatured && !b.isFeatured) return -1;
                    if (!a.isFeatured && b.isFeatured) return 1;
                    return 0;
                  });
                  if (news.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.newspaper,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "No news found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Be the first to share sports news with the community",
                            style: TextStyle(fontSize: 16),
                          ),
                          if (role != "reader")
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NewsFormPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Create News"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      return NewsEntryCard(
                        news: news[index],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailPage(news: news[index]),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
