import 'package:flutter/material.dart';

import '../l10n/system_strings.dart';
import '../theme/app_colors.dart';

enum RfidScanState { ready, reading, processing, success, error }

/// RFID illustration using [assets/images/rfid.png].
class RfidScanIllustration extends StatelessWidget {
  const RfidScanIllustration({super.key});

  static const assetPath = 'assets/images/rfid.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) =>
            const _RfidImagePlaceholder(),
      ),
    );
  }
}

class _RfidImagePlaceholder extends StatelessWidget {
  const _RfidImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x73FFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x4007877D), width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 52, color: AppColors.primary),
          SizedBox(height: 12),
          Text(
            'RFID Illustration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward-compatible alias.
class RfidScanArea extends StatelessWidget {
  const RfidScanArea({
    super.key,
    required this.strings,
    this.state = RfidScanState.ready,
    this.title,
    this.description,
  });

  final SystemStrings strings;
  final RfidScanState state;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return const RfidScanIllustration();
  }
}

/// Backward-compatible alias.
class RfidVisual extends StatelessWidget {
  const RfidVisual({super.key, this.processing = false, this.strings});

  final bool processing;
  final SystemStrings? strings;

  @override
  Widget build(BuildContext context) {
    return RfidScanArea(
      strings: strings ?? const SystemStrings(SystemLang.en),
      state: processing ? RfidScanState.processing : RfidScanState.ready,
    );
  }
}
