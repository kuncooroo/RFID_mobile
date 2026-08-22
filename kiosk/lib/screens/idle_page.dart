import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/welcome_assets.dart';
import '../widgets/kiosk_scaffold.dart';
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final bool serverOnline;
  final VoidCallback onTapMemberCard;
  final VoidCallback onRegister;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final landscape = AppSpacing.isLandscape(context);
    final shortScreen = AppSpacing.isCompactHeight(context);
    // Side-by-side only with enough width and height.
    final stackCards = width < 720 || (landscape && height < 700);

    final afterLangGap = AppSpacing.vGap(context, 44, min: 20, max: 50);
    final afterHeadingGap = AppSpacing.vGap(context, 40, min: 20, max: 44);
    final greetingSize =
        AppSpacing.scale(context, 18).clamp(15.0, 20.0).toDouble();
    final titleSize = AppSpacing.scale(context, 48)
        .clamp(landscape ? 28.0 : 32.0, landscape ? 44.0 : 58.0)
        .toDouble();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _WelcomeBrand(),
        SizedBox(height: AppSpacing.vGap(context, 20, min: 12, max: 20)),
        LanguageSelector(
          lang: lang,
          onChanged: onLangChanged,
          expandedLabels: true,
          showFlags: true,
        ),
        SizedBox(height: afterLangGap),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: greetingSize,
              color: const Color(0xFF222222),
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
            fontSize: titleSize,
            height: 1.06,
            letterSpacing: -1.2,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: afterHeadingGap),
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
                    SizedBox(
                      height: AppSpacing.vGap(context, 20, min: 12, max: 20),
                    ),
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
                    SizedBox(
                      width: AppSpacing.vGap(context, 28, min: 14, max: 28),
                    ),
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
        SizedBox(height: AppSpacing.vGap(context, 26, min: 16, max: 26)),
        Text(
          strings.orDivider,
          style: TextStyle(
            fontSize: AppSpacing.scale(context, 20).clamp(16.0, 22.0),
            color: const Color(0xFF777777),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.vGap(context, 14, min: 10, max: 14)),
        _WelcomeHelpButton(
          label: strings.needAssistance,
          onPressed: onHelp,
        ),
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

    return KioskScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewH = constraints.maxHeight;
          final topPad =
              shortScreen ? 8.0 : (viewH * 0.06).clamp(16.0, 64.0);
          final bottomPad =
              shortScreen ? 12.0 : (viewH * 0.09).clamp(20.0, 80.0);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewH),
              child: Padding(
                padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
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
    final width = MediaQuery.sizeOf(context).width;
    final wordSize = (width * 0.035).clamp(26.0, 42.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: CustomPaint(painter: _KutukuMarkPainter()),
        ),
        const SizedBox(width: 14),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: wordSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: const Color(0xFF111111),
            ),
            children: const [
              TextSpan(
                text: 'KUTU',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(text: 'KU'),
            ],
          ),
        ),
      ],
    );
  }
}

class _KutukuMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = AppColors.primary;

    final path1 = Path()
      ..moveTo(size.width * 0.61, size.height * 0.19)
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.19,
        size.width * 0.86,
        size.height * 0.30,
        size.width * 0.86,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.63,
        size.width * 0.70,
        size.height * 0.78,
        size.width * 0.52,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.37,
        size.height * 0.78,
        size.width * 0.24,
        size.height * 0.69,
        size.width * 0.19,
        size.height * 0.55,
      );
    canvas.drawPath(path1, stroke);

    final path2 = Path()
      ..moveTo(size.width * 0.27, size.height * 0.55)
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.44,
        size.width * 0.34,
        size.height * 0.36,
        size.width * 0.45,
        size.height * 0.36,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.36,
        size.width * 0.67,
        size.height * 0.45,
        size.width * 0.67,
        size.height * 0.58,
      )
      ..cubicTo(
        size.width * 0.67,
        size.height * 0.72,
        size.width * 0.56,
        size.height * 0.83,
        size.width * 0.42,
        size.height * 0.83,
      );
    canvas.drawPath(path2, stroke);
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.48),
      4,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final titleSize =
        AppSpacing.scale(context, 30).clamp(20.0, 34.0).toDouble();
    final bodySize =
        AppSpacing.scale(context, 17).clamp(14.0, 18.0).toDouble();
    final artH =
        AppSpacing.scale(context, 128).clamp(84.0, 140.0).toDouble();
    final padV = AppSpacing.vGap(context, 26, min: 16, max: 26);
    final padH = AppSpacing.vGap(context, 22, min: 14, max: 22);
    final lift = _hovered && !_pressed ? -2.0 : 0.0;
    final scale = _pressed ? 0.985 : 1.0;

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
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.025),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.055),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.045),
                  blurRadius: 48,
                  offset: Offset(0, 24),
                ),
              ],
            ),
            child: Padding(
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
                  SizedBox(
                    height: AppSpacing.vGap(context, 18, min: 10, max: 18),
                  ),
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
                      ? const Color(0xFF0F6663)
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
    required this.onHelp,
    this.scannerController,
    this.onDetect,
    this.showScanner = false,
  });

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final bool serverOnline;
  final bool verifying;
  final bool registerFlow;
  final VoidCallback onCancel;
  final VoidCallback onHelp;
  final MobileScannerController? scannerController;
  final void Function(BarcodeCapture capture)? onDetect;
  final bool showScanner;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 640;
    final state = !serverOnline
        ? RfidScanState.error
        : verifying
            ? RfidScanState.processing
            : RfidScanState.ready;
    final pageTitle =
        registerFlow ? strings.scanPageTitleRegister : strings.scanPageTitleVisit;
    final statusLabel = !serverOnline
        ? strings.systemOffline
        : verifying
            ? strings.readingCard
            : strings.waitingCard;
    final hPad = narrow ? 18.0 : 34.0;
    final titleSize =
        AppSpacing.scale(context, narrow ? 19 : 22).clamp(17.0, 22.0);
    final h1Size =
        AppSpacing.scale(context, 23).clamp(18.0, 24.0);
    final subSize =
        AppSpacing.scale(context, 16).clamp(13.0, 16.0);

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScanHeader(
                  title: pageTitle,
                  titleSize: titleSize,
                  lang: lang,
                  onLangChanged: onLangChanged,
                  onBack: onCancel,
                  onHelp: onHelp,
                  horizontalPadding: narrow ? 18 : 28,
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
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          narrow ? 20 : 28,
                          hPad,
                          narrow ? 30 : 40,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                narrow ? 16 : 28,
                                narrow ? 22 : 26,
                                narrow ? 16 : 28,
                                narrow ? 16 : 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE7E7E7),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0E000000),
                                    blurRadius: 30,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    strings.scanInstructionTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: h1Size,
                                      height: 1.25,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    strings.scanInstructionSubtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: subSize,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _ScanStatusBadge(
                                    label: statusLabel,
                                    animate: serverOnline,
                                  ),
                                  const SizedBox(height: 20),
                                  RfidScanArea(
                                    strings: strings,
                                    state: state,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _ScanGuideBox(strings: strings, narrow: narrow),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanHeader extends StatelessWidget {
  const _ScanHeader({
    required this.title,
    required this.titleSize,
    required this.lang,
    required this.onLangChanged,
    required this.onBack,
    required this.onHelp,
    required this.horizontalPadding,
  });

  final String title;
  final double titleSize;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleSize,
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
          const SizedBox(width: 10),
          _RoundIconButton(
            icon: Icons.help_outline_rounded,
            onTap: onHelp,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: Color(0xFFE7E7E7)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}

class _ScanStatusBadge extends StatelessWidget {
  const _ScanStatusBadge({
    required this.label,
    required this.animate,
  });

  final String label;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BlinkDot(
            color: const Color(0xFF111111),
            animate: animate,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSpacing.scale(context, 14).clamp(12.0, 14.0),
              color: const Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkDot extends StatefulWidget {
  const _BlinkDot({required this.color, required this.animate});

  final Color color;
  final bool animate;

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _BlinkDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = widget.animate ? _controller.value : 1.0;
        final scale = 0.82 + 0.18 * t;
        return Opacity(
          opacity: 0.35 + 0.65 * t,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ScanGuideBox extends StatefulWidget {
  const _ScanGuideBox({required this.strings, required this.narrow});

  final KioskStrings strings;
  final bool narrow;

  @override
  State<_ScanGuideBox> createState() => _ScanGuideBoxState();
}

class _ScanGuideBoxState extends State<_ScanGuideBox> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final steps = widget.strings.scanGuideSteps;
    final padH = widget.narrow ? 18.0 : 24.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E7E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, 0, padH, 0),
              child: SizedBox(
                height: 58,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.strings.usageGuide,
                        style: TextStyle(
                          fontSize:
                              AppSpacing.scale(context, 15).clamp(13.0, 16.0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: EdgeInsets.fromLTRB(padH + 4, 16, padH, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    Text(
                      '${i + 1}. ${steps[i]}',
                      style: TextStyle(
                        fontSize:
                            AppSpacing.scale(context, 15).clamp(13.0, 15.0),
                        height: 1.7,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
