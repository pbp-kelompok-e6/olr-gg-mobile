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
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _futureData;

  final _formKey = GlobalKey<FormState>();
  String _reportReason = '';

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _futureData = _fetchAllData(request);
  }

  Future<Map<String, dynamic>> _fetchAllData(CookieRequest request) async {
    String baseUrl = 'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id';
    String profileUrl;

    if (widget.userId != null) {
      profileUrl = '$baseUrl/users/show_profile/${widget.userId}/?type=json';
    } else {
      profileUrl = '$baseUrl/users/api/profile/';
    }

    final responseProfile = await request.get(profileUrl);
    if (responseProfile['status'] != 'success') {
      throw Exception(responseProfile['message'] ?? "Gagal load profil");
    }
    final user = UserProfile.fromJson(responseProfile['data']);
    final responseNews = await request.get(
      '$baseUrl/users/load_news/?id=${user.id}&type=json',
    );

    List<NewsEntry> newsList = [];
    if (responseNews['status'] == 'success') {
      for (var d in responseNews['news_list']) {
        if (d != null) newsList.add(NewsEntry.fromJson(d));
      }
    }

    return {'user': user, 'news': newsList};
  }

  Future<void> _refreshData() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() {
      _futureData = _fetchAllData(request);
    });
    await _futureData;
  }

  void _showReportDialog(
    BuildContext context,
    String targetId,
    String username,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report @$username"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: "Alasan",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
            onSaved: (v) => _reportReason = v!,
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);
                final request = context.read<CookieRequest>();
                try {
                  final response = await request.post(
                    'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/report_user/$targetId/',
                    {'reason': _reportReason},
                  );
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'])),
                    );
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Lapor", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isMyProfile = widget.userId == null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isMyProfile ? 'My Profile' : 'User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      drawer: isMyProfile ? const LeftDrawer() : null,

      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final errorMsg = snapshot.error.toString();
              final isNetworkError = errorMsg.contains('SocketException') ||
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
                        isNetworkError ? Icons.wifi_off : Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isNetworkError
                            ? 'Tidak dapat terhubung ke server'
                            : 'Gagal memuat profil',
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
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Tidak ada data."));
            }

            final UserProfile user = snapshot.data!['user'];
            final List<NewsEntry> newsList = snapshot.data!['news'];

            String? currentUser = request.jsonData['username'];
            bool isOwner = isMyProfile || (currentUser == user.username);
            bool isAdmin = request.jsonData['role'] == "admin";

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  () {
                                        String url = user.profilePictureUrl;
                                        if (url.isEmpty)
                                          return const AssetImage(
                                            'images/default_profile_picture.jpg',
                                          );
                                        if (url.startsWith('http')) {
                                          return CachedNetworkImageProvider(
                                            'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(url)}',
                                          );
                                        } else {
                                          if (!url.startsWith('/'))
                                            url = '/$url';
                                          return CachedNetworkImageProvider(
                                            'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id$url',
                                          );
                                        }
                                      }()
                                      as ImageProvider,
                            ),
                            if (isOwner)
                              GestureDetector(
                                onTap: () async {
                                  final res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) =>
                                          EditProfilePage(user: user),
                                    ),
                                  );
                                  if (res == true) _refreshData();
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            if (!isOwner)
                              GestureDetector(
                                onTap: () => _showReportDialog(
                                  context,
                                  user.id,
                                  user.username,
                                ),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Icon(
                                    Icons.flag,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "@${user.username} • ${user.role.toUpperCase()}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat(
                              "Joined",
                              _formatDate(DateTime.parse(user.dateJoined)),
                            ),
                            if (isOwner || isAdmin) ...[
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey[300],
                              ),
                              _buildStat("Strikes", "${user.strikes}"),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.red, width: 3.0),
                      ),
                    ),
                    child: const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.bio.isNotEmpty ? user.bio : "No bio yet.",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.red, width: 3.0),
                      ),
                    ),
                    child: Text(
                      "News by @${user.username}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  if (newsList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Belum ada berita.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: newsList.map((news) {
                        String thumb = "";
                        if (news.thumbnail.isNotEmpty &&
                            !news.thumbnail.contains("default")) {
                          thumb = news.thumbnail.startsWith('http')
                              ? news.thumbnail
                              : 'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id${news.thumbnail}';
                        }
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => NewsDetailPage(news: news),
                              ),
                            ),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: thumb.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(thumb),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: thumb.isEmpty
                                  ? const Icon(
                                      Icons.article,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            title: Text(
                              news.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              "${news.category} • ${_formatDate(news.createdAt)}",
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
