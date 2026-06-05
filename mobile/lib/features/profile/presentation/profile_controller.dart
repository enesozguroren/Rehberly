import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/profile_repository.dart';
import '../data/user_profile.dart';

class RehberlyProfileController extends ChangeNotifier {
  RehberlyProfileController(this._repository);

  final ProfileRepository _repository;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _showRankOnProfile = true;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get showRankOnProfile => _showRankOnProfile;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile(String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(username);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String bio,
    required String profilePictureUrl,
    required String travelStyle,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.updateProfile(
        fullName: fullName,
        bio: bio,
        profilePictureUrl: profilePictureUrl,
        travelStyle: travelStyle,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void setRankVisibility(bool value) {
    _showRankOnProfile = value;
    notifyListeners();
  }
}
