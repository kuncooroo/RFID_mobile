import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_spacing.dart';
import '../widgets/system_content_scaffold.dart';
import '../widgets/system_scaffold.dart';
import '../widgets/primary_button.dart';

class PhotoPreviewPage extends StatelessWidget {
  const PhotoPreviewPage({
    super.key,
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.photoBytes,
    required this.onUsePhoto,
    required this.onRetake,
    this.busy = false,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final Uint8List photoBytes;
  final VoidCallback onUsePhoto;
  final VoidCallback onRetake;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SystemContentScaffold(
      headerTitle: strings.photoOk,
      lang: lang,
      onLangChanged: onLangChanged,
      onBack: busy ? null : onRetake,
      languageOnlyHeader: true,
      footer: Column(
        children: [
          PrimaryButton(
            label: strings.usePhoto,
            busy: busy,
            onPressed: onUsePhoto,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: strings.retake,
            onPressed: busy ? null : onRetake,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final frameHeight =
              (constraints.maxHeight - 160).clamp(220.0, 640.0).toDouble();
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SystemPageHeading(
                    title: strings.photoOk,
                    subtitle: strings.photoOkBody,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: frameHeight,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDEDED),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: Image.memory(
                          photoBytes,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
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
    return SystemPageShell(
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
