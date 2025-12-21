import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReadingListDialog extends StatefulWidget {
  final String newsId;
  const ReadingListDialog({super.key, required this.newsId});

  @override
  State<ReadingListDialog> createState() => _ReadingListDialogState();
}

class _ReadingListDialogState extends State<ReadingListDialog> {
  List<dynamic> userLists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListStatus();
    });
  }

  Future<void> _fetchListStatus() async {
    final request = context.read<CookieRequest>();
    try {
      // Use localhost or 10.0.2.2 depending on your device
      final response = await request.get(
        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/api/status/${widget.newsId}/',
      );

      if (mounted) {
        setState(() {
          userLists = response;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleList(String listId, int index) async {
    final request = context.read<CookieRequest>();
    // Optimistic update
    setState(() {
      userLists[index]['is_in_list'] = !userLists[index]['is_in_list'];
    });

    try {
      final response = await request.postJson(
        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/readinglist/add_remove/${widget.newsId}/',
        jsonEncode({"list_id": listId}),
      );

      if (response['status'] != 'ADDED' && response['status'] != 'REMOVED') {
        // Revert on failure
        setState(() {
          userLists[index]['is_in_list'] = !userLists[index]['is_in_list'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Failed to update")),
          );
        }
      }
    } catch (e) {
      // Revert on error
      setState(() {
        userLists[index]['is_in_list'] = !userLists[index]['is_in_list'];
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save to Reading List"),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : userLists.isEmpty
            ? const Text("You don't have any reading lists yet.")
            : ListView.builder(
                shrinkWrap: true,
                itemCount: userLists.length,
                itemBuilder: (context, index) {
                  final list = userLists[index];
                  return CheckboxListTile(
                    title: Text(list['name']),
                    value: list['is_in_list'],
                    activeColor: Colors.blue,
                    onChanged: (bool? value) {
                      _toggleList(list['id'], index);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Done"),
        ),
      ],
    );
  }
}
