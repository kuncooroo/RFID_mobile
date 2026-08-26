import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shared kiosk page chrome: SafeArea + max width + horizontal padding.
/// Prefer [SystemPageShell] for normal screens with bottom actions.
class SystemScaffold extends StatelessWidget {
  const SystemScaffold({
    super.key,
    required this.child,
    this.dark = false,
    this.backgroundColor,
    this.horizontalPadding,
    this.verticalPadding,
  });

  final Widget child;
  final bool dark;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final padding = horizontalPadding ?? AppSpacing.pagePadding(context);
    final maxWidth = AppSpacing.maxContentWidth(context);
    final vPad =
        verticalPadding ??
        (AppSpacing.isCompactHeight(context) ? padding * 0.35 : padding * 0.55);

    return ColoredBox(
      color: dark
          ? const Color(0xFF111111)
          : (backgroundColor ?? AppColors.background),
      child: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: AppTypography.textTheme(context).apply(
              bodyColor: dark ? Colors.white : AppColors.text,
              displayColor: dark ? Colors.white : AppColors.text,
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: vPad,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Consistent vertical page structure for kiosk screens:
///
/// ```text
/// [optional header]
/// [main content — scrolls when needed]
/// [flexible remaining space]
/// [bottom action area]
/// ```
class SystemPageShell extends StatelessWidget {
  const SystemPageShell({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.dark = false,
    this.maxContentWidth,
    this.footerTopGap = 16,
    this.scrollBody = true,
  });

  final Widget body;
  final Widget? header;
  final Widget? footer;
  final bool dark;
  final double? maxContentWidth;
  final double footerTopGap;
  final bool scrollBody;

  @override
  Widget build(BuildContext context) {
    final readable = maxContentWidth ?? AppSpacing.maxReadableWidth(context);

    return SystemScaffold(
      dark: dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            header!,
            SizedBox(height: AppSpacing.vGap(context, 16, min: 10, max: 16)),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: readable),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: scrollBody
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  primary: true,
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: body,
                                  ),
                                );
                              },
                            )
                          : body,
                    ),
                    if (footer != null) ...[
                      SizedBox(height: footerTopGap),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action block: step indicator + primary + secondary.
class SystemActionArea extends StatelessWidget {
  const SystemActionArea({
    super.key,
    this.leading,
    required this.primary,
    this.secondary,
    this.gap = 8,
  });

  final Widget? leading;
  final Widget primary;
  final Widget? secondary;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading != null) ...[leading!, SizedBox(height: gap + 8)],
        primary,
        if (secondary != null) ...[SizedBox(height: gap), secondary!],
      ],
    );
  }
}

