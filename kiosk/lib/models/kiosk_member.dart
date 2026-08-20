class KioskUser {
  const KioskUser({
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.points = 0,
  });

  final int userId;
  final String name;
  final String? email;
  final String? phone;
  final int points;

  factory KioskUser.fromJson(Map<String, dynamic> json) {
    return KioskUser(
      userId: (json['user_id'] as num).toInt(),
      name: json['name']?.toString() ?? 'Pengunjung',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}

enum RfidLookupCode {
  memberFound,
  rfidNotRegistered,
  rfidInactive,
  rfidInvalid,
  serverError,
}

enum RfidCardStatus {
  unregistered,
  registered,
  inactive,
  invalid,
  error,
}

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
  });

  final RfidCardStatus status;
  final RfidLookupCode resultCode;
  final String rfidUid;
  final String? memberCode;
  final bool? isActive;
  final String? cardStatus;
  final KioskUser? user;
  final int? rfidMemberId;
  final String? message;

  bool get isRegistered =>
      resultCode == RfidLookupCode.memberFound && user != null;

  factory RfidLookup.fromJson(Map<String, dynamic> json, {String? message}) {
    final resultCode = _parseResultCode(
      json['result_code']?.toString(),
      json['status']?.toString(),
    );
    final status = switch (resultCode) {
      RfidLookupCode.memberFound => RfidCardStatus.registered,
      RfidLookupCode.rfidNotRegistered => RfidCardStatus.unregistered,
      RfidLookupCode.rfidInactive => RfidCardStatus.inactive,
      RfidLookupCode.rfidInvalid => RfidCardStatus.invalid,
      RfidLookupCode.serverError => RfidCardStatus.error,
    };

    KioskUser? user;
    final userJson = json['user'];
    if (userJson is Map) {
      user = KioskUser.fromJson(Map<String, dynamic>.from(userJson));
    }

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
    );
  }
}

/// Bound member used for photo upload (legacy verify payload).
class KioskMember {
  const KioskMember({
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

  factory KioskMember.fromLookup(RfidLookup lookup) {
    final user = lookup.user;
    if (user == null) {
      throw StateError('Lookup has no bound user');
    }
    return KioskMember(
      userId: user.userId,
      name: user.name,
      rfidUid: lookup.rfidUid,
      memberCode: lookup.memberCode ?? '',
      rfidMemberId: lookup.rfidMemberId ?? 0,
    );
  }

  factory KioskMember.fromJson(Map<String, dynamic> json) {
    return KioskMember(
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
      'RFID_NOT_REGISTERED' => RfidLookupCode.rfidNotRegistered,
      'RFID_INACTIVE' => RfidLookupCode.rfidInactive,
      'RFID_INVALID' => RfidLookupCode.rfidInvalid,
      _ => RfidLookupCode.serverError,
    };
  }
  return switch ((status ?? '').toLowerCase()) {
    'registered' => RfidLookupCode.memberFound,
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
  });

  final String name;
  final String? email;
  final String? phone;
}
