class GateExperience {
  const GateExperience({
    required this.id,
    required this.locationName,
    required this.checkedInAt,
    required this.amountCharged,
    required this.pointsAwarded,
    required this.hasPhoto,
    this.balanceAfter,
  });

  final int id;
  final String locationName;
  final DateTime? checkedInAt;
  final double amountCharged;
  final int pointsAwarded;
  final bool hasPhoto;
  final double? balanceAfter;

  factory GateExperience.fromJson(Map<String, dynamic> json) {
    final rawTime = json['checked_in_at']?.toString();
    return GateExperience(
      id: (json['id'] as num).toInt(),
      locationName: json['location_name']?.toString() ?? 'Gate',
      checkedInAt: rawTime == null ? null : DateTime.tryParse(rawTime),
      amountCharged: (json['amount_charged'] as num?)?.toDouble() ?? 0,
      pointsAwarded: (json['points_awarded'] as num?)?.toInt() ?? 0,
      hasPhoto: json['has_photo'] == true,
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
    );
  }
}
