import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../settings/models/settings.dart';
import '../navigation/profile_navigation.dart';
import '../providers/profile_providers.dart';
import '../widgets/security_view.dart';

/// Security settings screen.
class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  var _saving = false;
  var _readyOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).load();
    });
  }

  Future<void> _update(Settings Function(Settings current) updater) async {
    if (_saving) return;
    final current = ref.read(settingsControllerProvider).settings;
    setState(() => _saving = true);
    final ok = await ref
        .read(settingsControllerProvider.notifier)
        .updateSettings(updater(current));
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security preferences saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    if (state.isReady && !_readyOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _readyOnce) return;
        setState(() => _readyOnce = true);
      });
    }

    final showLoadError = state.hasFailed && !_readyOnce && !state.isLoading;

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
        title: Text('Security', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: SecurityView(
        settings: state.settings,
        isLoading: state.isLoading && !_readyOnce,
        hasLoadFailed: showLoadError,
        isSaving: _saving,
        errorMessage: showLoadError
            ? state.errorMessage
            : (_readyOnce && state.hasFailed ? state.errorMessage : null),
        onRetry: () {
          setState(() => _readyOnce = false);
          ref.read(settingsControllerProvider.notifier).load();
        },
        onBiometricChanged: (value) => _update(
          (settings) => settings.copyWith(biometricEnabled: value),
        ),
        onTwoFactorChanged: (value) => _update(
          (settings) => settings.copyWith(twoFactorEnabled: value),
        ),
        onChangePassword: () => ProfileNavigation.openChangePassword(context),
      ),
    );
  }
}
