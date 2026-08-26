/// Shipping / billing address used on Address and Checkout screens.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isDefault = false,
    this.notes,
  });

  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String street;
  final String city;
  final String? state;
  final String? postalCode;
  final String? country;
  final bool isDefault;
  final String? notes;

  String get fullAddress {
    final parts = [
      street,
      city,
      if (state != null && state!.isNotEmpty) state,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode,
      if (country != null && country!.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  /// Compact label for order receipts / tracking.
  String get oneLineLabel => '$recipientName · $fullAddress';

  Address copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    String? notes,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      notes: notes ?? this.notes,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    final line1 = json['line1'] as String?;
    final line2 = json['line2'] as String?;
    final street = json['street'] as String? ??
        json['address'] as String? ??
        [if (line1 != null && line1.isNotEmpty) line1, if (line2 != null && line2.isNotEmpty) line2]
            .join(', ');

    return Address(
      id: json['id'].toString(),
      label: json['label'] as String? ?? 'Home',
      recipientName:
          json['recipient_name'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: street,
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String? ?? json['zip'] as String?,
      country: json['country'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      notes: json['notes'] as String? ?? line2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'street': street,
      'line1': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
      'notes': notes,
    };
  }

  /// Payload accepted by Laravel `StoreAddressRequest`.
  Map<String, dynamic> toApiPayload() {
    return {
      'label': label,
      'recipient_name': recipientName,
      'phone': phone,
      'line1': street,
      if (notes != null && notes!.trim().isNotEmpty) 'line2': notes!.trim(),
      'city': city,
      if (state != null && state!.trim().isNotEmpty) 'state': state,
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        'postal_code': postalCode,
      if (country != null && country!.trim().isNotEmpty) 'country': country,
      'is_default': isDefault,
    };
  }
}

/// Form input for creating / updating a shipping address.
class AddressInput {
  const AddressInput({
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.city,
    this.state,
    this.postalCode,
    this.country = 'US',
    this.isDefault = false,
    this.notes,
  });

  final String label;
  final String recipientName;
  final String phone;
  final String street;
  final String city;
  final String? state;
  final String? postalCode;
  final String? country;
  final bool isDefault;
  final String? notes;

  Map<String, dynamic> toApiPayload() {
    return {
      'label': label.trim(),
      'recipient_name': recipientName.trim(),
      'phone': phone.trim(),
      'line1': street.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'line2': notes!.trim(),
      'city': city.trim(),
      if (state != null && state!.trim().isNotEmpty) 'state': state!.trim(),
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        'postal_code': postalCode!.trim(),
      if (country != null && country!.trim().isNotEmpty) 'country': country!.trim(),
      'is_default': isDefault,
    };
  }
}
