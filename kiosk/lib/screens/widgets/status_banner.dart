import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

enum BannerTone { neutral, success, danger, warn }

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.neutral,
    this.showSpinner = false,
  });

  final String message;
  final BannerTone tone;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      BannerTone.success => AppColors.success,
      BannerTone.danger => AppColors.error,
      BannerTone.warn => AppColors.warning,
      BannerTone.neutral => AppColors.textSecondary,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          if (showSpinner) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: color),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
