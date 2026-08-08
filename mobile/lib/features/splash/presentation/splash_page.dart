import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_session.dart';
import '../models/splash_statistic.dart';
import '../navigation/splash_navigation.dart';
import '../providers/splash_providers.dart';
import '../widgets/splash_view.dart';

/// App entry splash + Statistics intro (Figma `1:18`).
///
/// Restores session, then either auto-continues for returning users or shows
/// the marketing Statistics screen with a Get Started CTA.
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

  void _continue() {
    final session = ref.read(authSessionProvider);
    SplashNavigation.goToResolvedDestination(context, session);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splashControllerProvider);
    final statisticsAsync = ref.watch(splashStatisticsProvider);
    final statistics = statisticsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => kDefaultSplashStatistics,
    );

    ref.listen(splashControllerProvider, (previous, next) {
      if (!next.shouldAutoNavigate) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _continue();
      });
    });

    return Scaffold(
      body: SplashView(
        state: state,
        statistics: statistics,
        onRetry: () => ref.read(splashControllerProvider.notifier).retry(),
        onGetStarted: () {
          if (state.hasFailed) {
            // Fail-open already applied an unauthenticated/first-run session.
            ref.read(splashControllerProvider.notifier).continueFromIntro();
            return;
          }
          ref.read(splashControllerProvider.notifier).continueFromIntro();
        },
      ),
    );
  }
}
