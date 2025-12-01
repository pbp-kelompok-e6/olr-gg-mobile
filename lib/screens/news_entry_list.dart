import 'package:flutter/material.dart';
import 'package:olrggmobile/models/news_entry.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/screens/news_detail.dart';
import 'package:olrggmobile/widgets/news_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/screens/news_detail.dart';

class NewsEntryListPage extends StatefulWidget {
  final bool showOnlyMine;
  final bool showFeatured;

  const NewsEntryListPage({super.key, this.showOnlyMine = false, this.showFeatured = false,});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  late bool showOnlyMyNews;
  late bool showFeatured;

  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    showOnlyMyNews = widget.showOnlyMine;
    showFeatured = widget.showFeatured;

    if (showOnlyMyNews) selectedFilter = "mine";
    if (showFeatured) selectedFilter = "featured";
  }
  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    // TODO: Replace the URL with your app's URL and don't forget to add a trailing slash (/)!
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000

    final response = await request.get('http://localhost:8000/json/');

    // Decode response to json format
    var data = response;

    // Convert json data to NewsEntry objects
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

    String title = "All News";
    if (selectedFilter == "mine") title = "My News";
    if (selectedFilter == "featured") title = "Featured News";
    final request = context.watch<CookieRequest>();
    final role = request.jsonData["role"];
    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text(title),
      ),
      drawer: const LeftDrawer(),
      body: Column(
          children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              decoration: const InputDecoration(
                labelText: "Filter",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: "all",
                  child: Text("All News"),
                ),
                if (role != "reader")
                  DropdownMenuItem(
                    value: "mine",
                    child: Text("My News"),
                  ),
                DropdownMenuItem(
                  value: "featured",
                  child: Text("Featured News"),
                ),
              ],
              onChanged: (value) {
                if (value == "mine" && role == "reader") return;
                setState(() {
                  selectedFilter = value!;

                  showOnlyMyNews = selectedFilter == "mine";
                  showFeatured = selectedFilter == "featured";
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: fetchNews(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        Text(
                          'There are no news in OLR.GG yet.',
                          style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  } else {
                    List<NewsEntry> news = snapshot.data!;
                    if (showOnlyMyNews) {
                      final userUsername = request.jsonData["user_username"];
                      news =
                          news.where((p) => p.userUsername == userUsername).toList();
                    }
                    if (showFeatured) {
                      news = news.where((p) => p.isFeatured == true).toList();
                    }
                    return ListView.builder(
                      itemCount: news.length,
                      itemBuilder: (_, index) => NewsEntryCard(
                        news: news[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailPage(
                                news: news[index],
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