import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_settings_tile.dart';

/// Help and Support body (Figma `1:38`).
///
/// Kutuku layout: stacked settings tiles for contact channels
/// (Customer Service, Website, Whatsapp, Facebook, Twitter).
class HelpSupportView extends StatelessWidget {
  const HelpSupportView({
    super.key,
    required this.onCustomerService,
    required this.onWebsite,
    required this.onWhatsapp,
    required this.onFacebook,
    required this.onTwitter,
  });

  final VoidCallback onCustomerService;
  final VoidCallback onWebsite;
  final VoidCallback onWhatsapp;
  final VoidCallback onFacebook;
  final VoidCallback onTwitter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      children: [
        AppSettingsTile(
          title: 'Customer Service',
          leading: const Icon(Icons.headset_mic_outlined),
          onTap: onCustomerService,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSettingsTile(
          title: 'Website',
          leading: const Icon(Icons.language_rounded),
          onTap: onWebsite,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSettingsTile(
          title: 'Whatsapp',
          leading: const Icon(Icons.chat_rounded),
          onTap: onWhatsapp,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSettingsTile(
          title: 'Facebook',
          leading: const Icon(Icons.facebook_rounded),
          onTap: onFacebook,
        ),
        const SizedBox(height: AppSpacing.md),
        AppSettingsTile(
          title: 'Twitter',
          leading: const Icon(Icons.alternate_email_rounded),
          onTap: onTwitter,
        ),
      ],
    );
  }
}
