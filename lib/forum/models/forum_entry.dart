import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) =>
    List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
  final int id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userUsername;

  ForumEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    required this.userUsername,
  });

  factory ForumEntry.fromJson(Map<String, dynamic> json) {
    return ForumEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userUsername: json['user_username'],
    );
  }

  // --- TAMBAHKAN METHOD INI ---
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "category": category,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_username": userUsername,
  };
}
