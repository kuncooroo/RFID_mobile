import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/splash_providers.dart';
import '../widgets/splash_view.dart';

/// App entry splash: restores session and hands off to GoRouter redirects.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(splashControllerProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splashControllerProvider);

    return Scaffold(
      body: SplashView(
        state: state,
        onRetry: () => ref.read(splashControllerProvider.notifier).retry(),
      ),
    );
  }
}
