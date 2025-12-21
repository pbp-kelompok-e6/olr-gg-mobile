import 'package:flutter/material.dart';
import 'package:olrggmobile/models/news_entry.dart';
import 'package:olrggmobile/Rating/screens/ratings_section.dart';
import 'package:olrggmobile/comments/screens/comments_section.dart';
import 'package:olrggmobile/comments/screens/comment_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/readinglist/widgets/reading_list_dialog.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsEntry news;

  const NewsDetailPage({super.key, required this.news});

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'basketball':
        return Colors.orange.shade600;
      case 'soccer':
        return Colors.green.shade600;
      case 'football':
        return Colors.blue.shade600;
      case 'hockey':
        return Colors.cyan.shade600;
      case 'volleyball':
        return Colors.purple.shade600;
      case 'baseball':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getCategoryTextColor(String category) => Colors.white;
  Color _getFeaturedBg() => Colors.yellow.shade100;
  Color _getFeaturedBorder() => Colors.yellow.shade300;
  Color _getFeaturedText() => Colors.yellow.shade800;

  @override
  Widget build(BuildContext context) {
    final commentsSectionKey = GlobalKey<CommentsSectionState>();
    final request = context.watch<CookieRequest>(); // Akses request
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('News Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (news.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getFeaturedBg(),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getFeaturedBorder()),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Featured',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getFeaturedText(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(news.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              news.category[0].toUpperCase() +
                                  news.category.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getCategoryTextColor(news.category),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (news.thumbnail.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(news.thumbnail)}',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(news.createdAt),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            news.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.red],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Written by',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                news.userUsername,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        if (!request.loggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please login to save news."),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                ReadingListDialog(newsId: news.id),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.bookmark_add_outlined,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Ratings Section
                RatingsSection(newsId: news.id),
              ],
            ),
            CommentForm(
              newsId: news.id,
              onCommentAdded: () {
                commentsSectionKey.currentState?.refreshComments();
              },
            ),
            CommentsSection(key: commentsSectionKey, newsId: news.id)
          ],
          ),)
        ),
      ),
    );
  }
}
