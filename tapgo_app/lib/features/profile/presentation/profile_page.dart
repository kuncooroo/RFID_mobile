import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shell/widgets/shell_app_bar.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_view.dart';

/// My Profile tab screen (shell branch root).
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileControllerProvider.notifier).load();
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
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ShellAppBar(title: 'My Profile', showActions: false),
      body: ProfileView(
        state: state,
        onRetry: controller.load,
        onRefresh: controller.refresh,
        onLogout: _logout,
      ),
    );
  }
}
