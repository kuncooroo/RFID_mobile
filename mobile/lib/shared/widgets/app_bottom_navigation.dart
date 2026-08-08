import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';
import 'app_badge.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badgeCount,
    this.showDot = false,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final int? badgeCount;
  final bool showDot;
}

/// Bottom navigation with optional center FAB slot (RFID scan).
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.hasCenterFab = false,
  }) : assert(items.length >= 2, 'Provide at least 2 navigation items.');

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// When true, inserts a gap in the middle for a center-docked FAB.
  final bool hasCenterFab;

  @override
  Widget build(BuildContext context) {
    final mid = items.length ~/ 2;

    return BottomAppBar(
      color: AppColors.bottomNavBackground,
      elevation: 12,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      shape: hasCenterFab ? const CircularNotchedRectangle() : null,
      notchMargin: hasCenterFab ? 8 : 0,
      height: AppSizes.bottomNavHeight,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (hasCenterFab && i == mid)
              const SizedBox(width: AppSizes.fabDockGap),
            Expanded(
              child: _NavItemTile(
                item: items[i],
                selected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navActive : AppColors.navInactive;
    final iconData = selected ? (item.activeIcon ?? item.icon) : item.icon;

    final icon = Icon(iconData, size: AppSizes.iconMd, color: color);
    final badged = (item.showDot || (item.badgeCount ?? 0) > 0)
        ? AppBadge(
            count: item.badgeCount,
            showDot: item.showDot && (item.badgeCount == null),
            child: icon,
          )
        : icon;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          badged,
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bottomNavLabel.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
