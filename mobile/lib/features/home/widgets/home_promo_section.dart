import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_banner.dart';
import '../../../shared/widgets/app_carousel.dart';
import '../models/promotion.dart';

class HomePromoSection extends StatelessWidget {
  const HomePromoSection({
    super.key,
    required this.promotions,
    required this.onPromotionTap,
  });

  final List<Promotion> promotions;
  final ValueChanged<Promotion> onPromotionTap;

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: AppCarousel(
        itemCount: promotions.length,
        autoPlay: promotions.length > 1,
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: AppBanner(
              title: promo.title,
              subtitle: promo.subtitle ?? promo.storeName,
              imageUrl: promo.imageUrl,
              backgroundColor: AppColors.primarySoft,
              onTap: () => onPromotionTap(promo),
            ),
          );
        },
      ),
    );
  }
}
