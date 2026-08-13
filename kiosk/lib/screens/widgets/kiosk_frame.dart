import 'package:flutter/material.dart';

import '../../theme/kiosk_theme.dart';

class KioskFrame extends StatelessWidget {
  const KioskFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KioskColors.bg, Color(0xFF17183A), KioskColors.primaryDark],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: child,
      ),
    );
  }
}
