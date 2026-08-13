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
