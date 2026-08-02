import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/widgets/app_carousel.dart';
import '../../../shared/widgets/app_image.dart';

/// Product image gallery with carousel dots.
class ProductGallery extends StatelessWidget {
  const ProductGallery({
    super.key,
    required this.imageUrls,
    this.heroHeight = AppSizes.productDetailHeroHeight,
  });

  final List<String> imageUrls;
  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return SizedBox(
        height: heroHeight,
        child: const AppImage(
          assetPath: AppAssets.placeholderProduct,
          fit: BoxFit.cover,
        ),
      );
    }

    return AppCarousel(
      itemCount: imageUrls.length,
      height: heroHeight,
      enableInfiniteScroll: false,
      padEnds: false,
      itemBuilder: (context, index) {
        return AppImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}
