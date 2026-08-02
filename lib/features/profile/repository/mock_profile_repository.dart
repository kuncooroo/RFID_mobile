import '../../auth/models/member.dart';
import '../../settings/models/settings.dart';
import '../models/profile_snapshot.dart';
import 'profile_repository.dart';

/// Seeded profile/settings repository for tests and UI demos.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
  });

  final Duration delay;
  final bool shouldFail;

  Member _member = Member(
    id: 'mem-1',
    userId: 'local',
    displayName: 'Kutuku Member',
    email: 'member@kutuku.app',
    phone: '+1 202 555 0147',
    membershipTier: 'Gold',
    points: 1280,
    ordersCount: 12,
    favoritesCount: 4,
    followersCount: 86,
  );

  Settings _settings = const Settings();

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
  }) async {
    await Future<void>.delayed(delay);
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
    );
    return _member;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(delay);
    if (currentPassword.length < 6) {
      throw StateError('Current password is incorrect');
    }
    if (newPassword.length < 6) {
      throw StateError('New password must be at least 6 characters');
    }
  }

  @override
  Future<Settings> fetchSettings() async {
    await Future<void>.delayed(delay);
    return _settings;
  }

  @override
  Future<Settings> updateSettings(Settings settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _settings = settings;
    return _settings;
  }

  @override
  Future<List<LanguageOption>> fetchLanguages() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
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
    ];
  }
}
