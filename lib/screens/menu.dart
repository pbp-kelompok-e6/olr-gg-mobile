import 'package:flutter/material.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/widgets/news_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final role = request.jsonData["role"];

    final List<ItemHomepage> items = [
      ItemHomepage("All News", Icons.store, Colors.orange),
      if (role != "reader")
        ItemHomepage("Create News", Icons.post_add, Colors.red),
      if (role != "reader")
        ItemHomepage("My News", Icons.account_circle, Colors.green),
      ItemHomepage("Featured News", Icons.star, Colors.yellow),
    ];

    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        title: const Text(
          'OLR.GG',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow[700],
      ),
      drawer: LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di OLR.GG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  GridView.count(
                    primary: true,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 2.8,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}