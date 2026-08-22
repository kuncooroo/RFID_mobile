import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/primary_button.dart';

class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage({
    super.key,
    required this.strings,
    required this.photoBytes,
    required this.onUsePhoto,
    required this.onRetake,
    this.busy = false,
  });

  final KioskStrings strings;
  final Uint8List photoBytes;
  final VoidCallback onUsePhoto;
  final VoidCallback onRetake;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return KioskScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.photoOk,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: Image.memory(
                photoBytes,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vGap(context, 24, min: 12, max: 24)),
          KioskActionArea(
            primary: PrimaryButton(
              label: strings.usePhoto,
              busy: busy,
              onPressed: onUsePhoto,
            ),
            secondary: SecondaryButton(
              label: strings.retake,
              onPressed: busy ? null : onRetake,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressStatusPage extends StatelessWidget {
  const ProgressStatusPage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return KioskPageShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
          SizedBox(height: AppSpacing.vGap(context, 28, min: 16, max: 28)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
