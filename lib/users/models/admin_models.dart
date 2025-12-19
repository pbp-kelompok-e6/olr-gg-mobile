import 'package:http/http.dart';

class AdminUser {
  final int id;
  final String username;
  final String fullName;
  // final String bio;
  final String role;
  final bool isActive;
  final int strikes;
  final bool isSuperuser;
  final String profilePictureUrl;

  AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    // required this.bio,
    required this.role,
    required this.isActive,
    required this.strikes,
    required this.isSuperuser,
    required this.profilePictureUrl,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      // bio: json['bio'],
      role: json['role'],
      isActive: json['is_active'],
      strikes: json['strikes'],
      isSuperuser: json['is_superuser'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}

class AdminReport {
  final int id;
  final String createdAt;
  final String reporterUsername;
  final String reportedUsername;
  final int reportedUserId;
  final String reason;

  AdminReport({
    required this.id,
    required this.createdAt,
    required this.reporterUsername,
    required this.reportedUsername,
    required this.reportedUserId,
    required this.reason,
  });

  factory AdminReport.fromJson(Map<String, dynamic> json) {
    return AdminReport(
      id: json['id'],
      createdAt: json['created_at'],
      reporterUsername: json['reporter_username'],
      reportedUsername: json['reported_username'],
      reportedUserId: json['reported_user_id'],
      reason: json['reason'],
    );
  }
}

class AdminWriterRequest {
  final int id;
  final String createdAt;
  final String username;
  final int userId;
  final String reason;

  AdminWriterRequest({
    required this.id,
    required this.createdAt,
    required this.username,
    required this.userId,
    required this.reason,
  });

  factory AdminWriterRequest.fromJson(Map<String, dynamic> json) {
    return AdminWriterRequest(
      id: json['id'],
      createdAt: json['created_at'],
      username: json['username'],
      userId: json['user_id'],
      reason: json['reason'],
    );
  }
}