import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/welcome_assets.dart';
import '../widgets/system_app_header.dart';
import '../widgets/system_scaffold.dart';
import '../widgets/system_card.dart';
import '../widgets/language_selector.dart';
import '../widgets/rfid_visual.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.serverOnline,
    required this.onTapMemberCard,
    required this.onRegister,
    required this.onHelp,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final bool serverOnline;
  final VoidCallback onTapMemberCard;
  final VoidCallback onRegister;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final landscape = AppSpacing.isLandscape(context);
    final stackCards = width < 720;
    const greetingSize = 18.0;
    const titleSize = 40.0;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _WelcomeBrand(),
        const SizedBox(height: 20),
        LanguageSelector(
          lang: lang,
          onChanged: onLangChanged,
          expandedLabels: true,
          showFlags: true,
        ),
        const SizedBox(height: 44),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: greetingSize,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: strings.isId
                    ? 'Halo, selamat datang di '
                    : 'Hello, Welcome to ',
              ),
              TextSpan(
                text: strings.brand,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          strings.whatToday,
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          style: TextStyle(
            fontSize: landscape ? 32 : titleSize,
            height: 1.06,
            letterSpacing: -1.2,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 40),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: stackCards
              ? Column(
                  children: [
                    _WelcomeActionCard(
                      assetPath: WelcomeAssets.tapMemberCard,
                      title: strings.tapMemberCard,
                      body: strings.tapMemberCardBody,
                      onTap: serverOnline ? onTapMemberCard : null,
                    ),
                    const SizedBox(height: 20),
                    _WelcomeActionCard(
                      assetPath: WelcomeAssets.register,
                      title: strings.registerCardTitle,
                      body: strings.registerCardBody,
                      onTap: serverOnline ? onRegister : null,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _WelcomeActionCard(
                        assetPath: WelcomeAssets.tapMemberCard,
                        title: strings.tapMemberCard,
                        body: strings.tapMemberCardBody,
                        onTap: serverOnline ? onTapMemberCard : null,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _WelcomeActionCard(
                        assetPath: WelcomeAssets.register,
                        title: strings.registerCardTitle,
                        body: strings.registerCardBody,
                        onTap: serverOnline ? onRegister : null,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 26),
        Text(
          strings.orDivider,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF777777),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        _WelcomeHelpButton(label: strings.needAssistance, onPressed: onHelp),
        if (!serverOnline) ...[
          const SizedBox(height: 12),
          Text(
            strings.systemOffline,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return SystemScaffold(
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewH = constraints.maxHeight;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewH),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeBrand extends StatelessWidget {
  const _WelcomeBrand();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'TapGo',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.primary,
      ),
    );
  }
}

class _WelcomeActionCard extends StatefulWidget {
  const _WelcomeActionCard({
    required this.assetPath,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String assetPath;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  State<_WelcomeActionCard> createState() => _WelcomeActionCardState();
}

class _WelcomeActionCardState extends State<_WelcomeActionCard> {
  static const _radius = 26.0;

  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final titleSize = 28.0;
    final bodySize = 16.0;
    final artH = 120.0;
    final padV = 28.0;
    final padH = 24.0;
    final lift = _hovered && !_pressed ? -2.0 : 0.0;
    final scale = _pressed ? 0.985 : 1.0;
    final cardElevation = _hovered && !_pressed && widget.onTap != null
        ? 1.0
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, lift, 0),
            child: SystemCard(
              elevation: cardElevation,
              borderRadius: BorderRadius.circular(_radius),
              padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: artH,
                    width: double.infinity,
                    child: Center(
                      child: _WelcomeCardArt(
                        assetPath: widget.assetPath,
                        height: artH - 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleSize,
                      height: 1.1,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 290),
                    child: Text(
                      widget.body,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: bodySize,
                        height: 1.4,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCardArt extends StatelessWidget {
  const _WelcomeCardArt({required this.assetPath, required this.height});

  final String assetPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, error, stackTrace) {
        if (!WelcomeAssets.showPlaceholderLabels) {
          return const SizedBox.shrink();
        }
        return const Text(
          'IMAGE / SVG',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8A8F8E),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        );
      },
    );
  }
}

class _WelcomeHelpButton extends StatefulWidget {
  const _WelcomeHelpButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_WelcomeHelpButton> createState() => _WelcomeHelpButtonState();
}

class _WelcomeHelpButtonState extends State<_WelcomeHelpButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 140),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _hovered
                      ? AppColors.primaryDark
                      : const Color(0xFF666666),
                ),
                child: Text(widget.label, textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RfidAwaitPage extends StatelessWidget {
  const RfidAwaitPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.serverOnline,
    required this.verifying,
    required this.registerFlow,
    required this.onCancel,
    this.scannerController,
    this.onDetect,
    this.showScanner = false,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final bool serverOnline;
  final bool verifying;
  final bool registerFlow;
  final VoidCallback onCancel;
  final MobileScannerController? scannerController;
  final void Function(BarcodeCapture capture)? onDetect;
  final bool showScanner;

  @override
  Widget build(BuildContext context) {
    final pageTitle = registerFlow
        ? strings.scanPageTitleRegister
        : strings.scanPageTitleVisit;
    final statusLabel = !serverOnline
        ? strings.systemOffline
        : verifying
        ? strings.readingCard
        : strings.waitingCard;

    return Stack(
      fit: StackFit.expand,
      children: [
        const _ScanAnimatedBackground(),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SystemAppHeader(
                title: pageTitle,
                lang: lang,
                onLangChanged: onLangChanged,
                onBack: onCancel,
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (showScanner &&
                        scannerController != null &&
                        onDetect != null)
                      IgnorePointer(
                        child: Opacity(
                          opacity: 0.02,
                          child: MobileScanner(
                            controller: scannerController!,
                            onDetect: onDetect!,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const RfidScanIllustration(),
                                  const SizedBox(height: 8),
                                  Text(
                                    strings.scanInstructionTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      height: 1.15,
                                      letterSpacing: -1.2,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 640),
                                    child: Text(
                                      strings.scanInstructionSubtitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.5,
                                        color: Color(0xFF858585),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    statusLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: !serverOnline
                                          ? AppColors.error
                                          : AppColors.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Soft pulsing circles behind the scan screen content.
class _ScanAnimatedBackground extends StatefulWidget {
  const _ScanAnimatedBackground();

  @override
  State<_ScanAnimatedBackground> createState() =>
      _ScanAnimatedBackgroundState();
}

class _ScanAnimatedBackgroundState extends State<_ScanAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 1.2,
          colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA), Color(0xFFF5F6F6)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ScanCirclesPainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ScanCirclesPainter extends CustomPainter {
  _ScanCirclesPainter({required this.progress});

  final double progress;

  static const _ringCount = 4;
  static const _color = AppColors.primary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.38);
    final maxRadius = size.shortestSide * 0.72;

    for (var i = 0; i < _ringCount; i++) {
      final phase = (progress + i / _ringCount) % 1.0;
      final radius = maxRadius * (0.18 + phase * 0.82);
      final opacity = (1 - phase).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = _color.withValues(alpha: 0.11 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 + (1 - phase) * 0.8;

      canvas.drawCircle(center, radius, paint);

      if (phase < 0.35) {
        final fill = Paint()
          ..color = _color.withValues(alpha: 0.025 * (1 - phase / 0.35));
        canvas.drawCircle(center, radius, fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScanCirclesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
