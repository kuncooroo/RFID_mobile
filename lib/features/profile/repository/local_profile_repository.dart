import 'dart:convert';

import '../../../src/storage/secure_storage_service.dart';
import '../../auth/models/member.dart';
import '../../auth/models/user.dart';
import '../../settings/models/settings.dart';
import '../models/profile_snapshot.dart';
import 'mock_profile_repository.dart';
import 'profile_repository.dart';

/// Local profile stand-in until Laravel profile/settings endpoints exist.
class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository({
    required SecureStorageService storage,
    User? currentUser,
  }) : _delegate = MockProfileRepository(),
       _storage = storage,
       _currentUser = currentUser;

  final MockProfileRepository _delegate;
  final SecureStorageService _storage;
  final User? _currentUser;

  static const _settingsKey = 'profile_settings';

  @override
  Future<ProfileSnapshot> fetchProfile() async {
    final snapshot = await _delegate.fetchProfile();
    final user = _currentUser;
    final settings = await fetchSettings();

    if (user == null) {
      return ProfileSnapshot(member: snapshot.member, settings: settings);
    }

    final member = snapshot.member.copyWith(
      userId: user.id,
      displayName: user.name.isNotEmpty
          ? user.name
          : snapshot.member.displayName,
      email: user.email.isNotEmpty ? user.email : snapshot.member.email,
      phone: user.phone ?? snapshot.member.phone,
      avatarUrl: user.avatarUrl ?? snapshot.member.avatarUrl,
    );

    return ProfileSnapshot(member: member, settings: settings);
  }

  @override
  Future<Member> updateProfile({
    required String displayName,
    required String email,
    String? phone,
  }) {
    return _delegate.updateProfile(
      displayName: displayName,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _delegate.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<Settings> fetchSettings() async {
    final raw = await _storage.read(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return _delegate.fetchSettings();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Settings.fromJson(json);
    } catch (_) {
      return const Settings();
    }
  }

  @override
  Future<Settings> updateSettings(Settings settings) async {
    await _storage.write(_settingsKey, jsonEncode(settings.toJson()));
    return _delegate.updateSettings(settings);
  }

  @override
  Future<List<LanguageOption>> fetchLanguages() => _delegate.fetchLanguages();
}
