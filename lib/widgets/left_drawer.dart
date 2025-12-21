import 'package:flutter/material.dart';
import 'package:olrggmobile/screens/menu.dart';
import 'package:olrggmobile/screens/newslist_form.dart';
import 'package:olrggmobile/screens/news_entry_list.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/screens/login.dart';
import 'package:olrggmobile/users/screens/profile_page.dart';
import 'package:olrggmobile/users/screens/admin_dashboard_page.dart';
import 'package:olrggmobile/users/screens/request_writer_role.dart';
import 'package:olrggmobile/forum/screens/forum_entry_list.dart';
import 'package:olrggmobile/forum/screens/forumlist_form.dart';
import 'package:olrggmobile/readinglist/screens/reading_list_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final role = request.jsonData["role"];
    return Drawer(
      backgroundColor: const Color(0xFF0F1117),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "OLR.",
                        style: TextStyle(color: Colors.blue.shade400),
                      ),
                      TextSpan(
                        text: "GG",
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Berita olahraga terbaik hanya di sini",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.grey),
            title: const Text("Home", style: TextStyle(color: Colors.grey)),
            hoverColor: Colors.white10,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MyHomePage()),
            ),
          ),
          if (request.loggedIn == false) {
            ListTile(
              leading: const Icon(Icons.login, color: Colors.grey),
              title: const Text("Login", style: TextStyle(color: Colors.grey)),
              hoverColor: Colors.white10,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
            ),

          ListTile(
              leading: const Icon(Icons.login, color: Colors.grey),
              title: const Text("Login", style: TextStyle(color: Colors.grey)),
              hoverColor: Colors.white10,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
            ),
          }
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: const Icon(Icons.sports, color: Colors.grey),
              title: const Text('Sports', style: TextStyle(color: Colors.grey)),
              childrenPadding: const EdgeInsets.only(left: 16),
              backgroundColor: const Color(0xFF1A1D29),
              collapsedBackgroundColor: const Color(0xFF0F1117),
              collapsedIconColor: Colors.grey,
              iconColor: Colors.grey,
              children: [
                ListTile(
                  title: const Text(
                    "Basketball",
                    style: TextStyle(color: Colors.grey),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsEntryListPage(category: "basketball"),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Soccer",
                    style: TextStyle(color: Colors.grey),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsEntryListPage(category: "soccer"),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Football",
                    style: TextStyle(color: Colors.grey),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsEntryListPage(category: "football"),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Hockey",
                    style: TextStyle(color: Colors.grey),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsEntryListPage(category: "hockey"),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Volleyball",
                    style: TextStyle(color: Colors.grey),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsEntryListPage(category: "volleyball"),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Baseball",
                    style: TextStyle(color: Colors.grey),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsEntryListPage(category: "baseball"),
                    ),
                  ),
                ),
                const Divider(color: Colors.grey),
                ListTile(
                  title: const Text(
                    "All Sports News",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  hoverColor: Colors.white10,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => NewsEntryListPage()),
                  ),
                ),
              ],
            ),
          ),
          if (request.loggedIn) // Hanya muncul jika login
            ListTile(
              leading: const Icon(
                Icons.collections_bookmark,
                color: Colors.grey,
              ),
              title: const Text(
                'My Reading Lists',
                style: TextStyle(color: Colors.grey),
              ),
              hoverColor: Colors.white10,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadingListPage(),
                  ),
                );
              },
            ),
          if (role != "reader" && request.loggedIn)
            ListTile(
              leading: const Icon(Icons.post_add, color: Colors.grey),
              title: const Text(
                "Create News",
                style: TextStyle(color: Colors.grey),
              ),
              hoverColor: Colors.white10,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NewsFormPage()),
              ),
            ),
          // FORUM
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.grey),
            title: const Text('Forum', style: TextStyle(color: Colors.grey)),
            hoverColor: Colors.white10,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForumEntryListPage(),
                ),
              );
            },
          ),
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.add_comment, color: Colors.grey),
              title: const Text(
                'Create Forum',
                style: TextStyle(color: Colors.grey),
              ),
              hoverColor: Colors.white10,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForumFormPage(),
                  ),
                );
              },
            ),
          if (role == "reader" && role != "admin")
            ListTile(
              leading: const Icon(Icons.history_edu, color: Colors.grey),
              title: const Text(
                'Be a Writer',
                style: TextStyle(color: Colors.grey),
              ),
              hoverColor: Colors.white10,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestWriterPage(),
                  ),
                );
              },
            ),
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: const Text(
                'My Profile',
                style: TextStyle(color: Colors.grey),
              ),
              hoverColor: Colors.white10,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          if (role == "admin")
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.grey,
              ),
              title: const Text(
                'Admin Dashboard',
                style: TextStyle(color: Colors.grey),
              ),
              hoverColor: Colors.white10,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardPage(),
                  ),
                );
              },
            ),
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text("Logout", style: TextStyle(color: Colors.grey)),
              hoverColor: Colors.white10,
              onTap: () async {
                final response = await request.logout(
                  "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/auth/logout/",
                );
                String message = response["message"];
                if (context.mounted) {
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$message See you again, $uname."),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}
