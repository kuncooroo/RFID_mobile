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
    MockProfileRepository? delegate,
  })  : _delegate = delegate ?? MockProfileRepository.shared,
        _storage = storage,
        _currentUser = currentUser;

  final MockProfileRepository _delegate;
  final SecureStorageService _storage;
  final User? _currentUser;

  static const _settingsKey = 'profile_settings';
  static const _memberKey = 'profile_member_overrides';

  @override
  Future<ProfileSnapshot> fetchProfile() async {
    final snapshot = await _delegate.fetchProfile();
    final settings = await fetchSettings();
    final overrides = await _readMemberOverrides();
    final user = _currentUser;

    var member = snapshot.member;
    if (overrides != null) {
      member = member.copyWith(
        displayName: overrides['display_name'] as String? ?? member.displayName,
        email: overrides['email'] as String? ?? member.email,
        phone: overrides['phone'] as String? ?? member.phone,
        avatarUrl: overrides['avatar_url'] as String? ?? member.avatarUrl,
      );
    }

    if (user != null) {
      member = member.copyWith(
        userId: user.id,
        displayName: overrides?['display_name'] as String? ??
            (user.name.isNotEmpty ? user.name : member.displayName),
        email: overrides?['email'] as String? ??
            (user.email.isNotEmpty ? user.email : member.email),
        phone: overrides?['phone'] as String? ?? user.phone ?? member.phone,
        avatarUrl: overrides?['avatar_url'] as String? ??
            user.avatarUrl ??
            member.avatarUrl,
      );
    }

    return ProfileSnapshot(member: member, settings: settings);
  }

  @override
  Future<Member> updateProfile({
    required String displayName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    final member = await _delegate.updateProfile(
      displayName: displayName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    await _storage.write(
      _memberKey,
      jsonEncode({
        'display_name': member.displayName,
        'email': member.email,
        'phone': member.phone,
        'avatar_url': member.avatarUrl,
      }),
    );
    return member;
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
      final settings = Settings.fromJson(json);
      await _delegate.updateSettings(settings);
      return settings;
    } catch (_) {
      return _delegate.fetchSettings();
    }
  }

  @override
  Future<Settings> updateSettings(Settings settings) async {
    await _storage.write(_settingsKey, jsonEncode(settings.toJson()));
    return _delegate.updateSettings(settings);
  }

  @override
  Future<List<LanguageOption>> fetchLanguages() => _delegate.fetchLanguages();

  Future<Map<String, dynamic>?> _readMemberOverrides() async {
    final raw = await _storage.read(_memberKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
