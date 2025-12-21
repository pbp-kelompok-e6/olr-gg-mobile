import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/widgets/left_drawer.dart';
import 'package:olrggmobile/users/models/admin_models.dart';
import 'package:olrggmobile/users/screens/profile_page.dart';
import 'package:olrggmobile/users/screens/admin_edit_user.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<AdminUser> users = [];
  List<AdminReport> reports = [];
  List<AdminWriterRequest> requests = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      fetchAdminData(request);
    });
  }

  Future<void> fetchAdminData(CookieRequest request) async {
    if (users.isEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final response = await request.get(
        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/?type=json',
      );

      if (response['status'] == 'success') {
        List<AdminUser> tempUsers = [];
        for (var d in response['users']) {
          if (d != null) {
            tempUsers.add(AdminUser.fromJson(d));
          }
        }

        List<AdminReport> tempReports = [];
        for (var d in response['reports']) {
          if (d != null) {
            tempReports.add(AdminReport.fromJson(d));
          }
        }

        List<AdminWriterRequest> tempRequests = [];
        for (var d in response['writer_requests']) {
          if (d != null) {
            tempRequests.add(AdminWriterRequest.fromJson(d));
          }
        }

        setState(() {
          users = tempUsers;
          reports = tempReports;
          requests = tempRequests;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Gagal terhubung: $e";
        isLoading = false;
      });
    }
  }

  Future<void> resetStrikes(int userId, CookieRequest request) async {
    try {
      final response = await request.post(
        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/reset-strikes/$userId/',
        {},
      );
      if (response['status'] == 'success') {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Strikes direset!")));
        fetchAdminData(request);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> handleReport(
    int id,
    String action,
    CookieRequest request,
  ) async {
    final url = action == 'accept'
        ? 'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/accept-report/$id/'
        : 'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/delete-report/$id/';

    try {
      final response = await request.post(url, {});
      if (response['status'] == 'success') {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
        fetchAdminData(request);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> handleWriterRequest(
    int id,
    String action,
    CookieRequest request,
  ) async {
    final url = action == 'approve'
        ? 'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/approve-writer/$id/'
        : 'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/admin-dashboard/reject-writer/$id/';

    try {
      final response = await request.post(url, {});
      if (response['status'] == 'success') {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
        fetchAdminData(request);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Users"),
              Tab(icon: Icon(Icons.report_problem), text: "Reports"),
              Tab(icon: Icon(Icons.edit_document), text: "Requests"),
            ],
          ),
        ),
        drawer: const LeftDrawer(),
        backgroundColor: Colors.grey[100],
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : TabBarView(
                children: [
                  _buildUserList(request),
                  _buildReportList(request),
                  _buildRequestList(request),
                ],
              ),
      ),
    );
  }

  Widget _buildUserList(CookieRequest request) {
    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => fetchAdminData(request),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const Text("Tidak ada user."),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchAdminData(request),
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userId: user.id.toString()),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              () {
                                    String url = user.profilePictureUrl.trim();
                                    if (url.isEmpty)
                                      return const AssetImage(
                                        'images/default_profile_picture.jpg',
                                      );

                                    if (url.startsWith('http')) {
                                      return CachedNetworkImageProvider(
                                        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(url)}',
                                      );
                                    } else {
                                      if (!url.startsWith('/')) url = '/$url';
                                      return CachedNetworkImageProvider(
                                        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id$url',
                                      );
                                    }
                                  }()
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user.fullName.isEmpty ? "-" : user.fullName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: user.isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        Text(
                          "${user.strikes} / 3 Strikes",
                          style: TextStyle(
                            color: user.strikes >= 3
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminEditUserPage(
                                  userId: user.id,
                                  initialData: {
                                    'username': user.username,
                                    'first_name': user.fullName
                                        .split(" ")
                                        .first,
                                    'last_name': "",
                                    'bio': '',
                                    'role': user.role,
                                    'strikes': user.strikes,
                                    'profile_picture_url':
                                        user.profilePictureUrl,
                                  },
                                ),
                              ),
                            );
                            if (result == true) fetchAdminData(request);
                          },
                          child: const Text("Edit"),
                        ),
                        const SizedBox(width: 8),
                        if (user.strikes > 0)
                          OutlinedButton(
                            onPressed: () => resetStrikes(user.id, request),
                            child: const Text("Reset Strike"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportList(CookieRequest request) {
    if (reports.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => fetchAdminData(request),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 1,
            child: const Text("Tidak ada report yang masuk."),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchAdminData(request),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dari: @${report.reporterUsername} | Tanggal: ${report.createdAt}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Melaporkan: @${report.reportedUsername}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    "Alasan: ${report.reason}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              handleReport(report.id, 'accept', request),
                          child: const Text("Terima"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              handleReport(report.id, 'delete', request),
                          child: const Text("Tolak"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestList(CookieRequest request) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => fetchAdminData(request),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 1,
            child: const Text("Tidak ada request writer yang masuk."),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchAdminData(request),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "@${req.username} membuat request writer.",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(req.reason),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              handleWriterRequest(req.id, 'approve', request),
                          child: const Text("Approve"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              handleWriterRequest(req.id, 'reject', request),
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
