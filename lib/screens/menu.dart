import 'package:flutter/material.dart';
import 'package:olrggmobile/screens/news_entry_list.dart';
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

    final List<ItemHomepage> categories = [
      ItemHomepage(
        "Basketball",
        "Get the latest basketball news, scores, and highlights",
        "https://img.olympics.com/images/image/private/t_s_pog_staticContent_hero_xl_2x/f_auto/primary/ywjjv6pml5diu5cwid21",
        "basketball",
      ),
      ItemHomepage(
        "Soccer",
        "Follow your favorite teams and players worldwide",
        "https://thumbs.dreamstime.com/b/cristiano-ronaldo-shooting-28136493.jpg",
        "soccer",
      ),
      ItemHomepage(
        "Football",
        "Stay updated with NFL news and game analysis",
        "https://idsb.tmgrup.com.tr/ly/uploads/images/2022/03/14/190521.jpg",
        "football",
      ),
      ItemHomepage(
        "Hockey",
        "Catch up on NHL games and player stats",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrMg3tMgiXXoLGcpD0mu2lNO4xnq3-0q8sZw&s",
        "hockey",
      ),
      ItemHomepage(
        "Volleyball",
        "Discover volleyball tournaments and matches",
        "https://images.volleyballworld.com/image/upload/t_q-best/fivb-prd/hfbm8zmgfx70kyid9qaw.jpg",
        "volleyball",
      ),
      ItemHomepage(
        "Baseball",
        "Get MLB scores, standings, and highlights",
        "https://media.cnn.com/api/v1/images/stellar/prod/230707091515-01-baseball-shohei-ohtani.jpg",
        "baseball",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('OLR.GG'),
      ),
      drawer: LeftDrawer(),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF1D4ED8),
                    Color(0xFFB91C1C),
                    Color(0xFF7F1D1D),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'OLR.',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              TextSpan(
                                text: 'GG',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your ultimate destination for sports news and updates',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose your favorite sport to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            int crossAxisCount;
                            if (width < 600) {
                              crossAxisCount = 1;
                            }
                            else if (width < 1000) {
                              crossAxisCount = 2;
                            }
                            else {
                              crossAxisCount = 3;
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return ItemCard(categories[index]);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 40),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewsEntryListPage()
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            label: const Text(
                              "View All Sports News",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: const Color(0xFFF3F4F6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "About OLR.GG",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "OLR.GG is your one-stop destination for sports news across Basketball, Soccer, Football, "
                        "Hockey, Volleyball, and Baseball. Join our community to discuss, rate, and save your favorite articles.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      (() {
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("📰", style: TextStyle(fontSize: 36)),
                                  SizedBox(height: 8),
                                  Text(
                                    "Latest News",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Real-time sports updates",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })(),
                      (() {
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("💬", style: TextStyle(fontSize: 36)),
                                  SizedBox(height: 8),
                                  Text(
                                    "Community",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Join discussions with fans",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })(),
                      (() {
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("📚", style: TextStyle(fontSize: 36)),
                                  SizedBox(height: 8),
                                  Text(
                                    "Reading Lists",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Save your favorite articles",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })(),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              color: const Color(0xFF0F1117),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth < 800 ? 1 : 3;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("OLR.GG", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                              SizedBox(height: 4),
                              Text("Your ultimate destination for sports news.", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Quick Links", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsEntryListPage()),);}, child: const Text("News", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {}, child: const Text("Forum", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {}, child: const Text("Reading Lists", style: TextStyle(color: Colors.white70))),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEntryListPage(category: "basketball",),),);}, child: const Text("Basketball", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEntryListPage(category: "soccer",),),);}, child: const Text("Soccer", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEntryListPage(category: "football",),),);}, child: const Text("Football", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEntryListPage(category: "hockey",),),);}, child: const Text("Hockey", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEntryListPage(category: "volleyball",),),);}, child: const Text("Volleyball", style: TextStyle(color: Colors.white70))),
                              TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewsEntryListPage(category: "baseball",),),);}, child: const Text("Baseball", style: TextStyle(color: Colors.white70))),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text("© 2025 OLR.GG. All rights reserved.", style: TextStyle(color: Colors.white70)),
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