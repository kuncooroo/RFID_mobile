import '../models/address.dart';
import '../models/payment_method.dart';
import '../state/checkout_state.dart';
import 'checkout_repository.dart';

/// Seeded checkout repository for tests and UI demos.
class MockCheckoutRepository implements CheckoutRepository {
  MockCheckoutRepository({
    this.delay = const Duration(milliseconds: 350),
    this.shouldFail = false,
  })  : _addresses = List<Address>.from(_seedAddresses),
        _paymentMethods = List<PaymentMethod>.from(_seedPaymentMethods);

  final Duration delay;
  final bool shouldFail;
  final List<Address> _addresses;
  final List<PaymentMethod> _paymentMethods;
  int _orderCounter = 1042;

  @override
  Future<List<Address>> fetchAddresses() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load addresses');
    return List<Address>.unmodifiable(_addresses);
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to save address');
    final address = Address(
      id: 'addr-${_addresses.length + 1}',
      label: input.label,
      recipientName: input.recipientName,
      phone: input.phone,
      street: input.street,
      city: input.city,
      state: input.state,
      postalCode: input.postalCode,
      country: input.country,
      isDefault: input.isDefault || _addresses.isEmpty,
      notes: input.notes,
    );
    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
    return address;
  }

  @override
  Future<Address> updateAddress(String addressId, AddressInput input) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to update address');
    final index = _addresses.indexWhere((a) => a.id == addressId);
    if (index == -1) throw StateError('Address not found');
    final updated = _addresses[index].copyWith(
      label: input.label,
      recipientName: input.recipientName,
      phone: input.phone,
      street: input.street,
      city: input.city,
      state: input.state,
      postalCode: input.postalCode,
      country: input.country,
      isDefault: input.isDefault,
      notes: input.notes,
    );
    if (updated.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: i == index);
      }
    }
    _addresses[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to delete address');
    _addresses.removeWhere((a) => a.id == addressId);
  }

  @override
  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load payment methods');
    return List<PaymentMethod>.unmodifiable(_paymentMethods);
  }

  @override
  Future<PaymentMethod> addCard(NewCardInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (shouldFail) throw StateError('Unable to add card');

    final digits = input.cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '0000';
    final brand = _detectBrand(digits);

    final method = PaymentMethod(
      id: 'pm-${_paymentMethods.length + 1}',
      brand: brand,
      last4: last4,
      holderName: input.holderName,
      expiryMonth: input.expiryMonth,
      expiryYear: input.expiryYear,
      isDefault: _paymentMethods.isEmpty,
    );

    _paymentMethods.add(method);
    return method;
  }

  @override
  Future<String> placeOrder({
    required String addressId,
    required String paymentMethodId,
    required List<String> cartItemIds,
    required double total,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (shouldFail) throw StateError('Payment failed. Please try again.');
    if (cartItemIds.isEmpty) {
      throw StateError('No items selected for checkout.');
    }
    _orderCounter += 1;
    return 'ord-$_orderCounter';
  }

  String _detectBrand(String digits) {
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    if (digits.startsWith('3')) return 'Amex';
    return 'Card';
  }
}

final _seedAddresses = <Address>[
  const Address(
    id: 'addr-1',
    label: 'Home',
    recipientName: 'Alex Morgan',
    phone: '+1 555 010 2345',
    street: '742 Evergreen Terrace',
    city: 'Springfield',
    state: 'IL',
    postalCode: '62704',
    country: 'United States',
    isDefault: true,
  ),
  const Address(
    id: 'addr-2',
    label: 'Office',
    recipientName: 'Alex Morgan',
    phone: '+1 555 010 9876',
    street: '100 Market Street, Suite 400',
    city: 'San Francisco',
    state: 'CA',
    postalCode: '94105',
    country: 'United States',
  ),
];

final _seedPaymentMethods = <PaymentMethod>[
  const PaymentMethod(
    id: 'pm-1',
    brand: 'Visa',
    last4: '4242',
    holderName: 'Alex Morgan',
    expiryMonth: 8,
    expiryYear: 2027,
    isDefault: true,
  ),
  const PaymentMethod(
    id: 'pm-2',
    brand: 'Mastercard',
    last4: '8210',
    holderName: 'Alex Morgan',
    expiryMonth: 3,
    expiryYear: 2026,
  ),
];
