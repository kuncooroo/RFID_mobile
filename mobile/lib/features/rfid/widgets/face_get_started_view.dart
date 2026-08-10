import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import 'face_scan_brackets.dart';

/// Step 1 — Enterprise Face ID / camera scan intro.
class FaceGetStartedView extends StatelessWidget {
  const FaceGetStartedView({
    super.key,
    required this.onGetStarted,
    required this.onNotNow,
    required this.onBack,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onNotNow;
  final VoidCallback onBack;

  static const _titleColor = Color(0xFF1E1E1E);
  static const _subtitleColor = Color(0xFF6B7280);
  static const _accent = Color(0xFF5B50C6);
  static const _surface = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 24,
                    color: _titleColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Set up Face ID',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: _titleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Capture your face and tap your RFID card to verify identity',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _subtitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              AspectRatio(
                aspectRatio: 3 / 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: const Color(0xFFF3F4F6),
                          child: Center(
                            child: Icon(
                              Icons.photo_camera_front_outlined,
                              size: 56,
                              color: _accent.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final side = constraints.biggest.shortestSide;
                              return Center(
                                child: FaceScanBrackets(
                                  size: side,
                                  color: _accent,
                                  strokeWidth: 2.5,
                                  cornerLength: 28,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 16,
                          right: 16,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111827),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.nfc_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'RFID + Face capture',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onGetStarted,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Get started',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: onNotNow,
                  child: Text(
                    'Not now',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: _titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
