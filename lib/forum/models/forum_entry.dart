import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) =>
    List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
  int id;
  String title;
  String content;
  String userUsername;
  String category;
  DateTime createdAt;

  ForumEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.userUsername,
    required this.category,
    required this.createdAt,
  });

  factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    userUsername: json["user_username"],
    category: json["category"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "user_username": userUsername,
    "category": category,
    "created_at": createdAt.toIso8601String(),
  };
}
