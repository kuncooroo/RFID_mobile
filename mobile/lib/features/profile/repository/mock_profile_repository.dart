import '../../auth/models/member.dart';
import '../../settings/models/settings.dart';
import '../models/profile_snapshot.dart';
import 'profile_repository.dart';

/// Seeded profile/settings repository for tests and UI demos.
///
/// Uses a shared in-memory member + settings so Local + controllers stay in sync.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
  }) {
    _sharedMember ??= Member(
      id: 'mem-1',
      userId: 'local',
      displayName: 'Alex Morgan',
      email: 'alex@kutuku.app',
      phone: '+1 202 555 0147',
      avatarUrl: 'https://picsum.photos/seed/kutuku-member/200/200',
      membershipTier: 'Gold',
      points: 1280,
      ordersCount: 12,
      favoritesCount: 4,
      followersCount: 86,
    );
    _sharedSettings ??= const Settings();
  }

  static final MockProfileRepository shared = MockProfileRepository();

  final Duration delay;
  final bool shouldFail;

  static Member? _sharedMember;
  static Settings? _sharedSettings;

  Member get _member => _sharedMember!;
  set _member(Member value) => _sharedMember = value;

  Settings get _settings => _sharedSettings!;
  set _settings(Settings value) => _sharedSettings = value;

  static void resetShared() {
    _sharedMember = null;
    _sharedSettings = null;
  }

  @override
  Future<ProfileSnapshot> fetchProfile() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load profile');
    return ProfileSnapshot(member: _member, settings: _settings);
  }

  @override
  Future<Member> updateProfile({
    required String displayName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to update profile');
    if (displayName.trim().isEmpty) {
      throw StateError('Name is required');
    }
    if (email.trim().isEmpty) {
      throw StateError('Email is required');
    }
    _member = _member.copyWith(
      displayName: displayName.trim(),
      email: email.trim(),
      phone: phone?.trim(),
      avatarUrl: avatarUrl ?? _member.avatarUrl,
    );
    return _member;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to change password');
    if (currentPassword.length < 6) {
      throw StateError('Current password is incorrect');
    }
    if (newPassword.length < 6) {
      throw StateError('New password must be at least 6 characters');
    }
    if (currentPassword == newPassword) {
      throw StateError('New password must be different from current password');
    }
  }

  @override
  Future<Settings> fetchSettings() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load settings');
    return _settings;
  }

  @override
  Future<Settings> updateSettings(Settings settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (shouldFail) throw StateError('Unable to save settings');
    _settings = settings;
    return _settings;
  }

  @override
  Future<List<LanguageOption>> fetchLanguages() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return [
      LanguageOption(
        code: 'en',
        label: 'English',
        isSelected: _settings.languageCode == 'en',
      ),
      LanguageOption(
        code: 'id',
        label: 'Bahasa Indonesia',
        isSelected: _settings.languageCode == 'id',
      ),
      LanguageOption(
        code: 'es',
        label: 'Español',
        isSelected: _settings.languageCode == 'es',
      ),
      LanguageOption(
        code: 'fr',
        label: 'Français',
        isSelected: _settings.languageCode == 'fr',
      ),
      LanguageOption(
        code: 'zh',
        label: '中文',
        isSelected: _settings.languageCode == 'zh',
      ),
      LanguageOption(
        code: 'ar',
        label: 'العربية',
        isSelected: _settings.languageCode == 'ar',
      ),
    ];
  }
}
