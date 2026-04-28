import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/auth_session.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._repository);

  final AuthRepository _repository;

  AuthSession? _session;
  bool _isBootstrapping = true;
  bool _isBusy = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isBootstrapping => _isBootstrapping;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _session != null && !_session!.isExpired;
  String? get errorMessage => _errorMessage;

  Future<void> bootstrap() async {
    _isBootstrapping = true;
    notifyListeners();

    _session = await _repository.restoreSession();

    _isBootstrapping = false;
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _runAuthAction(() async {
      _session = await _repository.login(
        username: username,
        password: password,
      );
    });
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() async {
      await _repository.register(
        username: username,
        email: email,
        password: password,
      );
      _session = await _repository.login(
        username: username,
        password: password,
      );
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    _session = null;
    notifyListeners();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
