import 'package:flutter/material.dart';
import 'package:olrggmobile/Rating/models/rating_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class RatingEntryCard extends StatelessWidget {
  final RatingEntry rating;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const RatingEntryCard({
    super.key,
    required this.rating,
    required this.onDelete,
    required this.onEdit,
  });

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[200],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.userUsername,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                if (rating.canEdit)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: Colors.blue[700],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        color: Colors.red[700],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Konfirmasi Hapus"),
                                content: const Text("Apakah Anda yakin ingin menghapus rating ini?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Batal"),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Hapus"),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete == true) {
                            onDelete();
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Rating Stars
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.rating ? Icons.star : Icons.star_border,
                  color: Colors.yellow[700],
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 8),
            // Review Text
            Text(
              rating.review,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Date
            Text(
              _formatDate(rating.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

