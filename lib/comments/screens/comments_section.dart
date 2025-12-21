// dart
import 'package:flutter/material.dart';
import 'package:olrggmobile/comments/models/comment_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:olrggmobile/comments/widgets/comment_entry_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class CommentsSection extends StatefulWidget {
  final String newsId;
  const CommentsSection({Key? key, required this.newsId}) : super(key: key);

  @override
  CommentsSectionState createState() => CommentsSectionState();
}

class CommentsSectionState extends State<CommentsSection> {
  String? _editingCommentId;
  final _editFormKey = GlobalKey<FormState>();
  final _editController = TextEditingController();
  final ValueNotifier<List<CommentEntry>> _commentsNotifier = ValueNotifier([]);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _editController.dispose();
    _commentsNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/${widget.newsId}/json/',
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        final comments = body
            .map((dynamic item) => CommentEntry.fromJson(item))
            .toList();
        comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _commentsNotifier.value = comments;
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading comments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void refreshComments() {
    _editingCommentId = null;
    _loadComments();
  }

  void _startEditing(CommentEntry comment) {
    setState(() {
      _editingCommentId = comment.id;
      _editController.text = comment.content;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingCommentId = null;
      _editController.clear();
    });
  }

  Future<void> _saveEdit(String commentId) async {
    if (!_editFormKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    final response = await request.postJson(
      'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/$commentId/edit_flutter/',
      jsonEncode({'content': _editController.text}),
    );

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        refreshComments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEditForm(CommentEntry comment) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        border: Border.all(color: Colors.blue.shade600, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _editFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Comment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancelEditing,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _editController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Edit your comment...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Comment cannot be empty'
                  : null,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _saveEdit(comment.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ValueListenableBuilder<List<CommentEntry>>(
      valueListenable: _commentsNotifier,
      builder: (context, comments, _) {
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No comments yet.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final c = comments[i];
                if (_editingCommentId == c.id) {
                  return _buildEditForm(c);
                }

                return CommentEntryCard(
                  comment: c,
                  onEdit: () => _startEditing(c),
                  onDelete: () async {
                    final request = context.read<CookieRequest>();
                    try {
                      final response = await request.postJson(
                        'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/${c.id}/delete_flutter/',
                        jsonEncode({}),
                      );

                      if (mounted) {
                        if (response['status'] == 'success') {
                          refreshComments(); // Only updates comments section
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comment deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
