import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../models/kiosk_member.dart';
import '../theme/app_colors.dart';
import '../widgets/kiosk_card.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/primary_button.dart';

class RegisteredPage extends StatelessWidget {
  const RegisteredPage({
    super.key,
    required this.strings,
    required this.lookup,
    required this.onContinue,
  });

  final KioskStrings strings;
  final RfidLookup lookup;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final user = lookup.user;
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          Text(
            strings.welcomeBack,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              (user?.name.isNotEmpty == true ? user!.name[0] : 'K').toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'Visitor',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          KioskCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  strings.memberId,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  lookup.memberCode ?? '—',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.cardReady,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.continueLabel, onPressed: onContinue),
        ],
      ),
    );
  }
}

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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          Icon(Icons.credit_card_off_outlined, size: 72, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            strings.cardNotRegistered,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            strings.cardNotRegisteredBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.registerNow, onPressed: onRegister),
          const SizedBox(height: 8),
          SecondaryButton(label: strings.cancel, onPressed: onCancel),
        ],
      ),
    );
  }
}

class CameraPrepPage extends StatelessWidget {
  const CameraPrepPage({
    super.key,
    required this.strings,
    required this.onContinue,
  });

  final KioskStrings strings;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          Text(
            strings.confirmPresence,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            strings.needPhoto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.face_retouching_natural, size: 72, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            strings.lookAtCamera,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.continueLabel, onPressed: onContinue),
        ],
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({
    super.key,
    required this.strings,
    required this.name,
    this.checkedInAt,
    required this.onContinue,
  });

  final KioskStrings strings;
  final String name;
  final DateTime? checkedInAt;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final when = checkedInAt ?? DateTime.now();
    final date =
        '${when.day.toString().padLeft(2, '0')} ${_month(when.month)} ${when.year}';
    final time =
        '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            strings.checkedIn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            strings.welcomeName(name),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            '$date\n$time',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.continueLabel, onPressed: onContinue),
        ],
      ),
    );
  }

  String _month(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }
}

class PointsPage extends StatelessWidget {
  const PointsPage({
    super.key,
    required this.strings,
    required this.pointsAwarded,
    required this.pointsBalance,
    required this.onDone,
  });

  final KioskStrings strings;
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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          Text(strings.youEarned, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            '+${_fmt(pointsAwarded)} ${strings.points}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 40),
          Text(strings.yourTotal, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '${_fmt(pointsBalance)} ${strings.points}',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          Text(
            strings.thanksVisit,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.done, onPressed: onDone),
        ],
      ),
    );
  }
}

class DuplicateCheckInPage extends StatelessWidget {
  const DuplicateCheckInPage({
    super.key,
    required this.strings,
    required this.onHome,
  });

  final KioskStrings strings;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.info_outline_rounded, size: 72, color: AppColors.warning),
          const SizedBox(height: 24),
          Text(
            strings.alreadyCheckedIn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            strings.alreadyCheckedInBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.backHome, onPressed: onHome),
        ],
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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.error_outline_rounded, size: 72, color: AppColors.error),
          const SizedBox(height: 20),
          Text(
            strings.somethingWrong,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.tryAgain, onPressed: onRetry),
          const SizedBox(height: 8),
          SecondaryButton(label: strings.backHome, onPressed: onCancel),
        ],
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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.wifi_off_rounded, size: 72, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            strings.connectionUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            strings.cannotReach,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.retry, onPressed: onRetry),
          GhostButton(label: strings.backHome, onPressed: onHome),
        ],
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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.videocam_off_outlined, size: 72, color: AppColors.error),
          const SizedBox(height: 24),
          Text(
            strings.cameraUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            strings.cameraUnavailableBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.tryAgain, onPressed: onRetry),
          const SizedBox(height: 8),
          SecondaryButton(label: strings.backHome, onPressed: onHome),
        ],
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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.timer_off_outlined, size: 72, color: AppColors.textSecondary),
          const SizedBox(height: 24),
          Text(
            strings.sessionExpired,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            strings.sessionExpiredBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          PrimaryButton(label: strings.startAgain, onPressed: onStart),
        ],
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
    return KioskScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strings.helpTitle, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          Text(
            strings.helpBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const Spacer(),
          PrimaryButton(label: strings.back, onPressed: onBack),
        ],
      ),
    );
  }
}
