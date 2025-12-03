import 'package:flutter/material.dart';
import 'package:olrggmobile/users/models/user_profile.dart';
import 'package:olrggmobile/users/models/user_news.dart'; // Import model baru
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Kita gunakan FutureBuilder yang menangani kedua request (Profil & News)
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dataFuture = fetchProfileAndNews(request);
  }

  Future<Map<String, dynamic>> fetchProfileAndNews(CookieRequest request) async {
    // 1. Ambil Profil User (Gunakan endpoint API profil yang sebelumnya sudah dibuat)
    //    Endpoint ini tetap diperlukan untuk mendapatkan ID user yang sedang login.
    final profileResponse = await request.get('http://localhost:8000/users/api/profile/');
    
    if (profileResponse['status'] != 'success') {
      throw Exception('Gagal memuat profil');
    }
    
    final userProfile = UserProfile.fromJson(profileResponse['data']);

    // 2. Ambil News menggunakan endpoint ASLI yang sudah dimodifikasi
    //    Format: /users/load_news/?id=ID_USER&type=json
    final newsResponse = await request.get(
      'http://localhost:8000/users/load_news/?id=${userProfile.id}&type=json'
    );
    
    List<UserNews> newsList = [];
    if (newsResponse['status'] == 'success') {
      for (var item in newsResponse['news_list']) {
        newsList.add(UserNews.fromJson(item));
      }
    }

    return {
      'profile': userProfile,
      'news': newsList,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Note: Request tidak perlu di-watch di build jika sudah di-read di initState,
    // tapi jika butuh refresh state, bisa disesuaikan.
    
    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final UserProfile user = snapshot.data!['profile'];
          final List<UserNews> newsList = snapshot.data!['news'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === BAGIAN PROFIL (Sama seperti sebelumnya) ===
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            'http://localhost:8000${user.profilePictureUrl}',
                          ),
                          onBackgroundImageError: (_, __) => const Icon(Icons.person),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.fullName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // === BAGIAN INFO ===
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.info_outline,
                        title: "Bio",
                        content: user.bio,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.warning_amber_rounded,
                        title: "Status Pelanggaran",
                        content: "Strikes: ${user.strikes}/3",
                        contentColor: user.strikes >= 3 ? Colors.red : Colors.black87,
                      ),
                    ],
                  ),
                ),

                // === BAGIAN DAFTAR BERITA ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: const Text(
                    "Berita Saya",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white // Supaya kontras dengan background biru
                    ),
                  ),
                ),

                if (newsList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "Belum ada berita yang dipublish.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true, // Penting agar bisa di dalam SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigasi ke detail berita jika perlu
                            // Navigator.push(...);
                          },
                          child: Row(
                            children: [
                              // Thumbnail Berita
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    // Handle URL proxy localhost
                                    'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(news.thumbnail)}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => 
                                      Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                                  ),
                                ),
                              ),
                              // Detail Berita
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        news.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            news.createdAt,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Kategori & Featured Badge
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              news.categoryDisplay,
                                              style: TextStyle(fontSize: 10, color: Colors.blue[800]),
                                            ),
                                          ),
                                          if (news.isFeatured) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber[100],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                "Featured",
                                                style: TextStyle(fontSize: 10, color: Colors.amber[900]),
                                              ),
                                            ),
                                          ]
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color contentColor = Colors.black87,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue[800]),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: contentColor,
          ),
        ),
      ),
    );
  }
}