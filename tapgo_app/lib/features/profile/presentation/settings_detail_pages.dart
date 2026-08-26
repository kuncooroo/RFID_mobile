import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_loading.dart';
import '../providers/profile_providers.dart';
import '../widgets/settings_views.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    return ProfileFormScaffold(
      title: 'Notifications',
      child: state.isLoading
          ? const AppLoading.page()
          : NotificationSettingsView(
              settings: state.settings,
              onChanged: (settings) async {
                final ok = await ref
                    .read(settingsControllerProvider.notifier)
                    .updateSettings(settings);
                if (!context.mounted || !ok) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification preferences saved'),
                  ),
                );
              },
            ),
    );
  }
}
