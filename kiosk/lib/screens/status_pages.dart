import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/primary_button.dart';

class UnregisteredPage extends StatelessWidget {
  const UnregisteredPage({
    super.key,
    required this.strings,
    required this.onRegister,
    required this.onCancel,
  });

  final KioskStrings strings;
  final VoidCallback onRegister;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.credit_card_outlined,
            size: 72,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.newCardDetected,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 16, min: 8, max: 16)),
          Text(
            strings.newCardBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.register, onPressed: onRegister),
        secondary: SecondaryButton(label: strings.cancel, onPressed: onCancel),
      ),
    );
  }
}

class FaceEnrollmentIntroPage extends StatelessWidget {
  const FaceEnrollmentIntroPage({
    super.key,
    required this.strings,
    required this.onStart,
    this.requiredExisting = false,
  });

  final KioskStrings strings;
  final VoidCallback onStart;
  final bool requiredExisting;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            requiredExisting
                ? strings.faceRequiredTitle
                : strings.faceSetupTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 16, min: 8, max: 16)),
          Text(
            requiredExisting
                ? strings.faceRequiredBody
                : strings.faceSetupBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: AppSpacing.vGap(context, 28, min: 14, max: 28)),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _poseChip(strings.poseFront),
              _poseChip(strings.poseRight),
              _poseChip(strings.poseLeft),
            ],
          ),
          SizedBox(height: AppSpacing.vGap(context, 28, min: 14, max: 28)),
          Text(
            strings.faceOnceOnly,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.start, onPressed: onStart),
      ),
    );
  }

  Widget _poseChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: AppColors.primaryDark,
        ),
      ),
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
            secondary: SecondaryButton(label: strings.retake, onPressed: onRetake),
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
    required this.name,
    required this.pointsAwarded,
    required this.pointsBalance,
    required this.countdown,
    required this.onDone,
  });

  final KioskStrings strings;
  final String name;
  final int pointsAwarded;
  final int pointsBalance;
  final int countdown;
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
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.welcomeBack,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 10, min: 6, max: 10)),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.vGap(context, 28, min: 14, max: 28)),
          if (earned) ...[
            Text(
              strings.pointsPlus(pointsAwarded),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 42,
                  ),
            ),
            SizedBox(height: AppSpacing.vGap(context, 28, min: 14, max: 28)),
            Text(strings.totalBalance, style: Theme.of(context).textTheme.bodyMedium),
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
            SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
            Text(strings.yourTotal, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              '${_fmt(pointsBalance)} ${strings.points}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
          SizedBox(height: AppSpacing.vGap(context, 20, min: 10, max: 20)),
          Text(
            strings.thanksVisit,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        leading: Text(
          strings.returningIn(countdown),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        primary: PrimaryButton(label: strings.done, onPressed: onDone),
      ),
    );
  }
}

class DuplicateCheckInPage extends StatelessWidget {
  const DuplicateCheckInPage({
    super.key,
    required this.strings,
    required this.onHome,
    this.name,
    this.countdown,
  });

  final KioskStrings strings;
  final VoidCallback onHome;
  final String? name;
  final int? countdown;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, size: 72, color: AppColors.warning),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.alreadyCheckedIn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          if (name != null && name!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.vGap(context, 12, min: 6, max: 12)),
            Text(
              strings.alreadyCheckedInHi(name!),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
          SizedBox(height: AppSpacing.vGap(context, 16, min: 8, max: 16)),
          Text(
            strings.alreadyCheckedInBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        leading: countdown != null
            ? Text(
                strings.returningIn(countdown!),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              )
            : null,
        primary: PrimaryButton(label: strings.backHome, onPressed: onHome),
      ),
    );
  }
}

class EnrollmentCompletePage extends StatelessWidget {
  const EnrollmentCompletePage({
    super.key,
    required this.strings,
    required this.countdown,
    required this.onDone,
  });

  final KioskStrings strings;
  final int countdown;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.faceEnrollmentComplete,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 12, min: 6, max: 12)),
          Text(
            strings.faceEnrollmentCompleteBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        leading: Text(
          strings.returningIn(countdown),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        primary: PrimaryButton(label: strings.done, onPressed: onDone),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.strings,
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  final KioskStrings strings;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 72, color: AppColors.error),
          SizedBox(height: AppSpacing.vGap(context, 20, min: 10, max: 20)),
          Text(
            strings.somethingWrong,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 12, min: 6, max: 12)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.tryAgain, onPressed: onRetry),
        secondary: SecondaryButton(label: strings.backHome, onPressed: onCancel),
      ),
    );
  }
}

class OfflinePage extends StatelessWidget {
  const OfflinePage({
    super.key,
    required this.strings,
    required this.onRetry,
    required this.onHome,
  });

  final KioskStrings strings;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 72, color: AppColors.error),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.connectionUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 16, min: 8, max: 16)),
          Text(
            strings.cannotReach,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.retry, onPressed: onRetry),
        secondary: GhostButton(label: strings.backHome, onPressed: onHome),
      ),
    );
  }
}

class CameraErrorPage extends StatelessWidget {
  const CameraErrorPage({
    super.key,
    required this.strings,
    required this.onRetry,
    required this.onHome,
  });

  final KioskStrings strings;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off_outlined, size: 72, color: AppColors.error),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.cameraUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 16, min: 8, max: 16)),
          Text(
            strings.cameraUnavailableBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.tryAgain, onPressed: onRetry),
        secondary: SecondaryButton(label: strings.backHome, onPressed: onHome),
      ),
    );
  }
}

class TimeoutPage extends StatelessWidget {
  const TimeoutPage({
    super.key,
    required this.strings,
    required this.onStart,
  });

  final KioskStrings strings;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_off_outlined, size: 72, color: AppColors.textSecondary),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.sessionExpired,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 16, min: 8, max: 16)),
          Text(
            strings.sessionExpiredBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.startAgain, onPressed: onStart),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, required this.strings, required this.onBack});

  final KioskStrings strings;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.helpTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.helpBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Text(
            strings.helpMore,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      footer: KioskActionArea(
        primary: PrimaryButton(label: strings.tryAgain, onPressed: onBack),
      ),
    );
  }
}
