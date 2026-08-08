import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/splash_statistic.dart';

/// Statistics marketing intro (Figma `1:18`).
class StatisticsIntroView extends StatefulWidget {
  const StatisticsIntroView({
    super.key,
    required this.statistics,
    this.onGetStarted,
  });

  final List<SplashStatistic> statistics;
  final VoidCallback? onGetStarted;

  @override
  State<StatisticsIntroView> createState() => _StatisticsIntroViewState();
}

class _StatisticsIntroViewState extends State<StatisticsIntroView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.statistics.isEmpty
        ? kDefaultSplashStatistics
        : widget.statistics;

    return ColoredBox(
      color: AppColors.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDEBFA),
              AppColors.background,
              AppColors.background,
            ],
            stops: [0, 0.42, 1],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Kutuku',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    const _HeroVisual(),
                    const SizedBox(height: AppSpacing.xxxl),
                    Text(
                      'Shop smarter.\nLive better.',
                      style: AppTextStyles.displayMedium.copyWith(
                        height: 1.15,
                        letterSpacing: -0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Discover curated fashion, trusted stores, and seamless checkout in one place.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    _StatisticsRow(statistics: stats),
                    const Spacer(flex: 2),
                    AppButton(
                      label: 'Get Started',
                      onPressed: widget.onGetStarted,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft.withValues(alpha: 0.65),
            ),
          ),
          Container(
            width: 176,
            height: 176,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: AppImage(
              assetPath: AppAssets.statisticsHero,
              width: 176,
              height: 176,
              fit: BoxFit.cover,
              errorWidget: AppImage(
                assetPath: AppAssets.splash,
                width: 176,
                height: 176,
                fit: BoxFit.cover,
                errorWidget: const Icon(
                  Icons.shopping_bag_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsRow extends StatelessWidget {
  const _StatisticsRow({required this.statistics});

  final List<SplashStatistic> statistics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.xlAll,
      ),
      child: Row(
        children: [
          for (var i = 0; i < statistics.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 40, color: AppColors.divider),
            Expanded(child: _StatCell(statistic: statistics[i])),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.statistic});

  final SplashStatistic statistic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          statistic.value,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          statistic.label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
