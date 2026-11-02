import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';
import 'system_app_header.dart';
import 'language_selector.dart';
import 'primary_button.dart';

enum AlertTone { warning, error, success, muted, brand }

enum AlertBadgeKind { close, check }

/// Shared alert / status screen: header · illustration · copy · actions.
class AlertStatusLayout extends StatelessWidget {
  const AlertStatusLayout({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.title,
    required this.body,
    required this.tone,
    required this.icon,
    required this.primaryLabel,
    required this.onPrimary,
    this.headerTitle,
    this.onBack,
    this.secondaryLabel,
    this.onSecondary,
    this.badge,
    this.bodyExtra,
    this.languageOnlyHeader = false,
    this.hidePrimary = false,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final String title;
  final String body;
  final AlertTone tone;
  final IconData icon;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? headerTitle;
  final VoidCallback? onBack;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final AlertBadgeKind? badge;
  final Widget? bodyExtra;
  /// When true: top-right language only (no back / title).
  final bool languageOnlyHeader;
  /// When true: hide the primary action button.
  final bool hidePrimary;

  Color get _accent {
    switch (tone) {
      case AlertTone.warning:
        return AppColors.warning;
      case AlertTone.error:
        return AppColors.error;
      case AlertTone.success:
        return AppColors.success;
      case AlertTone.muted:
        return AppColors.statusMuted;
      case AlertTone.brand:
        return AppColors.primary;
    }
  }

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
                title: headerTitle ?? title,
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
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _AlertStatusVisual(
                                  accent: _accent,
                                  icon: icon,
                                  badge: badge,
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    height: 1.2,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF20242C),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 520),
                                  child: Text(
                                    body,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.5,
                                      color: Color(0xFF74777D),
                                    ),
                                  ),
                                ),
                                if (bodyExtra != null) ...[
                                  const SizedBox(height: 24),
                                  bodyExtra!,
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (!hidePrimary) ...[
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: primaryLabel,
                            onPressed: onPrimary,
                          ),
                        ],
                        if (secondaryLabel != null && onSecondary != null) ...[
                          SizedBox(height: hidePrimary ? 20 : 12),
                          SecondaryButton(
                            label: secondaryLabel!,
                            onPressed: onSecondary,
                          ),
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

class _AlertStatusVisual extends StatelessWidget {
  const _AlertStatusVisual({
    required this.accent,
    required this.icon,
    this.badge,
  });

  final Color accent;
  final IconData icon;
  final AlertBadgeKind? badge;

  @override
  Widget build(BuildContext context) {
    const size = 280.0;
    const circle = 140.0;
    const badgeSize = 48.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(size, accent.withValues(alpha: 0.04)),
          _ring(size * 0.78, accent.withValues(alpha: 0.06)),
          _ring(size * 0.58, accent.withValues(alpha: 0.08)),
          Container(
            width: circle,
            height: circle,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icon, size: 72, color: Colors.white),
          ),
          if (badge != null)
            Positioned(
              right: (size - circle) / 2 - 4,
              bottom: (size - circle) / 2 + 10,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  badge == AlertBadgeKind.check
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  size: badgeSize * 0.55,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ring(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
