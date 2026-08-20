import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_radius.dart';
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
        children: [
          Text(strings.photoOk, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
          PrimaryButton(
            label: strings.usePhoto,
            busy: busy,
            onPressed: onUsePhoto,
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: strings.retake,
            onPressed: busy ? null : onRetake,
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
    return KioskScaffold(
      child: Column(
        children: [
          const Spacer(),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 28),
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
          const Spacer(),
        ],
      ),
    );
  }
}
