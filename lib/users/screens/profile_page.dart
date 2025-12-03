import 'package:flutter/material.dart';
import 'package:olrggmobile/users/models/user_profile.dart';
import 'package:olrggmobile/widgets/left_drawer.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // fungsi buat mengambil data profil
  Future<UserProfile> fetchProfile(CookieRequest request) async {
    // TODO: ntar ganti url 
    final response = await request.get('http://localhost:8000/users/api/profile/');
    
    if (response['status'] == 'success') {
      return UserProfile.fromJson(response['data']);
    } else {
      throw Exception('Gagal memuat profil: ${response['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

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
      body: FutureBuilder<UserProfile>(
        future: fetchProfile(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data profil tidak ditemukan"));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Profil dengan Background Kuning
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
                        // Foto Profil
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            // Gunakan proxy URL jika di localhost android
                            'http://localhost:8000${user.profilePictureUrl}',
                          ),
                          onBackgroundImageError: (_, __) => const Icon(Icons.person),
                        ),
                        const SizedBox(height: 10),
                        // Nama Lengkap / Username
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // Role Badge
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        title: "Account status",
                        content: "Strike count: ${user.strikes}/3",
                        contentColor: user.strikes >= 3 ? Colors.red : Colors.black87,
                        trailing: user.strikes > 0 
                          ? const Icon(Icons.error, color: Colors.red) 
                          : const Icon(Icons.check_circle, color: Colors.green),
                      ),

                      const SizedBox(height: 10),

                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: "Joined since",
                        content: user.dateJoined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Edit Profile Button (Optional, mengarah ke form edit)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman edit profil (Anda perlu buat form ini)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur Edit Profil segera hadir!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[900],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Edit Profil",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
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
    Widget? trailing,
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
        trailing: trailing,
      ),
    );
  }
}