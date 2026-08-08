import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../state/home_state.dart';

/// Home / Category segment switcher from the Kutuku homescreen.
class HomeSegmentTabs extends StatelessWidget {
  const HomeSegmentTabs({
    super.key,
    required this.segment,
    required this.onChanged,
  });

  final HomeSegment segment;
  final ValueChanged<HomeSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: 'Home',
                selected: segment == HomeSegment.home,
                onTap: () => onChanged(HomeSegment.home),
              ),
            ),
            Expanded(
              child: _SegmentButton(
                label: 'Category',
                selected: segment == HomeSegment.category,
                onTap: () => onChanged(HomeSegment.category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
