import '../../../core/storage/token_store.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.username,
    required this.expiresAt,
  });

  final String token;
  final String username;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt.toUtc());

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      username: json['username'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  factory AuthSession.fromSnapshot(TokenSnapshot snapshot) {
    return AuthSession(
      token: snapshot.token,
      username: snapshot.username,
      expiresAt: snapshot.expiresAt,
    );
  }
}
