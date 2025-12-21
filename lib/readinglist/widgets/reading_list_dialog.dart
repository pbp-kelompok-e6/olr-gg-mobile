import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/readinglist/screens/reading_list_page.dart';

class ReadingListDialog extends StatefulWidget {
  final String newsId;
  const ReadingListDialog({super.key, required this.newsId});

  @override
  State<ReadingListDialog> createState() => _ReadingListDialogState();
}

class _ReadingListDialogState extends State<ReadingListDialog> {
  List<dynamic> userLists = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListStatus();
    });
  }

  Future<void> _fetchListStatus() async {
    final request = context.read<CookieRequest>();

    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });
    }

    try {
      final response = await request.get(
        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/api/status/${widget.newsId}/',
      );

      if (mounted) {
        setState(() {
          userLists = response;
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              e.toString().contains('SocketException') ||
                  e.toString().contains('Connection') ||
                  e.toString().contains('timeout')
              ? 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'
              : 'Terjadi kesalahan. Silakan coba lagi.';
        });
      }
    }
  }

  Future<void> _toggleList(String listId, int index) async {
    final request = context.read<CookieRequest>();
    final listName = userLists[index]['name'];
    final wasInList = userLists[index]['is_in_list'];

    // Optimistic update
    setState(() {
      userLists[index]['is_in_list'] = !userLists[index]['is_in_list'];
    });

    try {
      final response = await request.postJson(
        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/add_remove/${widget.newsId}/',
        jsonEncode({"list_id": listId}),
      );

      if (response['status'] == 'ADDED' || response['status'] == 'REMOVED') {
        if (mounted) {
          // Clear previous snackbars to prevent stacking
          ScaffoldMessenger.of(context).clearSnackBars();

          final isAdded = response['status'] == 'ADDED';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAdded ? 'Added to "$listName"' : 'Removed from "$listName"',
              ),
              backgroundColor: isAdded ? Colors.green : Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Revert on failure
        setState(() {
          userLists[index]['is_in_list'] = wasInList;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to update"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        userLists[index]['is_in_list'] = wasInList;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add to Reading List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content
            if (isLoading)
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchListStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else if (userLists.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("You don't have any reading lists yet."),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: userLists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final list = userLists[index];
                    final isInList = list['is_in_list'] == true;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isInList ? Colors.red.shade50 : Colors.white,
                        border: Border.all(
                          color: isInList
                              ? Colors.red.shade200
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              list['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isInList
                                    ? Colors.red.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () =>
                                _toggleList(list['id'].toString(), index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInList
                                  ? Colors.red.shade400
                                  : Colors.blue.shade50,
                              foregroundColor: isInList
                                  ? Colors.white
                                  : Colors.blue.shade700,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              isInList ? "REMOVE" : "ADD",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Manage Reading Lists button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to reading list page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadingListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "Manage Reading Lists",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
