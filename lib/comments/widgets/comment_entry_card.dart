import 'package:flutter/material.dart';
import 'package:olrggmobile/comments/models/comment_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:olrggmobile/screens/menu.dart';



class CommentEntryCard extends StatelessWidget {
  final CommentEntry comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const CommentEntryCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    // Simple date formatter without intl package
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currentUser = request.jsonData["user_username"];
    final role = request.jsonData["role"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Card(
          color: Colors.yellow[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.shade200),
          ),
          elevation: 4,
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  ]),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children:[
                        Text(
                          comment.userUsername ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (comment.userRole == 'admin') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                        if (comment.userRole == 'writer') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Writer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                    children: [
                        Text(
                          _formatDate(comment.createdAt),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (comment.updatedAt!= null)
                          Text(
                            " (edited)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ]),
                    const SizedBox(height: 8),
                    Text(
                      comment.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (comment.userUsername == currentUser || role == "admin")
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: onEdit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete Comment"),
                                        content: const Text("Are you sure you want to delete this comment? This action cannot be undone."),
                                        actions: [
                                          TextButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            onPressed: () => Navigator.pop(context, true),
                                          ),
                                          TextButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                            child: const Text("Cancel",
                                              style: TextStyle(color: Colors.white),),
                                            onPressed: () => Navigator.pop(context, false),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldDelete == true) {
                                    onDelete?.call();
                                  }
                                },
                              )
                            ],
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}