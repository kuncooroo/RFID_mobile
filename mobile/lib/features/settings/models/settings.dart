/// User preference / Settings entity from Settings screens.
class Settings {
  const Settings({
    this.languageCode = 'en',
    this.languageLabel = 'English',
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.orderUpdatesEnabled = true,
    this.promoNotificationsEnabled = true,
    this.biometricEnabled = false,
    this.twoFactorEnabled = false,
    this.currencyCode = 'USD',
  });

  final String languageCode;
  final String languageLabel;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool orderUpdatesEnabled;
  final bool promoNotificationsEnabled;
  final bool biometricEnabled;
  final bool twoFactorEnabled;
  final String currencyCode;

  Settings copyWith({
    String? languageCode,
    String? languageLabel,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? orderUpdatesEnabled,
    bool? promoNotificationsEnabled,
    bool? biometricEnabled,
    bool? twoFactorEnabled,
    String? currencyCode,
  }) {
    return Settings(
      languageCode: languageCode ?? this.languageCode,
      languageLabel: languageLabel ?? this.languageLabel,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      promoNotificationsEnabled:
          promoNotificationsEnabled ?? this.promoNotificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      languageCode: json['language_code'] as String? ?? 'en',
      languageLabel: json['language_label'] as String? ?? 'English',
      pushNotificationsEnabled:
          json['push_notifications_enabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['email_notifications_enabled'] as bool? ?? true,
      orderUpdatesEnabled: json['order_updates_enabled'] as bool? ?? true,
      promoNotificationsEnabled:
          json['promo_notifications_enabled'] as bool? ?? true,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      currencyCode: json['currency_code'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'language_label': languageLabel,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'order_updates_enabled': orderUpdatesEnabled,
      'promo_notifications_enabled': promoNotificationsEnabled,
      'biometric_enabled': biometricEnabled,
      'two_factor_enabled': twoFactorEnabled,
      'currency_code': currencyCode,
    };
  }
}

/// Selectable language option on Language settings screen.
class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.label,
    this.isSelected = false,
  });

  final String code;
  final String label;
  final bool isSelected;

  LanguageOption copyWith({String? code, String? label, bool? isSelected}) {
    return LanguageOption(
      code: code ?? this.code,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'label': label, 'is_selected': isSelected};
  }
}
