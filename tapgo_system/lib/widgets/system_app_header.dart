import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';
import 'language_selector.dart';

/// Shared kiosk header: optional back · title · language.
class SystemAppHeader extends StatelessWidget {
  const SystemAppHeader({
    super.key,
    required this.title,
    required this.lang,
    required this.onLangChanged,
    this.onBack,
  });

  final String title;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            Material(
              color: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(color: Color(0xFFE5E5E5)),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          LanguageSelector(
            lang: lang,
            onChanged: onLangChanged,
            showFlags: true,
            compact: true,
          ),
        ],
      ),
    );
  }
}
