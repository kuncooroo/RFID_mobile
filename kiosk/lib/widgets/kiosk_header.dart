import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class KioskLogo extends StatelessWidget {
  const KioskLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 56.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.md,
            boxShadow: AppShadows.card,
          ),
          alignment: Alignment.center,
          child: Text(
            'K',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 20 : 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Text(
          'KUTUKU',
          style: TextStyle(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class KioskHeader extends StatelessWidget {
  const KioskHeader({super.key, this.trailing, this.compact = true});

  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KioskLogo(compact: compact),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}
