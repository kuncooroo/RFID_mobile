import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/kiosk_strings.dart';
import '../widgets/help_button.dart' as help_btn;
import '../widgets/kiosk_header.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/language_selector.dart';
import '../widgets/primary_button.dart';
import '../widgets/rfid_visual.dart';
import '../widgets/status_indicator.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.serverOnline,
    required this.onCheckIn,
    required this.onRegister,
    required this.onHelp,
  });

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final bool serverOnline;
  final VoidCallback onCheckIn;
  final VoidCallback onRegister;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final landscape = AppSpacing.isLandscape(context);
    final content = Column(
      children: [
        KioskHeader(
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: LanguageSelector(lang: lang, onChanged: onLangChanged),
          ),
        ),
        const Spacer(),
        Text(
          strings.helloWelcome,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        Text(
          strings.whatToday,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(label: strings.checkIn, onPressed: onCheckIn),
        const SizedBox(height: 12),
        SecondaryButton(label: strings.register, onPressed: onRegister),
        const Spacer(),
        help_btn.HelpButton(label: strings.needHelp, onPressed: onHelp),
        const SizedBox(height: 16),
        StatusIndicator(
          status: serverOnline ? SystemStatus.ready : SystemStatus.offline,
          label: serverOnline ? strings.systemReady : strings.systemOffline,
        ),
      ],
    );

    return KioskScaffold(
      child: landscape
          ? Row(
              children: [
                const Expanded(child: Center(child: KioskLogo())),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}

class RfidScanPage extends StatelessWidget {
  const RfidScanPage({
    super.key,
    required this.strings,
    required this.scannerController,
    required this.onDetect,
    required this.showScanner,
    required this.processing,
    required this.onCancel,
    required this.onHelp,
    required this.serverOnline,
  });

  final KioskStrings strings;
  final MobileScannerController scannerController;
  final void Function(BarcodeCapture capture) onDetect;
  final bool showScanner;
  final bool processing;
  final VoidCallback onCancel;
  final VoidCallback onHelp;
  final bool serverOnline;

  @override
  Widget build(BuildContext context) {
    return KioskScaffold(
      child: Column(
        children: [
          Text(strings.checkIn, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(
            strings.tapCard,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showScanner)
                  Opacity(
                    opacity: 0.08,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: MobileScanner(
                        controller: scannerController,
                        onDetect: onDetect,
                      ),
                    ),
                  ),
                RfidVisual(processing: processing),
                if (processing)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppColors.background.withValues(alpha: 0.86),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              strings.checkingCard,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.pleaseWait,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            processing ? strings.checkingCard : strings.holdCard,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            processing ? strings.pleaseWait : strings.waitingCard,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 20),
          if (!processing)
            SecondaryButton(label: strings.cancel, onPressed: onCancel),
          const SizedBox(height: 8),
          help_btn.HelpButton(label: strings.needHelp, onPressed: onHelp),
          const SizedBox(height: 8),
          StatusIndicator(
            status: !serverOnline
                ? SystemStatus.offline
                : processing
                    ? SystemStatus.processing
                    : SystemStatus.ready,
            label: !serverOnline
                ? strings.systemOffline
                : processing
                    ? strings.systemProcessing
                    : strings.systemReady,
          ),
        ],
      ),
    );
  }
}
