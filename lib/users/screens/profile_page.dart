import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/users/models/user_profile.dart'; 
import 'package:olrggmobile/models/news_entry.dart';       
import 'package:olrggmobile/screens/news_detail.dart';       
import 'package:olrggmobile/widgets/left_drawer.dart';       

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dataFuture = fetchProfileAndNews(request);
  }

  Future<Map<String, dynamic>> fetchProfileAndNews(CookieRequest request) async {
    final profileResponse = await request.get('http://localhost:8000/users/api/profile/');
    
    if (profileResponse['status'] != 'success') {
      throw Exception('Gagal memuat profil');
    }
    
    final userProfile = UserProfile.fromJson(profileResponse['data']);
    
    final newsResponse = await request.get(
      'http://localhost:8000/users/load_news/?id=${userProfile.id}&type=json'
    );
    
    List<NewsEntry> newsList = [];
    if (newsResponse['status'] == 'success') {
      for (var item in newsResponse['news_list']) {
        // Parse data berita sesuai model NewsEntry
        newsList.add(NewsEntry.fromJson(item));
      }
    }

    return {
      'profile': userProfile,
      'news': newsList,
    };
  }

  // Fungsi format tanggal sederhana
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } 
          
          if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final UserProfile user = snapshot.data!['profile'];
          final List<NewsEntry> newsList = snapshot.data!['news'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (user.profilePictureUrl == "/static/image/default_profile_picture.jpg")
                      ? NetworkImage('http://localhost:8000/static/image/default_profile_picture.jpg')
                      : NetworkImage('http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(user.profilePictureUrl)}'),
                  child: user.profilePictureUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName, 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "@${user.username} • ${user.role}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSimpleRow("Bio", user.bio),
                        const Divider(),
                        _buildSimpleRow("Bergabung", user.dateJoined),
                        const Divider(),
                        _buildSimpleRow("Total Strike", "${user.strikes}"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Berita yang Dipublish",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                if (newsList.isEmpty)
                  const Text("Belum ada berita.")
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              image: news.thumbnail.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(news.thumbnail)}'
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: news.thumbnail.isEmpty 
                                ? const Icon(Icons.image) 
                                : null,
                          ),
                          title: Text(
                            news.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(news.category),
                              Text(
                                _formatDate(news.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailPage(news: news),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}