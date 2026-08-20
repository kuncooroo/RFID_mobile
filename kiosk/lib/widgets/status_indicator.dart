import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SystemStatus { ready, processing, offline, error }

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    required this.label,
  });

  final SystemStatus status;
  final String label;

  Color get _color => switch (status) {
        SystemStatus.ready => AppColors.success,
        SystemStatus.processing => AppColors.warning,
        SystemStatus.offline => AppColors.error,
        SystemStatus.error => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
