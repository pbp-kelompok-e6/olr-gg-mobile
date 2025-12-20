class ForumComment {
  final int id;
  final String user;
  final String content;
  final String createdAt;

  ForumComment({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'],
      user: json['user'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}