import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/alert_status_layout.dart';
import '../widgets/system_content_scaffold.dart';
import '../widgets/language_selector.dart';
import '../widgets/primary_button.dart';

class UnregisteredPage extends StatelessWidget {
  const UnregisteredPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onCancel,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.newCardDetected,
      body: strings.newCardBody,
      tone: AlertTone.warning,
      icon: Icons.info_rounded,
      primaryLabel: strings.back,
      onPrimary: onCancel,
      languageOnlyHeader: true,
    );
  }
}

class FaceEnrollmentIntroPage extends StatelessWidget {
  const FaceEnrollmentIntroPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onStart,
    required this.onBack,
    this.requiredExisting = false,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onStart;
  final VoidCallback onBack;
  final bool requiredExisting;

  @override
  Widget build(BuildContext context) {
    final title = requiredExisting
        ? strings.faceRequiredTitle
        : strings.faceSetupTitle;
    final body = requiredExisting
        ? strings.faceRequiredBody
        : '${strings.faceSetupBody}\n\n${strings.faceOnceOnly}';

    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: title,
      body: body,
      tone: AlertTone.brand,
      icon: Icons.face_retouching_natural_rounded,
      primaryLabel: strings.start,
      onPrimary: onStart,
      languageOnlyHeader: true,
    );
  }
}

class PoseProgressBar extends StatelessWidget {
  const PoseProgressBar({
    super.key,
    required this.strings,
    required this.currentIndex,
    required this.completed,
  });

  final SystemStrings strings;
  final int currentIndex;
  final Set<String> completed;

  @override
  Widget build(BuildContext context) {
    final poses = [
      (strings.poseFront, 'front'),
      (strings.poseRight, 'right'),
      (strings.poseLeft, 'left'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < poses.length; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          Column(
            children: [
              Text(
                poses[i].$1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: i == currentIndex
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed.contains(poses[i].$2)
                      ? AppColors.success
                      : i == currentIndex
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: completed.contains(poses[i].$2) || i == currentIndex
                        ? Colors.transparent
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: completed.contains(poses[i].$2)
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FaceReviewPage extends StatelessWidget {
  const FaceReviewPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.front,
    required this.right,
    required this.left,
    required this.onComplete,
    required this.onRetake,
    this.onBack,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final Uint8List front;
  final Uint8List right;
  final Uint8List left;
  final VoidCallback onComplete;
  final VoidCallback onRetake;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SystemContentScaffold(
      headerTitle: strings.faceReviewTitle,
      lang: lang,
      onLangChanged: onLangChanged,
      onBack: onBack ?? onRetake,
      languageOnlyHeader: true,
      footer: Column(
        children: [
          PrimaryButton(
            label: strings.completeEnrollment,
            onPressed: onComplete,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: strings.retakePhotos,
            onPressed: onRetake,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SystemPageHeading(
                    title: strings.faceReviewTitle,
                    subtitle: strings.faceReviewBody,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          strings.faceReviewSuccess,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FaceReviewCard(
                          label: strings.poseFront,
                          bytes: front,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FaceReviewCard(
                          label: strings.poseRight,
                          bytes: right,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FaceReviewCard(
                          label: strings.poseLeft,
                          bytes: left,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FaceReviewCard extends StatelessWidget {
  const _FaceReviewCard({
    required this.label,
    required this.bytes,
  });

  final String label;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: Color(0xFFECECEC),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(bytes, fit: BoxFit.contain),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VisitSuccessPage extends StatelessWidget {
  const VisitSuccessPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.name,
    required this.pointsAwarded,
    required this.pointsBalance,
    required this.onDone,
    this.amountCharged = 0,
    this.walletBalance = 0,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final String name;
  final int pointsAwarded;
  final int pointsBalance;
  final VoidCallback onDone;
  final double amountCharged;
  final double walletBalance;

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      if (i != 0 && fromEnd % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final earned = pointsAwarded > 0;

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      children: [
                        const _VisitSuccessVisual(),
                        const SizedBox(height: 28),
                        Text(
                          strings.welcomeBack,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.4,
                            color: Color(0xFF101820),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6F737C),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          width: 100,
                          height: 1,
                          color: const Color(0xFFEDEDED),
                        ),
                        const SizedBox(height: 28),
                        if (earned)
                          _VisitInfoCard(
                            softBlue: true,
                            icon: Icons.star_rounded,
                            label: strings.youEarned,
                            value: strings.pointsPlus(pointsAwarded),
                            valueColor: AppColors.primary,
                          )
                        else
                          _VisitInfoCard(
                            softBlue: true,
                            icon: Icons.info_rounded,
                            label: strings.checkedIn,
                            value: strings.alreadyGotDailyPoints
                                .replaceAll('\n', ' '),
                            valueColor: AppColors.textSecondary,
                            valueSize: 18,
                          ),
                        const SizedBox(height: 16),
                        _VisitInfoCard(
                          softBlue: false,
                          icon: Icons.payments_outlined,
                          label: strings.fareCharged,
                          value: _fmt(amountCharged.round()),
                          valueColor: const Color(0xFF111111),
                        ),
                        const SizedBox(height: 16),
                        _VisitInfoCard(
                          softBlue: false,
                          icon: Icons.account_balance_wallet_outlined,
                          label: strings.remainingBalance,
                          value: _fmt(walletBalance.round()),
                          valueColor: const Color(0xFF111111),
                        ),
                        const SizedBox(height: 16),
                        _VisitInfoCard(
                          softBlue: true,
                          icon: Icons.star_outline_rounded,
                          label: strings.totalBalance,
                          value: '${_fmt(pointsBalance)} ${strings.points}',
                          valueColor: const Color(0xFF111111),
                        ),
                        const SizedBox(height: 16),
                        _VisitInfoCard(
                          softBlue: true,
                          icon: Icons.auto_awesome_rounded,
                          label: strings.thanksVisit,
                          value: strings.thanksVisitBody,
                          valueColor: const Color(0xFF6F737C),
                          valueSize: 16,
                          iconOutlined: true,
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: strings.done,
                          onPressed: onDone,
                        ),
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

class _VisitInfoCard extends StatelessWidget {
  const _VisitInfoCard({
    required this.softBlue,
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueSize = 36,
    this.iconOutlined = false,
  });

  final bool softBlue;
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;
  final bool iconOutlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: softBlue
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFF6FAFF), Color(0xFFF9FCFF)],
              )
            : null,
        color: softBlue ? null : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x05000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F183050),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: iconOutlined
                ? Icon(icon, size: 36, color: AppColors.primary)
                : Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F737C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    height: 1.2,
                    fontWeight:
                        valueSize >= 28 ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: valueSize >= 28 ? -1.0 : 0,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitSuccessVisual extends StatelessWidget {
  const _VisitSuccessVisual();

  @override
  Widget build(BuildContext context) {
    const size = 280.0;
    const circle = 154.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(size, const Color(0x0A3F8FE8)),
          _ring(size * 0.82, const Color(0x0E3F8FE8)),
          _ring(size * 0.65, const Color(0x133F8FE8)),
          // Decorative accents
          const Positioned(
            left: 18,
            top: 96,
            child: _DecorDot(size: 16),
          ),
          const Positioned(
            right: 18,
            top: 40,
            child: _DecorDot(size: 16),
          ),
          const Positioned(
            right: 4,
            top: 128,
            child: _DecorPill(color: Color(0xFFA8DB7E), rotate: 0.5),
          ),
          const Positioned(
            right: 18,
            bottom: 54,
            child: _DecorPill(color: Color(0xFFB7DDFF), rotate: 0.45),
          ),
          const Positioned(
            left: 22,
            bottom: 68,
            child: _DecorStar(),
          ),
          Container(
            width: circle,
            height: circle,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4297EE), Color(0xFF2F7FD8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x2E3584DC),
                  blurRadius: 35,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 84,
              color: Colors.white,
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

class _DecorDot extends StatelessWidget {
  const _DecorDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF5CA6EE),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DecorPill extends StatelessWidget {
  const _DecorPill({required this.color, required this.rotate});

  final Color color;
  final double rotate;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        width: 13,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _DecorStar extends StatelessWidget {
  const _DecorStar();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.star_rounded,
      size: 30,
      color: Color(0xFFFFD56A),
    );
  }
}

class DuplicateCheckInPage extends StatelessWidget {
  const DuplicateCheckInPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onHome,
    this.name,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onHome;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final body = [
      if (name != null && name!.isNotEmpty) strings.alreadyCheckedInHi(name!),
      strings.alreadyCheckedInVisit,
      strings.alreadyCheckedInTap,
    ].join('\n\n');

    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.alreadyCheckedIn,
      body: body,
      tone: AlertTone.warning,
      icon: Icons.info_rounded,
      primaryLabel: strings.backHome,
      onPrimary: onHome,
      languageOnlyHeader: true,
    );
  }
}

class EnrollmentCompletePage extends StatelessWidget {
  const EnrollmentCompletePage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onDone,
    this.title,
    this.body,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onDone;
  final String? title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: title ?? strings.faceEnrollmentComplete,
      body: body ?? strings.faceEnrollmentCompleteBody,
      tone: AlertTone.success,
      icon: Icons.check_rounded,
      badge: AlertBadgeKind.check,
      primaryLabel: strings.done,
      onPrimary: onDone,
      languageOnlyHeader: true,
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.somethingWrong,
      body: message,
      tone: AlertTone.error,
      icon: Icons.error_outline_rounded,
      primaryLabel: strings.tryAgain,
      onPrimary: onRetry,
      secondaryLabel: strings.backHome,
      onSecondary: onCancel,
      languageOnlyHeader: true,
    );
  }
}

class OfflinePage extends StatelessWidget {
  const OfflinePage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onRetry,
    required this.onHome,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.connectionUnavailable,
      body: strings.cannotReach,
      tone: AlertTone.error,
      icon: Icons.wifi_off_rounded,
      primaryLabel: strings.retry,
      onPrimary: onRetry,
      secondaryLabel: strings.backHome,
      onSecondary: onHome,
      languageOnlyHeader: true,
    );
  }
}

class CameraErrorPage extends StatelessWidget {
  const CameraErrorPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onRetry,
    required this.onHome,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.cameraUnavailable,
      body: strings.cameraUnavailableBody,
      tone: AlertTone.error,
      icon: Icons.videocam_off_rounded,
      primaryLabel: strings.tryAgain,
      onPrimary: onRetry,
      secondaryLabel: strings.backHome,
      onSecondary: onHome,
      languageOnlyHeader: true,
    );
  }
}

class TimeoutPage extends StatelessWidget {
  const TimeoutPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onStart,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.sessionExpired,
      body: strings.sessionExpiredBody,
      tone: AlertTone.muted,
      icon: Icons.timer_off_rounded,
      primaryLabel: strings.startAgain,
      onPrimary: onStart,
      languageOnlyHeader: true,
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onBack,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.helpTitle,
      body: '${strings.helpBody}\n\n${strings.helpMore}',
      tone: AlertTone.muted,
      icon: Icons.help_rounded,
      primaryLabel: strings.backHome,
      onPrimary: onBack,
      onBack: onBack,
      hidePrimary: true,
    );
  }
}
