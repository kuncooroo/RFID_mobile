import '../../../shared/design_system/app_assets.dart';

/// Single onboarding carousel slide.
class OnboardingPageData {
  const OnboardingPageData({
    required this.id,
    required this.title,
    required this.description,
    required this.illustrationAsset,
  });

  final String id;
  final String title;
  final String description;
  final String illustrationAsset;

  OnboardingPageData copyWith({
    String? id,
    String? title,
    String? description,
    String? illustrationAsset,
  }) {
    return OnboardingPageData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      illustrationAsset: illustrationAsset ?? this.illustrationAsset,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'illustrationAsset': illustrationAsset,
  };

  factory OnboardingPageData.fromJson(Map<String, dynamic> json) {
    return OnboardingPageData(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      illustrationAsset: json['illustrationAsset'] as String,
    );
  }
}

/// Default Kutuku onboarding copy (Figma screens 1–3).
abstract final class OnboardingPages {
  static const List<OnboardingPageData> defaults = [
    OnboardingPageData(
      id: 'collections',
      title: 'Various Collections Of The Latest Products',
      description:
          'Urna amet, suspendisse ullamcorper ac elit diam facilisis cursus vestibulum.',
      illustrationAsset: AppAssets.onboarding1,
    ),
    OnboardingPageData(
      id: 'favorites',
      title: 'Complete Collection Of Top Products',
      description:
          'Urna amet, suspendisse ullamcorper ac elit diam facilisis cursus vestibulum.',
      illustrationAsset: AppAssets.onboarding2,
    ),
    OnboardingPageData(
      id: 'choice',
      title: 'Find The Best Choice For You',
      description:
          'Urna amet, suspendisse ullamcorper ac elit diam facilisis cursus vestibulum.',
      illustrationAsset: AppAssets.onboarding3,
    ),
  ];
}
