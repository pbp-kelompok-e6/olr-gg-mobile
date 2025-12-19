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

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final role = request.jsonData["role"];
    return Drawer(
      backgroundColor: Colors.yellow[400],
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.yellow.shade700,
            ),
            child: Column(
              children: [
                Text(
                  'OLR.GG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text("Berita olahraga terbaik hanya di sini",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ));
            },
          ),
          if (role != "reader" && request.loggedIn)
          ListTile(
            leading: const Icon(Icons.post_add),
            title: const Text('Create News'),
            // Bagian redirection ke ProductFormPage
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NewsFormPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('News List'),
            onTap: () {
              // Route to product list page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsEntryListPage()),
              );
            },
          ),
          if (role == "reader" && role != "admin")
          ListTile(
            leading: const Icon(Icons.history_edu),
            title: const Text('Be a Writer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestWriterPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          if (role == "admin")
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final response = await request.logout(
                  "http://localhost:8000/auth/logout/");
              String message = response["message"];
              if (context.mounted) {
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("$message See you again, $uname."),
                  ));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}