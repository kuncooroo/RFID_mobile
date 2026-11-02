class SystemUser {
  const SystemUser({
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.age,
    this.origin,
    this.gender,
    this.points = 0,
    this.balance = 0,
  });

  final int userId;
  final String name;
  final String? email;
  final String? phone;
  final int? age;
  final String? origin;
  final String? gender;
  final int points;
  final double balance;

  bool get hasProfile =>
      name.trim().isNotEmpty &&
      age != null &&
      age! > 0 &&
      (origin ?? '').trim().isNotEmpty &&
      (gender == 'male' || gender == 'female');

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      userId: (json['user_id'] as num).toInt(),
      name: json['name']?.toString() ?? 'Pengunjung',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      age: (json['age'] as num?)?.toInt(),
      origin: json['origin']?.toString(),
      gender: json['gender']?.toString(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

enum RfidLookupCode {
  memberFound,
  cardReady,
  rfidNotRegistered,
  rfidInactive,
  rfidInvalid,
  serverError,
}

enum RfidCardStatus { unregistered, registered, inactive, invalid, error }

class RfidLookup {
  const RfidLookup({
    required this.status,
    required this.resultCode,
    required this.rfidUid,
    this.memberCode,
    this.isActive,
    this.cardStatus,
    this.user,
    this.rfidMemberId,
    this.message,
    this.faceEnrolled = false,
    this.needsFaceEnrollment = false,
    this.balance = 0,
    this.fareAmount = 0,
    this.canEnter = false,
  });

  final RfidCardStatus status;
  final RfidLookupCode resultCode;
  final String rfidUid;
  final String? memberCode;
  final bool? isActive;
  final String? cardStatus;
  final SystemUser? user;
  final int? rfidMemberId;
  final String? message;
  final bool faceEnrolled;
  final bool needsFaceEnrollment;
  final double balance;
  final double fareAmount;
  final bool canEnter;

  bool get isRegistered =>
      resultCode == RfidLookupCode.memberFound && user != null;

  /// Issued card, with or without a linked identity.
  bool get canUseGate =>
      resultCode == RfidLookupCode.memberFound ||
      resultCode == RfidLookupCode.cardReady;

  factory RfidLookup.fromJson(Map<String, dynamic> json, {String? message}) {
    final resultCode = _parseResultCode(
      json['result_code']?.toString(),
      json['status']?.toString(),
    );
    final status = switch (resultCode) {
      RfidLookupCode.memberFound ||
      RfidLookupCode.cardReady => RfidCardStatus.registered,
      RfidLookupCode.rfidNotRegistered => RfidCardStatus.unregistered,
      RfidLookupCode.rfidInactive => RfidCardStatus.inactive,
      RfidLookupCode.rfidInvalid => RfidCardStatus.invalid,
      RfidLookupCode.serverError => RfidCardStatus.error,
    };

    SystemUser? user;
    final userJson = json['user'];
    if (userJson is Map) {
      user = SystemUser.fromJson(Map<String, dynamic>.from(userJson));
    }

    final faceEnrolled = json['face_enrolled'] == true;
    final needsEnrollment = json['needs_face_enrollment'] == true;

    return RfidLookup(
      status: status,
      resultCode: resultCode,
      rfidUid: json['rfid_uid']?.toString() ?? '',
      memberCode: json['member_code']?.toString(),
      isActive: json['is_active'] as bool?,
      cardStatus: json['card_status']?.toString(),
      user: user,
      rfidMemberId: (json['rfid_member_id'] as num?)?.toInt(),
      message: message,
      faceEnrolled: faceEnrolled,
      needsFaceEnrollment: needsEnrollment,
      balance: (json['balance'] as num?)?.toDouble() ?? user?.balance ?? 0,
      fareAmount: (json['fare_amount'] as num?)?.toDouble() ?? 0,
      canEnter: json['can_enter'] == true,
    );
  }
}

/// Bound member used for photo upload (legacy verify payload).
class SystemMember {
  const SystemMember({
    required this.userId,
    required this.name,
    required this.rfidUid,
    required this.memberCode,
    required this.rfidMemberId,
  });

  final int userId;
  final String name;
  final String rfidUid;
  final String memberCode;
  final int rfidMemberId;

  factory SystemMember.fromLookup(RfidLookup lookup) {
    final user = lookup.user;
    if (user == null) {
      throw StateError('Lookup has no bound user');
    }
    return SystemMember(
      userId: user.userId,
      name: user.name,
      rfidUid: lookup.rfidUid,
      memberCode: lookup.memberCode ?? '',
      rfidMemberId: lookup.rfidMemberId ?? 0,
    );
  }

  factory SystemMember.fromJson(Map<String, dynamic> json) {
    return SystemMember(
      userId: (json['user_id'] as num).toInt(),
      name: json['name']?.toString() ?? 'Pengunjung',
      rfidUid: json['rfid_uid']?.toString() ?? '',
      memberCode: json['member_code']?.toString() ?? '',
      rfidMemberId: (json['rfid_member_id'] as num?)?.toInt() ?? 0,
    );
  }
}

RfidLookupCode _parseResultCode(String? code, String? status) {
  final raw = (code ?? '').toUpperCase();
  if (raw.isNotEmpty) {
    return switch (raw) {
      'MEMBER_FOUND' => RfidLookupCode.memberFound,
      'CARD_READY' => RfidLookupCode.cardReady,
      'RFID_NOT_REGISTERED' => RfidLookupCode.rfidNotRegistered,
      'RFID_INACTIVE' => RfidLookupCode.rfidInactive,
      'RFID_INVALID' => RfidLookupCode.rfidInvalid,
      _ => RfidLookupCode.serverError,
    };
  }
  return switch ((status ?? '').toLowerCase()) {
    'registered' => RfidLookupCode.memberFound,
    'issued' => RfidLookupCode.cardReady,
    'unregistered' => RfidLookupCode.rfidNotRegistered,
    'inactive' => RfidLookupCode.rfidInactive,
    'invalid' => RfidLookupCode.rfidInvalid,
    _ => RfidLookupCode.serverError,
  };
}

class RegisterDraft {
  const RegisterDraft({
    required this.name,
    this.email,
    this.phone,
    this.age,
    this.origin,
    this.gender,
  });

  final String name;
  final String? email;
  final String? phone;
  final int? age;
  final String? origin;
  final String? gender;
}
