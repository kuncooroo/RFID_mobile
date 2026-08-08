import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../navigation/checkout_navigation.dart';
import '../providers/checkout_providers.dart';
import '../widgets/payment_method_tile.dart';

/// Change Payment Method list (Figma 1:50).
class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() =>
      _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(checkoutControllerProvider);
      if (state.paymentMethods.isEmpty) {
        ref.read(checkoutControllerProvider.notifier).loadPaymentMethods();
      }
    });
  }

  void _onSelect(String paymentMethodId) {
    ref.read(checkoutControllerProvider.notifier).selectPaymentMethod(
          paymentMethodId,
        );
    CheckoutNavigation.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutControllerProvider);

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
        title: Text(
          'Change Payment Method',
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: false,
      ),
      body: state.isLoading && state.paymentMethods.isEmpty
          ? const AppLoading.page(message: 'Loading cards…')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              itemCount: state.paymentMethods.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.listItem),
              itemBuilder: (context, index) {
                final method = state.paymentMethods[index];
                return PaymentMethodTile(
                  method: method,
                  isSelected: state.selectedPaymentId == method.id,
                  onTap: () => _onSelect(method.id),
                );
              },
            ),
      bottomNavigationBar: Container(
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
            label: 'Add New Card',
            variant: AppButtonVariant.outline,
            onPressed: () => CheckoutNavigation.openAddCard(context),
          ),
        ),
      ),
    );
  }
}
