class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(num? amount, {String symbol = 'PKR'}) {
    if (amount == null) return '$symbol 0';
    final value = amount.toDouble();
    final isNegative = value < 0;
    final abs = value.abs();

    final str = abs.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${isNegative ? '-' : ''}$symbol ${buffer.toString()}';
  }

  static String compact(num? amount, {String symbol = 'PKR'}) {
    if (amount == null) return '$symbol 0';
    final v = amount.toDouble();
    if (v >= 10000000) return '$symbol ${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '$symbol ${(v / 100000).toStringAsFixed(2)} L';
    if (v >= 1000) return '$symbol ${(v / 1000).toStringAsFixed(1)}K';
    return '$symbol ${v.toStringAsFixed(0)}';
  }
}