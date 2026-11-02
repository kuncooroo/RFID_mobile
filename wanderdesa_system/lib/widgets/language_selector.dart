import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';

/// Shared ID/EN switch — same blue brand look on idle and headers.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.lang,
    required this.onChanged,
    this.expandedLabels = false,
    this.showFlags = false,
    this.compact = false,
  });

  final SystemLang lang;
  final ValueChanged<SystemLang> onChanged;
  final bool expandedLabels;
  final bool showFlags;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 3 : 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(
            SystemLang.id,
            expandedLabels ? 'Indonesia' : 'ID',
            flag: showFlags ? '🇮🇩' : null,
          ),
          _chip(
            SystemLang.en,
            expandedLabels ? 'English' : 'EN',
            flag: showFlags ? '🇬🇧' : null,
          ),
        ],
      ),
    );
  }

  Widget _chip(SystemLang value, String label, {String? flag}) {
    final active = lang == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : (expandedLabels ? 16 : 14),
          vertical: compact ? 7 : (expandedLabels ? 10 : 8),
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 9 : 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag != null) ...[
              Text(flag, style: TextStyle(fontSize: compact ? 14 : 16)),
              SizedBox(width: compact ? 5 : 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: compact ? 13 : (expandedLabels ? 15 : 13),
                color: active ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
