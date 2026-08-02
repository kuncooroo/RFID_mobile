import '../models/address.dart';
import '../models/payment_method.dart';

enum CheckoutStatus { initial, loading, ready, failure }

class CheckoutState {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.addresses = const [],
    this.selectedAddressId,
    this.paymentMethods = const [],
    this.selectedPaymentId,
    this.placingOrder = false,
    this.placedOrderId,
    this.errorMessage,
  });

  const CheckoutState.initial() : this();

  final CheckoutStatus status;
  final List<Address> addresses;
  final String? selectedAddressId;
  final List<PaymentMethod> paymentMethods;
  final String? selectedPaymentId;
  final bool placingOrder;
  final String? placedOrderId;
  final String? errorMessage;

  bool get isLoading =>
      status == CheckoutStatus.initial || status == CheckoutStatus.loading;

  bool get hasFailed => status == CheckoutStatus.failure;

  bool get isReady => status == CheckoutStatus.ready;

  Address? get selectedAddress {
    if (selectedAddressId == null) return null;
    for (final address in addresses) {
      if (address.id == selectedAddressId) return address;
    }
    return null;
  }

  PaymentMethod? get selectedPaymentMethod {
    if (selectedPaymentId == null) return null;
    for (final method in paymentMethods) {
      if (method.id == selectedPaymentId) return method;
    }
    return null;
  }

  bool get canContinueFromAddress =>
      selectedAddressId != null && addresses.isNotEmpty;

  bool get canPay =>
      selectedAddressId != null &&
      selectedPaymentId != null &&
      !placingOrder;

  CheckoutState copyWith({
    CheckoutStatus? status,
    List<Address>? addresses,
    String? selectedAddressId,
    List<PaymentMethod>? paymentMethods,
    String? selectedPaymentId,
    bool? placingOrder,
    String? placedOrderId,
    String? errorMessage,
    bool clearError = false,
    bool clearPlacedOrderId = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentId: selectedPaymentId ?? this.selectedPaymentId,
      placingOrder: placingOrder ?? this.placingOrder,
      placedOrderId: clearPlacedOrderId
          ? null
          : (placedOrderId ?? this.placedOrderId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Input for adding a new payment card.
class NewCardInput {
  const NewCardInput({
    required this.cardNumber,
    required this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  final String cardNumber;
  final String holderName;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
}
