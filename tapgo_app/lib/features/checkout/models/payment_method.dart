/// Saved card / payment method from Payment screens.
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    this.holderName,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.type = PaymentMethodType.card,
  });

  final String id;
  final String brand;
  final String last4;
  final String? holderName;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
  final PaymentMethodType type;

  String get maskedNumber => '•••• •••• •••• $last4';

  String? get expiryLabel {
    if (expiryMonth == null || expiryYear == null) return null;
    final month = expiryMonth!.toString().padLeft(2, '0');
    final yearStr = expiryYear!.toString();
    final year = yearStr.length > 2
        ? yearStr.substring(yearStr.length - 2)
        : yearStr.padLeft(2, '0');
    return '$month/$year';
  }

  PaymentMethod copyWith({
    String? id,
    String? brand,
    String? last4,
    String? holderName,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
    PaymentMethodType? type,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      holderName: holderName ?? this.holderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'].toString(),
      brand: json['brand'] as String? ?? json['card_brand'] as String? ?? '',
      last4: json['last4'] as String? ?? json['last_four'] as String? ?? '',
      holderName: json['holder_name'] as String?,
      expiryMonth: (json['expiry_month'] as num?)?.toInt(),
      expiryYear: (json['expiry_year'] as num?)?.toInt(),
      isDefault: json['is_default'] as bool? ?? false,
      type: PaymentMethodType.fromJson(json['type'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'last4': last4,
      'holder_name': holderName,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      'type': type.toJson(),
    };
  }
}

enum PaymentMethodType {
  card,
  wallet,
  bank,
  other;

  static PaymentMethodType fromJson(String? value) {
    return PaymentMethodType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethodType.card,
    );
  }

  String toJson() => name;
}
