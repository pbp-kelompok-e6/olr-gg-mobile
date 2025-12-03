class UserProfile {
  final int id;
  final String username;
  final String fullName;
  final String bio;
  final String role;
  final int strikes;
  final String dateJoined;
  final String profilePictureUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.bio,
    required this.role,
    required this.strikes,
    required this.dateJoined,
    required this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'] == "" ? json['username'] : json['full_name'],
      bio: json['bio'] ?? "-",
      role: json['role'],
      strikes: json['strikes'],
      dateJoined: json['date_joined'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}