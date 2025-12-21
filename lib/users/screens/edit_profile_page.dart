import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/users/models/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;

  File? _imageFile; // file gambar yang dari galeri hp
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    List<String> names = widget.user.fullName.split(" ");
    String firstName = names.isNotEmpty ? names.first : "";
    String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _ambilGambar() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _simpanData(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String url = "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/edit_profile_flutter/";

    try {
      var requestMultipart = http.MultipartRequest('POST', Uri.parse(url));

      requestMultipart.fields['first_name'] = _firstNameController.text;
      requestMultipart.fields['last_name'] = _lastNameController.text;
      requestMultipart.fields['bio'] = _bioController.text;

      if (_imageFile != null) {
        requestMultipart.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _imageFile!.path,
        ));
      }

      requestMultipart.headers.addAll(request.headers);

      var response = await requestMultipart.send();
      var responseString = await response.stream.bytesToString();
      var data = jsonDecode(responseString);

      if (mounted) {
        if (response.statusCode == 200 && data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil berhasil disimpan!")),
          );
          Navigator.pop(context, true); // Balik ke halaman sebelumnya
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: ${data['message']}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: () {
                  String url = widget.user.profilePictureUrl;
                  if (_imageFile != null) {
                    return FileImage(_imageFile!);
                  }
                  if (url.isEmpty) {
                    return const AssetImage('images/default_profile_picture.jpg');
                  }
                  if (url.startsWith('http')) {
                    return CachedNetworkImageProvider(
                        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(url)}'
                    );
                  }
                  else {
                    if (!url.startsWith('/')) url = '/$url';
                    return CachedNetworkImageProvider('https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id$url');
                  }
                }() as ImageProvider,
                // onBackgroundImageError: (_, __) {
                //   print("Gagal load image: ${widget.user.profilePictureUrl}");
                // },
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _ambilGambar,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ganti Foto"),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nama depan wajib diisi";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : () => _simpanData(request),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Perubahan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}