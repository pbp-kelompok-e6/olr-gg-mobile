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

  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _strikesController;

  String? _selectedRole;
  final List<String> _roleOptions = ['reader', 'writer', 'admin'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    _usernameController = TextEditingController(text: data['username'] ?? '');
    _firstNameController = TextEditingController(text: data['first_name'] ?? '');
    _lastNameController = TextEditingController(text: data['last_name'] ?? '');
    _bioController = TextEditingController(text: data['bio'] ?? '');
    _strikesController = TextEditingController(text: (data['strikes'] ?? 0).toString());

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

  Future<void> _simpanPerubahan(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await request.post(
        "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/edit-user/${widget.userId}/",
        {
          'username': _usernameController.text,
          'role': _selectedRole ?? 'reader',
          'strikes': _strikesController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'bio': _bioController.text,
        },
      );

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil update user!")),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Gagal update.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error koneksi: $e")),
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
        title: const Text('Edit User'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Username tidak boleh kosong";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
                items: _roleOptions.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _strikesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah Strikes",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Tidak boleh kosong";
                  if (int.tryParse(value) == null) return "Harus berupa angka";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
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
                  onPressed: _isLoading ? null : () => _simpanPerubahan(request),
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