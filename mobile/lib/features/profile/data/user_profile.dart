class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.bio,
    required this.profilePictureUrl,
    required this.travelStyle,
    required this.rankTitle,
    required this.visitedCountryCount,
    required this.visitedCityCount,
  });

  final int id;
  final String username;
  final String fullName;
  final String bio;
  final String profilePictureUrl;
  final String travelStyle;
  final String rankTitle;
  final int visitedCountryCount;
  final int visitedCityCount;

  String get displayName => fullName.trim().isEmpty ? username : fullName;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String? ?? '',
      travelStyle: json['travelStyle'] as String? ?? 'Henüz belirtilmedi',
      rankTitle: json['rankTitle'] as String? ?? 'Çaylak Kaşif',
      visitedCountryCount: (json['visitedCountryCount'] as num?)?.toInt() ?? 0,
      visitedCityCount: (json['visitedCityCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory UserProfile.fallback(String username) {
    return UserProfile(
      id: 0,
      username: username,
      fullName: username,
      bio: 'Profil bilgileri henüz senkronize edilmedi.',
      profilePictureUrl: '',
      travelStyle: 'Henüz belirtilmedi',
      rankTitle: 'Çaylak Kaşif',
      visitedCountryCount: 0,
      visitedCityCount: 0,
    );
  }
}
