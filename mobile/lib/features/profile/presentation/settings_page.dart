import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import '../state/profile_state.dart';
import '../widgets/settings_views.dart';

/// Settings hub (Figma Setting tree).
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).load();
    });
  }

  Future<void> _logout() async {
    final confirmed = await showAppDialog(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    Widget body;
    if (state.isLoading) {
      body = const AppLoading.page(message: 'Loading settings…');
    } else if (state.status == ProfileStatus.failure &&
        state.languages.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Could not load settings',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.danger,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () =>
                    ref.read(settingsControllerProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      body = SettingsHubView(state: state, onLogout: _logout);
    }

    return ProfileFormScaffold(title: 'Settings', child: body);
  }
}
