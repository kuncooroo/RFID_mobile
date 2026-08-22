import 'package:flutter/material.dart';

import '../config/kiosk_config.dart';
import '../l10n/kiosk_strings.dart';
import '../services/kiosk_api.dart';
import '../theme/app_colors.dart';
import '../widgets/kiosk_header.dart';
import '../widgets/kiosk_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_indicator.dart';
import 'kiosk_flow_page.dart';

class KioskSplashPage extends StatefulWidget {
  const KioskSplashPage({super.key, required this.api});

  final KioskApi api;

  @override
  State<KioskSplashPage> createState() => _KioskSplashPageState();
}

class _KioskSplashPageState extends State<KioskSplashPage> {
  final _strings = const KioskStrings(KioskLang.en);
  String _status = '';
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _status = _strings.bootConfig;
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = _strings.bootConfig;
    });

    if (KioskConfig.apiBaseUrl.trim().isEmpty) {
      setState(() {
        _busy = false;
        _error = _strings.genericError;
      });
      return;
    }

    setState(() => _status = _strings.bootConnecting);
    try {
      await widget.api.health().timeout(const Duration(seconds: 8));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _strings.cannotReach;
        _status = _strings.bootFailed;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _status = _strings.bootReady);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => KioskFlowPage(api: widget.api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: KioskPageShell(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Center(child: KioskLogo()),
            const SizedBox(height: 40),
            if (_busy)
              const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            else if (_error != null)
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              PrimaryButton(label: _strings.retry, onPressed: _boot),
              const SizedBox(height: 16),
            ],
            StatusIndicator(
              status: _error != null
                  ? SystemStatus.offline
                  : SystemStatus.processing,
              label: _error != null
                  ? _strings.systemOffline
                  : _strings.systemProcessing,
            ),
          ],
        ),
      ),
    );
  }
}
