import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../messaging/navigation/messaging_navigation.dart';
import '../navigation/profile_navigation.dart';
import '../widgets/help_support_view.dart';

/// Help and Support screen (Figma `1:38`).
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _supportThreadId = 'thread-5';
  static const _websiteUrl = 'https://kutuku.app';
  static const _whatsappNumber = '+62 851-0000-0000';
  static const _facebookHandle = '@kutuku.app';
  static const _twitterHandle = '@kutuku';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => ProfileNavigation.pop(context),
        ),
        title: Text('Help and Support', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: HelpSupportView(
        onCustomerService: () {
          MessagingNavigation.openThreadById(context, _supportThreadId);
        },
        onWebsite: () => _copyAndToast(
          context,
          value: _websiteUrl,
          message: 'Website link copied',
        ),
        onWhatsapp: () => _copyAndToast(
          context,
          value: _whatsappNumber,
          message: 'Whatsapp number copied',
        ),
        onFacebook: () => _copyAndToast(
          context,
          value: _facebookHandle,
          message: 'Facebook handle copied',
        ),
        onTwitter: () => _copyAndToast(
          context,
          value: _twitterHandle,
          message: 'Twitter handle copied',
        ),
      ),
    );
  }

  static Future<void> _copyAndToast(
    BuildContext context, {
    required String value,
    required String message,
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
