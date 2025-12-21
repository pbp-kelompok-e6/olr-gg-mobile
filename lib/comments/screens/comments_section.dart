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
  final ValueNotifier<List<CommentEntry>> _commentsNotifier = ValueNotifier([]);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentsNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:8000/comments/${widget.newsId}/json/')
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
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ValueListenableBuilder<List<CommentEntry>>(
      valueListenable: _commentsNotifier,
      builder: (context, comments, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Comments (${comments.length})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            if (comments.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '💬',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No comments yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to share your thoughts!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),

                itemBuilder: (context, i) {
                  final c = comments[i];

                  return CommentEntryCard(
                    comment: c,
                    onSaveEdit: (newContent) async {
                      final request = context.read<CookieRequest>();
                      try {
                        final response = await request.postJson(
                          'http://localhost:8000/comments/${c.id}/edit_flutter/',
                          jsonEncode({'content': newContent}),
                        );

                        if (mounted) {
                          if (response['status'] == 'success') {
                            refreshComments();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comment updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update comment'),
                                backgroundColor: Colors.red,
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
                    onDelete: () async {
                      final request = context.read<CookieRequest>();
                      try {
                        final response = await request.postJson(
                            'http://localhost:8000/comments/${c.id}/delete_flutter/',
                            jsonEncode({})
                        );

                        if (mounted) {
                          if (response['status'] == 'success') {
                            refreshComments();
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