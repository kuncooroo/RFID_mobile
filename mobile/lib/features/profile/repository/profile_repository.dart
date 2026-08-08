import '../../auth/models/member.dart';
import '../../settings/models/settings.dart';
import '../models/profile_snapshot.dart';

/// Contract for My Profile + Settings preference operations.
abstract class ProfileRepository {
  Future<ProfileSnapshot> fetchProfile();

  Future<Member> updateProfile({
    required String displayName,
    required String email,
    String? phone,
    String? avatarUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Settings> fetchSettings();

  Future<Settings> updateSettings(Settings settings);

  Future<List<LanguageOption>> fetchLanguages();
}
