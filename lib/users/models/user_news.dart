// lib/models/user_news.dart

class UserNews {
  final int id;
  final String title;
  final String category;
  final String categoryDisplay;
  final String thumbnail;
  final String createdAt;
  final bool isFeatured;
  final double averageRating;

  UserNews({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryDisplay,
    required this.thumbnail,
    required this.createdAt,
    required this.isFeatured,
    required this.averageRating,
  });

  factory UserNews.fromJson(Map<String, dynamic> json) {
    return UserNews(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      categoryDisplay: json['category_display'],
      thumbnail: json['thumbnail'] ?? '',
      createdAt: json['created_at'],
      isFeatured: json['is_featured'],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }
}