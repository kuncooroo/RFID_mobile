import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../auth/models/member.dart';
import '../../settings/models/settings.dart';
import '../models/profile_snapshot.dart';
import 'profile_repository.dart';

class RemoteProfileRepository implements ProfileRepository {
  RemoteProfileRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<ProfileSnapshot> fetchProfile() async {
    final user = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.user,
      parser: _asMap,
    );
    final memberJson = user['member'];
    final settingsJson = user['settings'];

    final member = memberJson is Map
        ? Member.fromJson({
            ...Map<String, dynamic>.from(memberJson),
            'email': user['email'],
            'phone': user['phone'],
            'avatar_url': user['avatar_url'],
            'user_id': user['id'],
          })
        : Member(
            id: user['id'].toString(),
            userId: user['id'].toString(),
            displayName: user['name']?.toString() ?? '',
            email: user['email']?.toString(),
            phone: user['phone']?.toString(),
            avatarUrl: user['avatar_url']?.toString(),
          );

    final settings = settingsJson is Map
        ? Settings.fromJson(Map<String, dynamic>.from(settingsJson))
        : const Settings();

    return ProfileSnapshot(member: member, settings: settings);
  }

  @override
  Future<Member> updateProfile({
    required String displayName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.userProfile,
      data: {
        'name': displayName,
        'email': email,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_path': avatarUrl,
      },
      parser: _asMap,
    );
    final memberJson = user['member'];
    if (memberJson is Map) {
      return Member.fromJson({
        ...Map<String, dynamic>.from(memberJson),
        'email': user['email'],
        'phone': user['phone'],
        'avatar_url': user['avatar_url'],
        'user_id': user['id'],
      });
    }
    return Member(
      id: user['id'].toString(),
      userId: user['id'].toString(),
      displayName: user['name']?.toString() ?? displayName,
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      avatarUrl: user['avatar_url']?.toString(),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.put<dynamic>(
      ApiEndpoints.userPassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  @override
  Future<Settings> fetchSettings() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.userSettings,
      parser: _asMap,
    );
    return Settings.fromJson(data);
  }

  @override
  Future<Settings> updateSettings(Settings settings) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.userSettings,
      data: settings.toJson(),
      parser: _asMap,
    );
    return Settings.fromJson(data);
  }

  @override
  Future<List<LanguageOption>> fetchLanguages() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.languages,
      parser: (d) {
        if (d is! List) return <Map<String, dynamic>>[];
        return d
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    return list
        .map(
          (e) => LanguageOption(
            code: e['code']?.toString() ?? 'en',
            label: e['label']?.toString() ?? 'English',
          ),
        )
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
