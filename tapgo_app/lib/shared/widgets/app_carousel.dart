import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';

/// Horizontal carousel with page dots for Home promos and product galleries.
class AppCarousel extends StatefulWidget {
  const AppCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = AppSizes.promoCarouselHeight,
    this.viewportFraction = 1,
    this.enableInfiniteScroll = true,
    this.autoPlay = false,
    this.showIndicator = true,
    this.onPageChanged,
    this.padEnds = true,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final double height;
  final double viewportFraction;
  final bool enableInfiniteScroll;
  final bool autoPlay;
  final bool showIndicator;
  final ValueChanged<int>? onPageChanged;
  final bool padEnds;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: widget.itemCount,
          itemBuilder: (context, index, _) {
            return widget.itemBuilder(context, index) ??
                const SizedBox.shrink();
          },
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: widget.viewportFraction,
            enableInfiniteScroll:
                widget.enableInfiniteScroll && widget.itemCount > 1,
            autoPlay: widget.autoPlay && widget.itemCount > 1,
            enlargeCenterPage: false,
            padEnds: widget.padEnds,
            onPageChanged: (index, _) {
              setState(() => _index = index);
              widget.onPageChanged?.call(index);
            },
          ),
        ),
        if (widget.showIndicator && widget.itemCount > 1) ...[
          const SizedBox(height: AppSpacing.md),
          AnimatedSmoothIndicator(
            activeIndex: _index,
            count: widget.itemCount,
            effect: ExpandingDotsEffect(
              dotHeight: AppSizes.pageDot,
              dotWidth: AppSizes.pageDot,
              expansionFactor: AppSizes.pageDotActiveWidth / AppSizes.pageDot,
              spacing: AppSpacing.sm,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.borderStrong,
            ),
          ),
        ],
      ],
    );
  }
}
