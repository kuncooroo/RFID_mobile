/// Domain error for auth flows (maps cleanly to UI messages).
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
