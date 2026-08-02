/// Shopping member profile shown on Home greeting and Profile hub.
///
/// Distinct from [User] auth identity: carries display/membership commerce
/// fields used across Home, Messages, and Settings.
class Member {
  const Member({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.email,
    this.phone,
    this.membershipTier,
    this.points = 0,
    this.ordersCount = 0,
    this.favoritesCount = 0,
    this.followersCount = 0,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final String? membershipTier;
  final int points;
  final int ordersCount;
  final int favoritesCount;
  final int followersCount;

  String get greetingName => displayName.split(' ').first;

  Member copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? email,
    String? phone,
    String? membershipTier,
    int? points,
    int? ordersCount,
    int? favoritesCount,
    int? followersCount,
  }) {
    return Member(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      membershipTier: membershipTier ?? this.membershipTier,
      points: points ?? this.points,
      ordersCount: ordersCount ?? this.ordersCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      followersCount: followersCount ?? this.followersCount,
    );
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? json['id'].toString(),
      displayName:
          json['display_name'] as String? ?? json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      membershipTier: json['membership_tier'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'email': email,
      'phone': phone,
      'membership_tier': membershipTier,
      'points': points,
      'orders_count': ordersCount,
      'favorites_count': favoritesCount,
      'followers_count': followersCount,
    };
  }
}
