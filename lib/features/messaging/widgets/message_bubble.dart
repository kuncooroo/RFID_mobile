import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primarySoft : AppColors.surfaceMuted,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isMine ? AppRadius.lg : AppRadius.xs),
                  bottomRight: Radius.circular(isMine ? AppRadius.xs : AppRadius.lg),
                ),
                border: isMine
                    ? Border.all(color: AppColors.primaryLight.withValues(alpha: 0.45))
                    : null,
              ),
              child: Text(
                message.body,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMine ? AppColors.textPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            if (message.sentAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatBubbleTime(message.sentAt!),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBubbleTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
