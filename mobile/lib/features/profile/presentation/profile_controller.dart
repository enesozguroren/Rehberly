import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/profile_repository.dart';
import '../data/user_profile.dart';

class RehberlyProfileController extends ChangeNotifier {
  RehberlyProfileController(this._repository);

  final ProfileRepository _repository;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
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
}
