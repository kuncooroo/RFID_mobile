import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../navigation/checkout_navigation.dart';
import '../providers/checkout_providers.dart';
import '../state/checkout_state.dart';
import '../widgets/address_card.dart';

/// Shipping address selection (Figma 1:49).
class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(checkoutControllerProvider.notifier).loadAddresses();
    });
  }

  void _onContinue() {
    final state = ref.read(checkoutControllerProvider);
    if (!state.canContinueFromAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a delivery address')),
      );
      return;
    }
    CheckoutNavigation.openPayment(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);
    final controller = ref.read(checkoutControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => CheckoutNavigation.pop(context),
        ),
        title: Text('Address', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: _buildBody(state, controller),
      bottomNavigationBar: state.addresses.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  label: 'Continue',
                  onPressed: state.canContinueFromAddress ? _onContinue : null,
                ),
              ),
            ),
    );
  }

  Widget _buildBody(CheckoutState state, CheckoutController controller) {
    if (state.isLoading && state.addresses.isEmpty) {
      return const AppLoading.page(message: 'Loading addresses…');
    }

    if (state.hasFailed && state.addresses.isEmpty) {
      return AppErrorState(
        title: 'Could not load addresses',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: controller.loadAddresses,
      );
    }

    if (state.addresses.isEmpty) {
      return Center(
        child: Text(
          'No saved addresses yet.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      itemCount: state.addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listItem),
      itemBuilder: (context, index) {
        final address = state.addresses[index];
        return AddressCard(
          address: address,
          isSelected: state.selectedAddressId == address.id,
          onTap: () => controller.selectAddress(address.id),
        );
      },
    );
  }
}
