import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_view.dart';

/// First-run onboarding carousel before auth.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(onboardingControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    ref.listen(onboardingControllerProvider, (previous, next) {
      if (previous?.currentIndex == next.currentIndex) return;
      if (!_pageController.hasClients) return;
      if (_pageController.page?.round() == next.currentIndex) return;
      _pageController.animateToPage(
        next.currentIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });

    return Scaffold(
      body: OnboardingView(
        state: state,
        pageController: _pageController,
        onPageChanged: controller.setPageIndex,
        onCreateAccount: controller.createAccount,
        onSignIn: controller.signIn,
        onRetry: controller.retry,
      ),
    );
  }
}
