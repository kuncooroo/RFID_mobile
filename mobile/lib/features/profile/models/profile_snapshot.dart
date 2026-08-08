import '../../auth/models/member.dart';
import '../../settings/models/settings.dart';

/// Combined profile hub payload (member + preferences).
class ProfileSnapshot {
  const ProfileSnapshot({
    required this.member,
    this.settings = const Settings(),
  });

  final Member member;
  final Settings settings;

  ProfileSnapshot copyWith({Member? member, Settings? settings}) {
    return ProfileSnapshot(
      member: member ?? this.member,
      settings: settings ?? this.settings,
    );
  }
}
