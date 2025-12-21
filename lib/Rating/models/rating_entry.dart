// To parse this JSON data, do
//
//     final ratingEntry = ratingEntryFromJson(jsonString);

import 'dart:convert';

List<RatingEntry> ratingEntryFromJson(String str) =>
    List<RatingEntry>.from(json.decode(str).map((x) => RatingEntry.fromJson(x)));

String ratingEntryToJson(List<RatingEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RatingEntry {
  dynamic id;  // Can be int or String depending on backend
  int rating;  // Rating score (1-5)
  String review;  // Review text
  DateTime createdAt;
  String userUsername;
  bool canEdit;

  RatingEntry({
    required this.id,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.userUsername,
    required this.canEdit,
  });

  factory RatingEntry.fromJson(Map<String, dynamic> json) => RatingEntry(
    id: json['id'],
    rating: json['rating'],
    review: json['review'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
    userUsername: json['user_username'],
    canEdit: json['can_edit'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'rating': rating,
    'review': review,
    'created_at': createdAt.toIso8601String(),
    'user_username': userUsername,
    'can_edit': canEdit,
  };
}