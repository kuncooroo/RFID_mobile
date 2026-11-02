class PresenceRecord {
  const PresenceRecord({
    required this.id,
    required this.userId,
    required this.rfidId,
    required this.locationId,
    required this.status,
    this.deviceId,
    this.photoPath,
    this.capturedAt,
  });

  final int id;
  final int userId;
  final int rfidId;
  final int locationId;
  final String status;
  final String? deviceId;
  final String? photoPath;
  final String? capturedAt;

  factory PresenceRecord.fromJson(Map<String, dynamic> json) {
    return PresenceRecord(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      rfidId: (json['rfid_id'] as num?)?.toInt() ?? 0,
      locationId: (json['location_id'] as num).toInt(),
      status: json['status']?.toString() ?? 'VERIFIED',
      deviceId: json['device_id']?.toString(),
      photoPath: json['photo_path']?.toString(),
      capturedAt: json['captured_at']?.toString(),
    );
  }
}

class CheckInRecord {
  const CheckInRecord({
    required this.id,
    required this.userId,
    required this.rfidId,
    required this.locationId,
    required this.presenceId,
    required this.status,
    required this.pointsAwarded,
    required this.pointsBalance,
    required this.alreadyCheckedInToday,
    this.duplicate = false,
    this.checkedInAt,
    this.memberName,
    this.memberCode,
    this.granted = false,
    this.amountCharged = 0,
    this.walletBalance = 0,
    this.resultCode,
    this.age,
    this.origin,
    this.gender,
  });

  final int id;
  final int userId;
  final int rfidId;
  final int locationId;
  final int presenceId;
  final String status;
  final int pointsAwarded;
  final int pointsBalance;
  final bool alreadyCheckedInToday;
  final bool duplicate;
  final String? checkedInAt;
  final String? memberName;
  final String? memberCode;
  final bool granted;
  final double amountCharged;
  final double walletBalance;
  final String? resultCode;
  final int? age;
  final String? origin;
  final String? gender;

  bool get succeeded => granted || status.toUpperCase() == 'SUCCESS';

  bool get denied =>
      resultCode == 'INSUFFICIENT_BALANCE' || status.toUpperCase() == 'DENIED';

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    final points = json['points'];
    var awarded = (json['points_awarded'] as num?)?.toInt();
    var balance = (json['points_balance'] as num?)?.toInt();
    if (points is Map) {
      awarded ??= (points['earned'] as num?)?.toInt();
      balance ??= (points['balance'] as num?)?.toInt();
    }

    final resultCode = json['result_code']?.toString().toUpperCase() ?? '';
    final duplicate =
        json['duplicate'] == true || resultCode == 'ALREADY_CHECKED_IN';
    final wallet = json['wallet'];
    final charged = (json['amount_charged'] as num?)?.toDouble() ??
        (wallet is Map ? (wallet['charged'] as num?)?.toDouble() : null) ??
        0;
    final walletBalance = (json['wallet_balance'] as num?)?.toDouble() ??
        (wallet is Map ? (wallet['balance'] as num?)?.toDouble() : null) ??
        0;
    final visitor = json['visitor'];
    final visitorMap = visitor is Map ? Map<String, dynamic>.from(visitor) : null;

    return CheckInRecord(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      rfidId: (json['rfid_id'] as num?)?.toInt() ?? 0,
      locationId: (json['location_id'] as num?)?.toInt() ?? 0,
      presenceId: (json['presence_id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'FAIL',
      pointsAwarded: awarded ?? 0,
      pointsBalance: balance ?? 0,
      alreadyCheckedInToday:
          json['already_checked_in_today'] == true || duplicate,
      duplicate: duplicate,
      checkedInAt: json['checked_in_at']?.toString(),
      memberName:
          visitorMap?['name']?.toString() ??
          json['member_name']?.toString() ??
          (json['user'] is Map ? json['user']['name']?.toString() : null),
      memberCode: json['member_code']?.toString(),
      granted: json['granted'] == true ||
          (json['status']?.toString().toUpperCase() == 'SUCCESS'),
      amountCharged: charged.toDouble(),
      walletBalance: walletBalance.toDouble(),
      resultCode: resultCode.isEmpty ? null : resultCode,
      age: (visitorMap?['age'] as num?)?.toInt(),
      origin: visitorMap?['origin']?.toString(),
      gender: visitorMap?['gender']?.toString(),
    );
  }
}
