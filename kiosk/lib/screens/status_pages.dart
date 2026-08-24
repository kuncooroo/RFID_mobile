import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/alert_status_layout.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/primary_button.dart';

class UnregisteredPage extends StatelessWidget {
  const UnregisteredPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.onRegister,
    required this.onCancel,
  });

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final VoidCallback onRegister;
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
      primaryLabel: strings.registerNowCta,
      onPrimary: onRegister,
      secondaryLabel: strings.cancel,
      onSecondary: onCancel,
      onBack: onCancel,
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      onBack: onBack,
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

  final KioskStrings strings;
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
    required this.front,
    required this.right,
    required this.left,
    required this.onComplete,
    required this.onRetake,
  });

  final KioskStrings strings;
  final Uint8List front;
  final Uint8List right;
  final Uint8List left;
  final VoidCallback onComplete;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return KioskScaffold(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            strings.faceReviewTitle,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            strings.faceReviewBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _thumb(strings.poseFront, front)),
                const SizedBox(width: 10),
                Expanded(child: _thumb(strings.poseRight, right)),
                const SizedBox(width: 10),
                Expanded(child: _thumb(strings.poseLeft, left)),
              ],
            ),
          ),
          KioskActionArea(
            primary: PrimaryButton(
              label: strings.completeEnrollment,
              onPressed: onComplete,
            ),
            secondary: SecondaryButton(
              label: strings.retake,
              onPressed: onRetake,
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(String label, Uint8List bytes) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
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
  });

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final String name;
  final int pointsAwarded;
  final int pointsBalance;
  final VoidCallback onDone;

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
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.welcomeBack,
      body: name,
      tone: AlertTone.success,
      icon: Icons.check_rounded,
      badge: AlertBadgeKind.check,
      primaryLabel: strings.done,
      onPrimary: onDone,
      onBack: onDone,
      bodyExtra: Column(
        children: [
          if (earned) ...[
            Text(
              strings.pointsPlus(pointsAwarded),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
                fontSize: 42,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.totalBalance,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${_fmt(pointsBalance)} ${strings.points}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ] else ...[
            Text(
              strings.alreadyGotDailyPoints,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              strings.yourTotal,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${_fmt(pointsBalance)} ${strings.points}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            strings.thanksVisit,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final VoidCallback onHome;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final body = [
      if (name != null && name!.isNotEmpty) strings.alreadyCheckedInHi(name!),
      strings.alreadyCheckedInBody,
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
      onBack: onHome,
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
  });

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return AlertStatusLayout(
      strings: strings,
      lang: lang,
      onLangChanged: onLangChanged,
      title: strings.faceEnrollmentComplete,
      body: strings.faceEnrollmentCompleteBody,
      tone: AlertTone.success,
      icon: Icons.check_rounded,
      badge: AlertBadgeKind.check,
      primaryLabel: strings.done,
      onPrimary: onDone,
      onBack: onDone,
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      onBack: onCancel,
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      onBack: onHome,
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      onBack: onHome,
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      onBack: onStart,
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

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
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
      primaryLabel: strings.tryAgain,
      onPrimary: onBack,
      onBack: onBack,
    );
  }
}
