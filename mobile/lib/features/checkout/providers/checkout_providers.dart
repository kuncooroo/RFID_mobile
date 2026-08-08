import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/providers/cart_providers.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_providers.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../repository/checkout_repository.dart';
import '../repository/mock_checkout_repository.dart';
import '../state/checkout_state.dart';
import '../../../src/network/api_client.dart';
import '../repository/remote_checkout_repository.dart';

/// Pass `--dart-define=USE_MOCK_CHECKOUT=true` to force the mock repository.
const bool kUseMockCheckoutRepository = bool.fromEnvironment(
  'USE_MOCK_CHECKOUT',
  defaultValue: false,
);

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  if (kUseMockCheckoutRepository) {
    return MockCheckoutRepository();
  }
  return RemoteCheckoutRepository(api: ref.watch(apiClientProvider));
});

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(
      CheckoutController.new,
    );

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState.initial();

  Future<void> loadAddresses() async {
    if (state.status == CheckoutStatus.loading) return;
    state = state.copyWith(status: CheckoutStatus.loading, clearError: true);
    try {
      final addresses = await ref
          .read(checkoutRepositoryProvider)
          .fetchAddresses();
      final defaultAddress = _defaultAddress(addresses);
      state = state.copyWith(
        status: CheckoutStatus.ready,
        addresses: addresses,
        selectedAddressId: defaultAddress?.id,
      );
    } catch (error) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadPaymentMethods() async {
    state = state.copyWith(clearError: true);
    try {
      final methods = await ref
          .read(checkoutRepositoryProvider)
          .fetchPaymentMethods();
      final defaultMethod = _defaultPaymentMethod(methods);
      state = state.copyWith(
        status: CheckoutStatus.ready,
        paymentMethods: methods,
        selectedPaymentId: state.selectedPaymentId ?? defaultMethod?.id,
      );
    } catch (error) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void selectAddress(String addressId) {
    state = state.copyWith(selectedAddressId: addressId);
  }

  void selectPaymentMethod(String paymentMethodId) {
    state = state.copyWith(selectedPaymentId: paymentMethodId);
  }

  Future<Address?> saveAddress(AddressInput input, {String? addressId}) async {
    state = state.copyWith(savingAddress: true, clearError: true);
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final saved = addressId == null
          ? await repo.createAddress(input)
          : await repo.updateAddress(addressId, input);

      final addresses = [...state.addresses];
      final index = addresses.indexWhere((a) => a.id == saved.id);
      if (index == -1) {
        addresses.add(saved);
      } else {
        addresses[index] = saved;
      }

      if (saved.isDefault) {
        for (var i = 0; i < addresses.length; i++) {
          if (addresses[i].id != saved.id && addresses[i].isDefault) {
            addresses[i] = addresses[i].copyWith(isDefault: false);
          }
        }
      }

      state = state.copyWith(
        savingAddress: false,
        status: CheckoutStatus.ready,
        addresses: addresses,
        selectedAddressId: saved.id,
      );
      return saved;
    } catch (error) {
      state = state.copyWith(
        savingAddress: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    state = state.copyWith(clearError: true);
    try {
      await ref.read(checkoutRepositoryProvider).deleteAddress(addressId);
      final addresses =
          state.addresses.where((a) => a.id != addressId).toList();
      final selectedStillValid =
          addresses.any((a) => a.id == state.selectedAddressId);
      state = state.copyWith(
        addresses: addresses,
        selectedAddressId: selectedStillValid
            ? state.selectedAddressId
            : _defaultAddress(addresses)?.id,
        clearSelectedAddress: !selectedStillValid && addresses.isEmpty,
      );
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return false;
    }
  }

  Future<PaymentMethod?> addCard(NewCardInput input) async {
    state = state.copyWith(clearError: true);
    try {
      final method = await ref.read(checkoutRepositoryProvider).addCard(input);
      final methods = [...state.paymentMethods, method];
      state = state.copyWith(
        paymentMethods: methods,
        selectedPaymentId: method.id,
      );
      return method;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return null;
    }
  }

  Future<String?> placeOrder() async {
    final addressId = state.selectedAddressId;
    final paymentId = state.selectedPaymentId;
    if (addressId == null || paymentId == null) return null;

    final cartState = ref.read(cartControllerProvider);
    final selectedItems = cartState.cart.items
        .where((item) => item.isSelected)
        .toList();
    if (selectedItems.isEmpty) {
      state = state.copyWith(errorMessage: 'No items selected for checkout.');
      return null;
    }

    state = state.copyWith(placingOrder: true, clearError: true);
    try {
      final subtotal = cartState.selectedSubtotal;
      const shippingFee = 0.0;
      final total = subtotal + shippingFee;

      final orderId = await ref.read(checkoutRepositoryProvider).placeOrder(
        addressId: addressId,
        paymentMethodId: paymentId,
        cartItemIds: selectedItems.map((item) => item.id).toList(),
        total: total,
      );

      Address? address;
      for (final candidate in state.addresses) {
        if (candidate.id == addressId) {
          address = candidate;
          break;
        }
      }

      final placedAt = DateTime.now();
      final rawId = orderId.replaceFirst(
        RegExp(r'^ord-', caseSensitive: false),
        '',
      );
      final orderNumber = orderId.toUpperCase().startsWith('KU-')
          ? orderId.toUpperCase()
          : 'KU-$rawId';

      final order = Order(
        id: orderId,
        orderNumber: orderNumber,
        status: OrderStatus.paid,
        total: total,
        subtotal: subtotal,
        shippingFee: shippingFee,
        currency: cartState.cart.currency,
        addressId: addressId,
        shippingAddressLabel: address?.oneLineLabel,
        paymentMethodId: paymentId,
        placedAt: placedAt,
        updatedAt: placedAt,
        items: [
          for (final item in selectedItems)
            OrderItem(
              id: 'oi-${item.id}',
              productId: item.productId,
              name: item.name,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              imageUrl: item.imageUrl,
              variantLabel: _variantLabel(item.colorName, item.size),
            ),
        ],
        tracking: buildInitialTracking(orderId: orderId, placedAt: placedAt),
      );

      await ref.read(ordersRepositoryProvider).createOrder(order);
      await ref.read(cartControllerProvider.notifier).removeSelectedItems();
      await ref.read(ordersControllerProvider.notifier).reloadAfterCheckout();

      state = state.copyWith(
        placingOrder: false,
        placedOrderId: orderId,
      );
      return orderId;
    } catch (error) {
      state = state.copyWith(
        placingOrder: false,
        errorMessage: error.toString(),
      );
      return null;
    }
  }

  void resetPlacedOrder() {
    state = state.copyWith(clearPlacedOrderId: true);
  }
}

Address? _defaultAddress(List<Address> addresses) {
  for (final address in addresses) {
    if (address.isDefault) return address;
  }
  return addresses.isNotEmpty ? addresses.first : null;
}

PaymentMethod? _defaultPaymentMethod(List<PaymentMethod> methods) {
  for (final method in methods) {
    if (method.isDefault) return method;
  }
  return methods.isNotEmpty ? methods.first : null;
}

String? _variantLabel(String? colorName, String? size) {
  final parts = <String>[
    if (colorName != null && colorName.trim().isNotEmpty) colorName.trim(),
    if (size != null && size.trim().isNotEmpty) size.trim(),
  ];
  if (parts.isEmpty) return null;
  return parts.join(' / ');
}
