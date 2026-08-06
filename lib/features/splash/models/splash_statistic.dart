/// Marketing statistic shown on the Splash / Statistics intro (Figma `1:18`).
class SplashStatistic {
  const SplashStatistic({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final String? icon;

  factory SplashStatistic.fromJson(Map<String, dynamic> json) {
    return SplashStatistic(
      value: json['value']?.toString() ?? '',
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      'icon': icon,
    };
  }
}

/// Seed copy for the Statistics intro screen.
const kDefaultSplashStatistics = <SplashStatistic>[
  SplashStatistic(value: '50K+', label: 'Products'),
  SplashStatistic(value: '1.2K+', label: 'Brands'),
  SplashStatistic(value: '98%', label: 'Happy buyers'),
];
