import 'auth_tokens.dart';
import 'user.dart';

/// Successful authentication payload.
class AuthResult {
  const AuthResult({required this.user, required this.tokens});

  final User user;
  final AuthTokens tokens;

  AuthResult copyWith({User? user, AuthTokens? tokens}) {
    return AuthResult(user: user ?? this.user, tokens: tokens ?? this.tokens);
  }

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;
    final tokenJson = json['token'] as Map<String, dynamic>? ?? json;
    return AuthResult(
      user: User.fromJson(userJson),
      tokens: AuthTokens.fromJson(tokenJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': tokens.toJson(),
  };
}
