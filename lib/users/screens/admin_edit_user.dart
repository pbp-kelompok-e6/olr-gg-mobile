import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminEditUserPage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> initialData;

  const AdminEditUserPage({
    super.key,
    required this.userId,
    required this.initialData,
  });

  @override
  State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _strikesController;

  // Role Dropdown
  String? _selectedRole;
  final List<String> _roleOptions = ['reader', 'writer', 'admin'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    _usernameController = TextEditingController(text: data['username'] ?? '');
    _firstNameController = TextEditingController(text: data['first_name'] ?? '');
    _lastNameController = TextEditingController(text: data['last_name'] ?? '');
    _bioController = TextEditingController(text: data['bio'] ?? '');
    _strikesController = TextEditingController(text: (data['strikes'] ?? 0).toString());

    // Set Role awal
    String initialRole = data['role'] ?? 'reader';
    if (_roleOptions.contains(initialRole)) {
      _selectedRole = initialRole;
    } else {
      _selectedRole = 'reader';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _strikesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Gunakan localhost untuk Web/Chrome
    final String url = "http://localhost:8000/users/admin-dashboard/edit-user/${widget.userId}/";

    try {
      // Kita pakai request.post bawaan pbp_django_auth
      // Ini OTOMATIS mengurus Cookie Session & CSRF Token
      final response = await request.post(url, {
        'username': _usernameController.text,
        'role': _selectedRole ?? 'reader',
        'strikes': _strikesController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'bio': _bioController.text,
        // Kita tidak kirim data gambar, jadi Django akan membiarkan gambar yang lama
      });

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User berhasil diupdate!")),
          );
          // Kembali ke dashboard dengan nilai 'true' agar list direfresh
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          // Tampilkan error jika validasi form Django gagal
          String msg = "Gagal menyimpan update.";
          if (response['errors'] != null) {
            msg = "Error: ${response['errors']}";
          } else if (response['message'] != null) {
            msg = response['message'];
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil CookieRequest dari Provider
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Edit User'),
        backgroundColor: Colors.indigo, // Sesuaikan dengan Dashboard
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Data User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 20),

              // --- USERNAME ---
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? "Username wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // --- ROLE & STRIKES ---
              Row(
                children: [
                  // Dropdown Role
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: _roleOptions.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedRole = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Input Strikes
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _strikesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Strikes",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Wajib";
                        if (int.tryParse(val) == null) return "Angka";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- DATA PRIBADI ---
              const Divider(),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- BIO ---
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 32),

              // --- TOMBOL SUBMIT ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : () => _submitForm(request),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}