import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_image.dart';

/// Full-bleed product image gallery with overlay page dots (Detail / Detail v2).
class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.imageUrls,
    this.heroHeight = AppSizes.productDetailHeroHeight,
  });

  final List<String> imageUrls;
  final double heroHeight;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: widget.heroHeight,
        width: double.infinity,
        child: const AppImage(
          assetPath: AppAssets.placeholderProduct,
          borderRadius: BorderRadius.zero,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      height: widget.heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider.builder(
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index, _) {
              return AppImage(
                imageUrl: widget.imageUrls[index],
                borderRadius: BorderRadius.zero,
                fit: BoxFit.cover,
                width: double.infinity,
                height: widget.heroHeight,
              );
            },
            options: CarouselOptions(
              height: widget.heroHeight,
              viewportFraction: 1,
              enableInfiniteScroll: widget.imageUrls.length > 1,
              enlargeCenterPage: false,
              padEnds: false,
              onPageChanged: (index, _) => setState(() => _index = index),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.xxl + AppSpacing.md,
              child: Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _index,
                  count: widget.imageUrls.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: AppSizes.pageDot,
                    dotWidth: AppSizes.pageDot,
                    expansionFactor:
                        AppSizes.pageDotActiveWidth / AppSizes.pageDot,
                    spacing: AppSpacing.sm,
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
