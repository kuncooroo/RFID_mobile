import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class KioskLogo extends StatelessWidget {
  const KioskLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.md,
            boxShadow: AppShadows.card,
          ),
          alignment: Alignment.center,
          child: const Text(
            'K',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'KUTUKU',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class KioskHeader extends StatelessWidget {
  const KioskHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const KioskLogo(),
        if (trailing != null) ...[
          const SizedBox(height: 20),
          trailing!,
        ],
      ],
    );
  }
}
