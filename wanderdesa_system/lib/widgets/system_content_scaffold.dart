import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';
import 'system_app_header.dart';
import 'language_selector.dart';

/// Shared kiosk screen: header · scrollable body · pinned actions.
/// Keeps buttons and padding consistent so content is not clipped.
class SystemContentScaffold extends StatelessWidget {
  const SystemContentScaffold({
    super.key,
    required this.headerTitle,
    required this.lang,
    required this.onLangChanged,
    required this.body,
    this.onBack,
    this.footer,
    this.languageOnlyHeader = false,
  });

  final String headerTitle;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final Widget body;
  final VoidCallback? onBack;
  final Widget? footer;
  final bool languageOnlyHeader;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (languageOnlyHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Align(
                  alignment: Alignment.topRight,
                  child: LanguageSelector(
                    lang: lang,
                    onChanged: onLangChanged,
                    showFlags: true,
                    compact: true,
                  ),
                ),
              )
            else
              SystemAppHeader(
                title: headerTitle,
                lang: lang,
                onLangChanged: onLangChanged,
                onBack: onBack,
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      children: [
                        Expanded(child: body),
                        if (footer != null) ...[
                          const SizedBox(height: 16),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard page heading used on capture / review screens.
class SystemPageHeading extends StatelessWidget {
  const SystemPageHeading({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppColors.text,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
