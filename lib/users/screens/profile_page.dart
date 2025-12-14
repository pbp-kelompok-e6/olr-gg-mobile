import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/users/models/user_profile.dart';
import 'package:olrggmobile/models/news_entry.dart';
import 'package:olrggmobile/screens/news_detail.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/users/screens/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final int? userId; 

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _dataFuture;
  final _formKey = GlobalKey<FormState>();
  String _reportReason = '';

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dataFuture = fetchProfileAndNews(request);
  }

  Future<Map<String, dynamic>> fetchProfileAndNews(CookieRequest request) async {
    String profileUrl;
    String baseUrl = 'http://localhost:8000'; 
    
    if (widget.userId != null) {
      profileUrl = '$baseUrl/users/show_profile/${widget.userId}/?type=json';
    } else {
      profileUrl = '$baseUrl/users/api/profile/';
    }

    try {
      final profileResponse = await request.get(profileUrl);

      if (profileResponse['status'] != 'success') {
        throw Exception('Gagal memuat profil: ${profileResponse['message'] ?? "Unknown error"}');
      }

      final userProfile = UserProfile.fromJson(profileResponse['data']);

      final newsResponse = await request.get(
        '$baseUrl/users/load_news/?id=${userProfile.id}&type=json'
      );

      List<NewsEntry> newsList = [];
      if (newsResponse['status'] == 'success') {
        for (var item in newsResponse['news_list']) {
          newsList.add(NewsEntry.fromJson(item));
        }
      }

      return {
        'profile': userProfile,
        'news': newsList,
      };
    } catch (e) {
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // --- FUNGSI REPORT USER (Pop Up Dialog) ---
  void _showReportDialog(BuildContext context, String targetUserId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report @$username"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Apa alasan Anda melaporkan user ini?"),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Alasan (Reason)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alasan tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _reportReason = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final request = context.read<CookieRequest>();
                  
                  // Kirim Request ke Backend
                  // Endpoint: /users/report_user/<id>/
                  // Method: POST (Wajib POST agar tidak return HTML)
                  try {
                    final response = await request.post(
                      'http://localhost:8000/users/report_user/$targetUserId/',
                      {
                        'reason': _reportReason,
                      }
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop(); // Tutup Dialog
                      
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response['message']),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Handle error validation dari Django
                        String errMessage = response['message'] ?? "Terjadi kesalahan";
                        if (response['errors'] != null) {
                           // Jika error berupa JSON string dari form.errors.as_json()
                           // Kita perlu parsing sedikit atau tampilkan generic error
                           errMessage = "Isian form tidak valid.";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text("Submit Report"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.userId != null ? 'User Profile' : 'My Profile';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      drawer: widget.userId == null ? const LeftDrawer() : null,
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
          
          // Logic Owner: Jika widget.userId null (akses dari drawer) -> pasti owner
          // Atau jika backend mengirim flag is_owner (opsional, tp kita pakai logic userId)
          bool isOwner = widget.userId == null;

          // Tambahan: Jika akses dari Admin Dashboard tapi user ID nya sama dengan yang login,
          // kita tidak bisa cek di sini tanpa data request.user.id dari cookie.
          // Tapi untuk keamanan, Backend Report User akan menolak jika lapor diri sendiri.

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                
                // --- SECTION 1: HEADER USER (Vertical Center) ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. Foto Profil (Besar di Tengah)
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (user.profilePictureUrl.isEmpty || user.profilePictureUrl.contains("default"))
                                ? const AssetImage('images/default_profile_picture.jpg') as ImageProvider
                                : CachedNetworkImageProvider('http://localhost:8000${user.profilePictureUrl}'),
                            onBackgroundImageError: (_, __) {},
                          ),
                          
                          // TOMBOL EDIT (Hanya Jika Owner)
                          if (isOwner)
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black26)]
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditProfilePage(user: user)),
                                  );
                                  if (result == true) {
                                    setState(() {
                                      final request = context.read<CookieRequest>();
                                      _dataFuture = fetchProfileAndNews(request);
                                    });
                                  }
                                },
                              ),
                            ),

                          // TOMBOL REPORT (Hanya Jika BUKAN Owner)
                          if (!isOwner)
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black26)]
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.flag, color: Colors.red, size: 20),
                                tooltip: "Report User",
                                onPressed: () {
                                  // Panggil fungsi dialog report
                                  final request = context.read<CookieRequest>();
                                  _showReportDialog(context, user.id, user.username);
                                },
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 2. Nama Lengkap (Center)
                      Text(
                        user.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 8),

                      // 3. Username & Role Badge (Center)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "@${user.username}",
                            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      
                      // 4. Info Stats
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn("Joined", _formatDate(DateTime.parse(user.dateJoined))),
                          Container(height: 30, width: 1, color: Colors.grey[300]),
                          _buildStatColumn("Strikes", "${user.strikes}"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- SECTION 2: ABOUT ---
                _buildSectionTitle("About"),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    user.bio.isNotEmpty ? user.bio : "This user has not added a bio yet.",
                    style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 15),
                  ),
                ),

                const SizedBox(height: 24),

                // --- SECTION 3: POSTS ---
                _buildSectionTitle("Posts by @${user.username}"),
                const SizedBox(height: 12),

                if (newsList.isEmpty)
                   Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.newspaper, size: 40, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        const Text("Belum ada berita.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      
                      // Logic Thumbnail
                      String thumbnailUrl = "";
                      if (news.thumbnail.isNotEmpty && !news.thumbnail.contains("default")) {
                        if (news.thumbnail.startsWith('http')) {
                           thumbnailUrl = news.thumbnail.replaceAll('localhost', 'localhost');
                        } else {
                           thumbnailUrl = 'http://localhost:8000${news.thumbnail}';
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 70, 
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                      image: thumbnailUrl.isNotEmpty
                                          ? DecorationImage(image: NetworkImage(thumbnailUrl), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: thumbnailUrl.isEmpty
                                        ? const Icon(Icons.article, color: Colors.grey)
                                        : null,
                                  ),
                                  title: Text(
                                    news.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(news.category, style: TextStyle(fontSize: 11, color: Colors.blue[800], fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(_formatDate(news.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
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

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.red, width: 3)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}