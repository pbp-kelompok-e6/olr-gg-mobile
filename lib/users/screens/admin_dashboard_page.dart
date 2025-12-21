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

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  List<AdminUser> users = [];
  List<AdminReport> reports = [];
  List<AdminWriterRequest> requests = [];

  bool isLoading = true;
  String errorMessage = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      fetchAdminData(request);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        setState(() {
          users = List<AdminUser>.from(
            response['users'].map((x) => AdminUser.fromJson(x)),
          );
          reports = List<AdminReport>.from(
            response['reports'].map((x) => AdminReport.fromJson(x)),
          );
          requests = List<AdminWriterRequest>.from(
            response['writer_requests'].map(
              (x) => AdminWriterRequest.fromJson(x),
            ),
          );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: "Users"),
            Tab(icon: Icon(Icons.report_problem), text: "Reports"),
            Tab(icon: Icon(Icons.edit_document), text: "Requests"),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : TabBarView(
              controller: _tabController,
              children: [
                _UserListTab(
                  users: users,
                  onRefresh: () => fetchAdminData(request),
                  onRequestAction: (id) => resetStrikes(id, request),
                ),
                _ReportListTab(
                  reports: reports,
                  onRefresh: () => fetchAdminData(request),
                  onRequestAction: (id, action) =>
                      handleReport(id, action, request),
                ),
                _RequestListTab(
                  requests: requests,
                  onRefresh: () => fetchAdminData(request),
                  onRequestAction: (id, action) =>
                      handleWriterRequest(id, action, request),
                ),
              ],
            ),
    );
  }
}

class _UserListTab extends StatefulWidget {
  final List<AdminUser> users;
  final Future<void> Function() onRefresh;
  final Function(int) onRequestAction;

  const _UserListTab({
    required this.users,
    required this.onRefresh,
    required this.onRequestAction,
  });

  @override
  State<_UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<_UserListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _navigateToEditPage(AdminUser user) async {
    String firstName = "";
    String lastName = "";
    List<String> names = user.fullName.trim().split(" ");
    if (names.isNotEmpty) {
      firstName = names.first;
      if (names.length > 1) {
        lastName = names.sublist(1).join(" ");
      }
    }

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEditUserPage(
          userId: user.id,
          initialData: {
            'username': user.username,
            'first_name': firstName,
            'last_name': lastName,
            'email': '',
            'bio': '',
            'role': user.role,
            'strikes': user.strikes,
            'profile_picture_url': user.profilePictureUrl,
          },
        ),
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          final user = widget.users[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: user.id),
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
                                    if (url.isEmpty) {
                                      return const AssetImage(
                                        'images/default_profile_picture.jpg',
                                      );
                                    }

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

                          onBackgroundImageError: (_, __) {
                            print(
                              "Gagal load image: ${user.profilePictureUrl}",
                            );
                          },
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
                        _AdminHelpers.buildRoleBadge(user.role),
                      ],
                    ),
                    const Divider(height: 20),

                    // status dan jumlah strike
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AdminHelpers.buildStatusBadge(user.isActive),
                        _AdminHelpers.buildStrikesBadge(user.strikes),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text("Edit User"),
                          onPressed: () => _navigateToEditPage(user),
                        ),

                        if (user.strikes > 0) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange[800],
                              side: BorderSide(color: Colors.orange[800]!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text("Reset Strike"),
                            onPressed: () => _AdminHelpers.showConfirmDialog(
                              context,
                              "Reset Strikes",
                              "Reset strikes untuk user ini menjadi 0?",
                              () => widget.onRequestAction(user.id),
                            ),
                          ),
                        ],
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
}

class _ReportListTab extends StatefulWidget {
  final List<AdminReport> reports;
  final Future<void> Function() onRefresh;
  final Function(int, String) onRequestAction;

  const _ReportListTab({
    required this.reports,
    required this.onRefresh,
    required this.onRequestAction,
  });

  @override
  State<_ReportListTab> createState() => _ReportListTabState();
}

class _ReportListTabState extends State<_ReportListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.reports.isEmpty)
      return _AdminHelpers.buildEmptyState(
        "Tidak ada laporan.",
        widget.onRefresh,
      );

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: widget.reports.length,
        itemBuilder: (context, index) {
          final rep = widget.reports[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rep.createdAt, style: const TextStyle(fontSize: 12)),
                      Text(
                        "by @${rep.reporterUsername}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Melaporkan: @${rep.reportedUsername}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rep.reason,
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
                          onPressed: () => _AdminHelpers.showConfirmDialog(
                            context,
                            "Accept",
                            "Terima?",
                            () => widget.onRequestAction(rep.id, 'accept'),
                          ),
                          child: const Text("Accept"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _AdminHelpers.showConfirmDialog(
                            context,
                            "Reject",
                            "Tolak?",
                            () => widget.onRequestAction(rep.id, 'delete'),
                          ),
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

class _RequestListTab extends StatefulWidget {
  final List<AdminWriterRequest> requests;
  final Future<void> Function() onRefresh;
  final Function(int, String) onRequestAction;

  const _RequestListTab({
    required this.requests,
    required this.onRefresh,
    required this.onRequestAction,
  });

  @override
  State<_RequestListTab> createState() => _RequestListTabState();
}

class _RequestListTabState extends State<_RequestListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.requests.isEmpty)
      return _AdminHelpers.buildEmptyState(
        "Tidak ada request.",
        widget.onRefresh,
      );

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: widget.requests.length,
        itemBuilder: (context, index) {
          final req = widget.requests[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "@${req.username}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                              widget.onRequestAction(req.id, 'approve'),
                          child: const Text("Approve"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              widget.onRequestAction(req.id, 'reject'),
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

class _AdminHelpers {
  static Widget buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget buildStatusBadge(bool isActive) {
    return Text(
      isActive ? "Active" : "Inactive",
      style: TextStyle(
        color: isActive ? Colors.green : Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget buildStrikesBadge(int strikes) {
    return Text(
      "$strikes / 3 Strikes",
      style: TextStyle(
        color: strikes >= 3 ? Colors.red : Colors.orange,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget buildEmptyState(String msg, Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          SizedBox(height: 100),
          Center(
            child: Text(msg, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  static void showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Ya"),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
