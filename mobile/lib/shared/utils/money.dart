/// Shared currency / price formatting for catalog and commerce screens.
String formatMoney(
  num amount, {
  String currency = 'USD',
  int fractionDigits = 0,
}) {
  final symbol = currency == 'USD' ? '\$' : '$currency ';
  return '$symbol${amount.toStringAsFixed(fractionDigits)}';
}
