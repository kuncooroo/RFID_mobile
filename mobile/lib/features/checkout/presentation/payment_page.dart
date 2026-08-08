import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../cart/providers/cart_providers.dart';
import '../navigation/checkout_navigation.dart';
import '../providers/checkout_providers.dart';
import '../widgets/address_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_tile.dart';

/// Payment confirmation screen (Figma 1:48).
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(checkoutControllerProvider.notifier);
      final state = ref.read(checkoutControllerProvider);
      if (state.addresses.isEmpty) {
        controller.loadAddresses();
      }
      controller.loadPaymentMethods();
    });
  }

  Future<void> _onPayNow() async {
    final checkoutState = ref.read(checkoutControllerProvider);
    if (checkoutState.selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a delivery address first')),
      );
      CheckoutNavigation.pop(context);
      return;
    }
    if (checkoutState.selectedPaymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a payment method')),
      );
      return;
    }

    final orderId =
        await ref.read(checkoutControllerProvider.notifier).placeOrder();
    if (!mounted) return;
    if (orderId == null) {
      final error = ref.read(checkoutControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Payment failed. Please try again.')),
      );
      return;
    }
    CheckoutNavigation.openSuccess(context, orderId: orderId);
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final controller = ref.read(checkoutControllerProvider.notifier);
    final selectedItems = cartState.cart.items
        .where((item) => item.isSelected)
        .toList();
    final selectedMethod = checkoutState.selectedPaymentMethod;
    final selectedAddress = checkoutState.selectedAddress;
    final total = cartState.selectedSubtotal;

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
        title: Text('Payment', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: checkoutState.isLoading && checkoutState.paymentMethods.isEmpty
          ? const AppLoading.page(message: 'Loading payment…')
          : checkoutState.hasFailed && checkoutState.paymentMethods.isEmpty
          ? AppErrorState(
              title: 'Could not load payment',
              message: checkoutState.errorMessage ?? 'Please try again.',
              onRetry: controller.loadPaymentMethods,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxl,
              ),
              children: [
                if (selectedAddress != null) ...[
                  Text('Shipping Address', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AddressCard(
                    address: selectedAddress,
                    isSelected: true,
                    onTap: () => CheckoutNavigation.pop(context),
                  ),
                  const SizedBox(height: AppSpacing.section),
                ],
                OrderSummaryCard(
                  items: selectedItems,
                  subtotal: total,
                ),
                const SizedBox(height: AppSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payment Method',
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          CheckoutNavigation.openPaymentMethods(context),
                      child: Text('Change', style: AppTextStyles.link),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (selectedMethod != null)
                  PaymentMethodTile(
                    method: selectedMethod,
                    isSelected: true,
                    onTap: () =>
                        CheckoutNavigation.openPaymentMethods(context),
                    showRadio: false,
                  )
                else
                  Text(
                    'No payment method selected',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (checkoutState.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    checkoutState.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ],
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
            label: 'Pay Now · ${formatMoney(total)}',
            isLoading: checkoutState.placingOrder,
            onPressed: checkoutState.canPay && selectedItems.isNotEmpty
                ? _onPayNow
                : null,
          ),
        ),
      ),
    );
  }
}
