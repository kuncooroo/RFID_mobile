import '../models/address.dart';
import '../models/payment_method.dart';
import '../state/checkout_state.dart';

/// Contract for checkout flow operations.
abstract class CheckoutRepository {
  Future<List<Address>> fetchAddresses();

  Future<List<PaymentMethod>> fetchPaymentMethods();

  Future<PaymentMethod> addCard(NewCardInput input);

  Future<String> placeOrder({
    required String addressId,
    required String paymentMethodId,
    required List<String> cartItemIds,
    required double total,
  });
}
