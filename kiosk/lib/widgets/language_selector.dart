import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.lang,
    required this.onChanged,
    this.expandedLabels = false,
    this.showFlags = false,
    this.compact = false,
  });

  final KioskLang lang;
  final ValueChanged<KioskLang> onChanged;
  final bool expandedLabels;
  final bool showFlags;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 2 : 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 9 : 14),
        border: Border.all(color: AppColors.border),
        boxShadow: compact
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(
            KioskLang.id,
            expandedLabels ? 'Indonesia' : 'ID',
            flag: showFlags ? '🇮🇩' : null,
          ),
          _chip(
            KioskLang.en,
            expandedLabels ? 'English' : 'EN',
            flag: showFlags ? '🇬🇧' : null,
          ),
        ],
      ),
    );
  }

  Widget _chip(KioskLang value, String label, {String? flag}) {
    final active = lang == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : (expandedLabels ? 16 : 14),
          vertical: compact ? 6 : (expandedLabels ? 10 : 8),
        ),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 7 : 10),
          boxShadow: active && !compact
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag != null) ...[
              Text(flag, style: TextStyle(fontSize: compact ? 12 : 16)),
              SizedBox(width: compact ? 4 : 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : (expandedLabels ? 15 : 13),
                color: active
                    ? const Color(0xFF111111)
                    : const Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
