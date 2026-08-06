import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../models/order.dart';

class OrderTrackTimeline extends StatelessWidget {
  const OrderTrackTimeline({super.key, required this.events});

  final List<OrderTrackingEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text(
        'No tracking updates yet.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _TimelineTile(
            event: events[i],
            isLast: i == events.length - 1,
            showConnectorAsActive:
                events[i].isCompleted &&
                (i + 1 < events.length ? events[i + 1].isCompleted : false),
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.event,
    required this.isLast,
    required this.showConnectorAsActive,
  });

  final OrderTrackingEvent event;
  final bool isLast;
  final bool showConnectorAsActive;

  @override
  Widget build(BuildContext context) {
    final active = event.isCompleted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : AppColors.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: active
                      ? const Icon(
                          Icons.check,
                          size: 10,
                          color: AppColors.textOnPrimary,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: showConnectorAsActive
                          ? AppColors.primaryLight
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (event.description != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      event.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (event.occurredAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatDateTime(event.occurredAt!),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} · $h:$m';
  }
}
