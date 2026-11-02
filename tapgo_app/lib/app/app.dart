import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/router/auth_session.dart';
import '../features/profile/providers/profile_providers.dart';
import '../shared/design_system/app_theme.dart';
import '../shared/l10n/app_text.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final language = ref.watch(settingsControllerProvider).settings.languageCode;
    final text = AppText(language == 'id' ? 'id' : 'en');

    ref.listen(authSessionProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        ref.read(settingsControllerProvider.notifier).load();
      }
    });

    return MaterialApp.router(
      title: 'WanderDesa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: Locale(text.code),
      routerConfig: router,
      builder: (context, child) {
        return AppTextScope(
          text: text,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
