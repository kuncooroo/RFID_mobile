/// Rupiah formatting for catalog and commerce screens.
String formatMoney(
  num amount, {
  String currency = 'IDR',
  int fractionDigits = 0,
}) {
  final rounded = fractionDigits == 0 ? amount.round() : amount;
  final negative = rounded < 0;
  final digits = rounded.abs().toStringAsFixed(fractionDigits).split('.');
  final whole = digits.first;
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final fromEnd = whole.length - i;
    if (i != 0 && fromEnd % 3 == 0) buf.write('.');
    buf.write(whole[i]);
  }
  final fraction = digits.length > 1 ? ',${digits[1]}' : '';
  return '${negative ? '-' : ''}Rp ${buf.toString()}$fraction';
}
