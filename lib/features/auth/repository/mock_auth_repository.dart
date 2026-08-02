import '../models/auth_exception.dart';
import '../models/auth_requests.dart';
import '../models/auth_result.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';
import 'auth_repository.dart';

/// In-memory auth repository for tests and UI demos.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.delay = const Duration(milliseconds: 500),
    this.shouldFailLogin = false,
    this.shouldFailRegister = false,
    this.loginErrorMessage = 'Invalid email or password',
    this.registerErrorMessage = 'Unable to create account',
  });

  final Duration delay;
  final bool shouldFailLogin;
  final bool shouldFailRegister;
  final String loginErrorMessage;
  final String registerErrorMessage;

  User? _user;
  AuthTokens? _tokens;

  @override
  Future<AuthResult> login(LoginRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);
    if (shouldFailLogin) {
      throw AuthException(loginErrorMessage, code: 'invalid_credentials');
    }
    return _persist(
      User(
        id: 'mock-user',
        name: 'Kutuku Member',
        email: request.identifier.trim(),
      ),
    );
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureName(request.name);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);
    if (shouldFailRegister) {
      throw AuthException(registerErrorMessage, code: 'register_failed');
    }
    return _persist(
      User(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        name: request.name.trim(),
        email: request.identifier.trim(),
      ),
    );
  }

  @override
  Future<AuthResult> loginWithSocial(AuthSocialProvider provider) async {
    await Future<void>.delayed(delay);
    final label = provider == AuthSocialProvider.google ? 'Google' : 'Facebook';
    return _persist(
      User(
        id: 'mock-${provider.name}',
        name: '$label User',
        email: '${provider.name}@kutuku.app',
      ),
    );
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureIdentifier(request.identifier);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);
    AuthCredentialRules.ensurePasswordMatch(
      request.password,
      request.passwordConfirmation,
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _user = null;
    _tokens = null;
  }

  @override
  Future<User?> currentUser() async => _user;

  AuthResult _persist(User user) {
    _user = user;
    _tokens = AuthTokens(
      accessToken: 'mock-token-${user.id}',
      refreshToken: 'mock-refresh-${user.id}',
    );
    return AuthResult(user: user, tokens: _tokens!);
  }
}
