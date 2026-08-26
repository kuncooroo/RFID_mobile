/// Sanctum-style token pair returned by login / register.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken:
          json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
  };
}
