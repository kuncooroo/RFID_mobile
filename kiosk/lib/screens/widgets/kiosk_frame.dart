import 'package:flutter/material.dart';

import '../../widgets/kiosk_scaffold.dart';

class KioskFrame extends StatelessWidget {
  const KioskFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => KioskScaffold(child: child);
}
