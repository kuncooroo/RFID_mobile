import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_icon.dart';

/// Shell top bar used by Home and other tab roots.
class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAppBar({
    super.key,
    this.title,
    this.greeting,
    this.leading,
    this.onSearch,
    this.onNotifications,
    this.onCart,
    this.unreadNotifications = 0,
    this.showActions = true,
  });

  final String? title;
  final String? greeting;
  final Widget? leading;
  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final VoidCallback? onCart;
  final int unreadNotifications;
  final bool showActions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppSpacing.screenHorizontal,
      title:
          leading ??
          (greeting != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (title != null)
                      Text(title!, style: AppTextStyles.headlineSmall),
                  ],
                )
              : (title == null
                    ? null
                    : Text(title!, style: AppTextStyles.headlineSmall))),
      actions: showActions
          ? [
              if (onSearch != null)
                IconButton(
                  tooltip: 'Search',
                  onPressed: onSearch,
                  icon: const AppIcon.data(Icons.search_rounded),
                ),
              if (onNotifications != null)
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: onNotifications,
                  icon: AppBadge(
                    count: unreadNotifications > 0 ? unreadNotifications : null,
                    child: const AppIcon.data(Icons.notifications_none_rounded),
                  ),
                ),
              if (onCart != null)
                IconButton(
                  tooltip: 'Cart',
                  onPressed: onCart,
                  icon: const AppIcon.data(Icons.shopping_bag_outlined),
                ),
              const SizedBox(width: AppSpacing.sm),
            ]
          : null,
    );
  }
}
