import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../state/checkout_state.dart';
import 'checkout_repository.dart';

class RemoteCheckoutRepository implements CheckoutRepository {
  RemoteCheckoutRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<List<Address>> fetchAddresses() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.addresses,
      parser: _asList,
    );
    return list.map(Address.fromJson).toList();
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.addresses,
      data: input.toApiPayload(),
      parser: _asMap,
    );
    return Address.fromJson(data);
  }

  @override
  Future<Address> updateAddress(String addressId, AddressInput input) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.address(addressId),
      data: input.toApiPayload(),
      parser: _asMap,
    );
    return Address.fromJson(data);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _api.delete<dynamic>(ApiEndpoints.address(addressId));
  }

  @override
  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.paymentMethods,
      parser: _asList,
    );
    return list.map(PaymentMethod.fromJson).toList();
  }

  @override
  Future<PaymentMethod> addCard(NewCardInput input) async {
    final digits = input.cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.paymentMethods,
      data: {
        'type': 'card',
        'brand': _detectBrand(digits),
        'last4': last4,
        'holder_name': input.holderName,
        'expiry_month': input.expiryMonth,
        'expiry_year': input.expiryYear,
        'provider_token': 'tok_${digits.hashCode.abs()}',
        'is_default': true,
      },
      parser: _asMap,
    );
    return PaymentMethod.fromJson(data);
  }

  @override
  Future<String> placeOrder({
    required String addressId,
    required String paymentMethodId,
    required List<String> cartItemIds,
    required double total,
  }) async {
    // Ensure only requested cart lines are selected before checkout.
    final cart = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.cart,
      parser: _asMap,
    );
    final items = (cart['items'] as List?)?.whereType<Map>() ?? const [];
    for (final item in items) {
      final id = item['id']?.toString() ?? '';
      final shouldSelect = cartItemIds.contains(id);
      final isSelected = item['is_selected'] == true;
      if (id.isNotEmpty && shouldSelect != isSelected) {
        await _api.put<dynamic>(
          ApiEndpoints.cartItem(id),
          data: {'is_selected': shouldSelect},
        );
      }
    }

    final order = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.checkout,
      data: {
        'address_id': int.tryParse(addressId) ?? addressId,
        'payment_method_id': int.tryParse(paymentMethodId) ?? paymentMethodId,
      },
      parser: _asMap,
    );
    return order['id']?.toString() ?? order['order_number']?.toString() ?? '';
  }

  String _detectBrand(String digits) {
    if (digits.startsWith('4')) return 'visa';
    if (digits.startsWith('5')) return 'mastercard';
    if (digits.startsWith('3')) return 'amex';
    return 'card';
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
