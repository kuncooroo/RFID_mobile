import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/rfid_navigation.dart';
import '../providers/rfid_providers.dart';
import '../state/rfid_scan_state.dart';
import '../widgets/face_get_started_view.dart';
import '../widgets/face_hold_still_view.dart';
import '../widgets/face_success_view.dart';

/// Face ID / RFID member verification — Get started → Hold still → Success.
class RfidScanScreen extends ConsumerStatefulWidget {
  const RfidScanScreen({super.key});

  @override
  ConsumerState<RfidScanScreen> createState() => _RfidScanScreenState();
}

class _RfidScanScreenState extends ConsumerState<RfidScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(rfidScanControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rfidScanControllerProvider);
    final controller = ref.read(rfidScanControllerProvider.notifier);

    return switch (state.step) {
      FaceVerifyStep.getStarted => FaceGetStartedView(
          onBack: () => RfidNavigation.pop(context),
          onNotNow: () => RfidNavigation.pop(context),
          onGetStarted: controller.getStarted,
        ),
      FaceVerifyStep.holdStill => FaceHoldStillView(
          progress: state.progress,
          rfidUid: state.rfidUid,
          isSubmitting: state.isSubmitting,
          onBack: controller.reset,
          onRfidCaptured: controller.setRfidUid,
          onCapture: (imagePath, rfidUid) => controller.captureAndSave(
            imagePath: imagePath,
            rfidUid: rfidUid,
          ),
        ),
      FaceVerifyStep.success => FaceSuccessView(
          memberId: state.memberId,
          onBack: () => RfidNavigation.pop(context),
          onStartShopping: () => RfidNavigation.goHome(context),
        ),
      FaceVerifyStep.failure => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: controller.reset,
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Verification failed',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Please try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: controller.reset,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
    };
  }
}
