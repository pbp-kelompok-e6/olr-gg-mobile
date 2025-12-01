// To parse this JSON data, do
//
//     final productEntry = productEntryFromJson(jsonString);

import 'dart:convert';

List<NewsEntry> newsEntryFromJson(String str) => List<NewsEntry>.from(json.decode(str).map((x) => NewsEntry.fromJson(x)));

String newsEntryToJson(List<NewsEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsEntry {
  String id;
  String title;
  String content;
  String thumbnail;
  String category;
  bool isFeatured;
  DateTime createdAt;
  String userId;
  String userUsername;

  NewsEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.thumbnail,
    required this.category,
    required this.isFeatured,
    required this.createdAt,
    required this.userId,
    required this.userUsername
  });

  factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    thumbnail: json["thumbnail"] ?? "",
    category: json["category"],
    isFeatured: json["is_featured"],
    createdAt: DateTime.parse(json["created_at"]),
    userUsername: json["user_username"],
    userId: json["user_id"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "thumbnail": thumbnail,
    "category": category,
    "is_featured": isFeatured,
    "created_at": createdAt.toIso8601String(),
    "user_id": userId,
    "user_username": userUsername,
  };
}