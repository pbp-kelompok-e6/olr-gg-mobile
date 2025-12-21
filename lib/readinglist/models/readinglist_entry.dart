

import 'dart:convert';


List<ReadingListEntry> readingListEntryFromJson(String str) => List<ReadingListEntry>.from(json.decode(str).map((x) => ReadingListEntry.fromJson(x)));

String readingListEntryToJson(List<ReadingListEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReadingListEntry {
  String id;
  String name;
  List<Item> items;

  ReadingListEntry({
    required this.id,
    required this.name,
    required this.items,
  });

  factory ReadingListEntry.fromJson(Map<String, dynamic> json) => ReadingListEntry(
    id: json["id"],
    name: json["name"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  int id;
  bool isRead;
  News news;

  Item({
    required this.id,
    required this.isRead,
    required this.news,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    isRead: json["is_read"],
    news: News.fromJson(json["news"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_read": isRead,
    "news": news.toJson(),
  };
}

class News {
  String id;
  String title;
  String thumbnail;
  String category;
  DateTime createdAt;
  String content;
  String userUsername;
  int userId;

  News({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.category,
    required this.createdAt,
    required this.content,
    required this.userUsername,
    required this.userId,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json["id"],
    title: json["title"],
    thumbnail: json["thumbnail"],
    category: json["category"],
    createdAt: DateTime.parse(json["created_at"]),
    content: json["content"],
    userUsername: json["user_username"],
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "thumbnail": thumbnail,
    "category": category,
    "created_at": createdAt.toIso8601String(),
    "content": content,
    "user_username": userUsername,
    "user_id": userId,
  };
}
