import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  IconData get _icon => switch (notification.type) {
        NotificationType.order => Icons.local_shipping_outlined,
        NotificationType.promo => Icons.local_offer_outlined,
        NotificationType.payment => Icons.payments_outlined,
        NotificationType.chat => Icons.chat_bubble_outline_rounded,
        NotificationType.system => Icons.notifications_none_rounded,
      };

  Color get _iconBg => switch (notification.type) {
        NotificationType.order => AppColors.infoSoft,
        NotificationType.promo => AppColors.warningSoft,
        NotificationType.payment => AppColors.successSoft,
        NotificationType.chat => AppColors.primarySoft,
        NotificationType.system => AppColors.surfaceMuted,
      };

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final hasImage =
        notification.imageUrl != null && notification.imageUrl!.trim().isNotEmpty;

    return Material(
      color: unread
          ? AppColors.primarySoft.withValues(alpha: 0.4)
          : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                AppImage(
                  imageUrl: notification.imageUrl,
                  width: 48,
                  height: 48,
                  borderRadius: AppRadius.mdAll,
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(_icon, color: AppColors.primary, size: 22),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.badge,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (notification.body != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _formatTime(notification.createdAt!),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

/// Kept for shell chrome compatibility.
typedef ShellNotificationTile = NotificationTile;
