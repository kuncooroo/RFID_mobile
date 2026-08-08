import '../models/address.dart';
import '../models/payment_method.dart';
import '../state/checkout_state.dart';
import 'checkout_repository.dart';
import 'mock_checkout_repository.dart';

/// Local checkout stand-in until Laravel checkout endpoints are wired.
class LocalCheckoutRepository implements CheckoutRepository {
  LocalCheckoutRepository() : _delegate = MockCheckoutRepository();

  final MockCheckoutRepository _delegate;

  @override
  Future<List<Address>> fetchAddresses() => _delegate.fetchAddresses();

  @override
  Future<Address> createAddress(AddressInput input) =>
      _delegate.createAddress(input);

  @override
  Future<Address> updateAddress(String addressId, AddressInput input) =>
      _delegate.updateAddress(addressId, input);

  @override
  Future<void> deleteAddress(String addressId) =>
      _delegate.deleteAddress(addressId);

  @override
  Future<List<PaymentMethod>> fetchPaymentMethods() =>
      _delegate.fetchPaymentMethods();

  @override
  Future<PaymentMethod> addCard(NewCardInput input) =>
      _delegate.addCard(input);

  @override
  Future<String> placeOrder({
    required String addressId,
    required String paymentMethodId,
    required List<String> cartItemIds,
    required double total,
  }) =>
      _delegate.placeOrder(
        addressId: addressId,
        paymentMethodId: paymentMethodId,
        cartItemIds: cartItemIds,
        total: total,
      );
}
