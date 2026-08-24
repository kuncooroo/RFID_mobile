import 'package:flutter/material.dart';

import '../config/kiosk_config.dart';
import '../l10n/kiosk_strings.dart';
import '../services/kiosk_api.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';
import 'kiosk_flow_page.dart';

class KioskSplashPage extends StatefulWidget {
  const KioskSplashPage({super.key, required this.api});

  final KioskApi api;

  @override
  State<KioskSplashPage> createState() => _KioskSplashPageState();
}

class _KioskSplashPageState extends State<KioskSplashPage>
    with TickerProviderStateMixin {
  final _strings = const KioskStrings(KioskLang.en);
  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final Animation<double> _markScale;
  late final Animation<double> _markFade;
  late final Animation<double> _copyFade;

  String _status = '';
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _status = _strings.bootConfig;
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _markScale = CurvedAnimation(parent: _intro, curve: Curves.easeOutBack);
    _markFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _copyFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _intro.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = _strings.bootConfig;
    });

    if (KioskConfig.apiBaseUrl.trim().isEmpty) {
      setState(() {
        _busy = false;
        _error = _strings.genericError;
      });
      return;
    }

    setState(() => _status = _strings.bootConnecting);
    try {
      await widget.api.health().timeout(const Duration(seconds: 8));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _strings.cannotReach;
        _status = _strings.bootFailed;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _status = _strings.bootReady);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            KioskFlowPage(api: widget.api),
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final mobile = width < 560;
    final markSize = AppSpacing.scale(context, 108).clamp(80.0, 128.0);
    final wordSize = AppSpacing.scale(context, 44).clamp(30.0, 48.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 1.2,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFAFAFA),
                Color(0xFFF5F6F6),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 24 : 48,
                vertical: mobile ? 20 : 32,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment(0, height < 700 ? -0.05 : -0.12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: Listenable.merge([_intro, _pulse]),
                          builder: (context, _) {
                            return Opacity(
                              opacity: _markFade.value,
                              child: Transform.scale(
                                scale: 0.82 + (_markScale.value * 0.18),
                                child: _SplashMark(
                                  size: markSize,
                                  pulse: _pulse.value,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        FadeTransition(
                          opacity: _copyFade,
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: wordSize,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                                color: AppColors.primary,
                              ),
                              children: const [
                                TextSpan(text: 'TapGo'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FadeTransition(
                      opacity: _copyFade,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: mobile ? 8 : 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_busy)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.primary,
                                ),
                              )
                            else if (_error != null)
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 14),
                            Text(
                              _status,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _error != null
                                    ? AppColors.error
                                    : AppColors.textMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: PrimaryButton(
                                  label: _strings.retry,
                                  onPressed: _boot,
                                ),
                              ),
                            ],
                          ],
                        ),
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

class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.size, required this.pulse});

  final double size;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final field = size * 2.4;
    return SizedBox(
      width: field,
      height: field,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(field),
            painter: _SplashRingsPainter(progress: pulse),
          ),
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x144BA3F5),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
              border: Border.all(color: const Color(0x144BA3F5)),
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashRingsPainter extends CustomPainter {
  _SplashRingsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.48;
    const color = AppColors.primary;

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1.0;
      final radius = maxRadius * (0.28 + phase * 0.72);
      final opacity = (1 - phase).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: 0.16 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 + (1 - phase);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashRingsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
