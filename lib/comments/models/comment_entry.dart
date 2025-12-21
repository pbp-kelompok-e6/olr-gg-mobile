// To parse this JSON data, do
//
//     final commentEntry = commentEntryFromJson(jsonString);

import 'dart:convert';

CommentEntry commentEntryFromJson(String str) => CommentEntry.fromJson(json.decode(str));

String commentEntryToJson(CommentEntry data) => json.encode(data.toJson());

class CommentEntry {
  String id;
  String newsId;
  int userId;
  String content;
  DateTime createdAt;
  DateTime? updatedAt;
  String userUsername;
  String userRole;

  CommentEntry({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.userUsername,
    required this.userRole,
  });

  factory CommentEntry.fromJson(Map<String, dynamic> json) => CommentEntry(
    id: json["id"],
    newsId: json["news_id"],
    userId: json["user_id"],
    content: json["content"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    userUsername: json["user_username"],
    userRole: json["user_role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "news_id": newsId,
    "user_id": userId,
    "content": content,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "user_username": userUsername,
    "user_role": userRole,
  };
}
