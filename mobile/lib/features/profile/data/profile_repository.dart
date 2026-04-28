import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import 'user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile(String username) async {
    try {
      final response = await _apiClient.profile.get<Map<String, dynamic>>(
        '/api/Profile/$username',
      );
      return UserProfile.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return UserProfile.fallback(username);
      }
      throw ApiException.fromDio(error);
    }
  }

  Future<UserProfile> updateProfile({
    required String fullName,
    required String bio,
    required String profilePictureUrl,
    required String travelStyle,
  }) async {
    try {
      final response = await _apiClient.profile.put<Map<String, dynamic>>(
        '/api/Profile',
        data: {
          'fullName': fullName.trim(),
          'bio': bio.trim(),
          'profilePictureUrl': profilePictureUrl.trim(),
          'travelStyle': travelStyle.trim(),
        },
      );

      final profile = response.data?['profile'];
      return UserProfile.fromJson(Map<String, dynamic>.from(profile as Map));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
