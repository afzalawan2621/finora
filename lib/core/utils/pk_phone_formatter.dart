import 'package:flutter/services.dart';

/// Formats Pakistani phone numbers as: +92 3XX XXXXXXX
///
/// Examples:
///   03001234567   → +92 300 1234567
///   3001234567    → +92 300 1234567
///   923001234567  → +92 300 1234567
class PkPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Step 1: Remove the "+92 " prefix if it's already there
    var text = newValue.text;
    if (text.startsWith('+92 ')) {
      text = text.substring(4);
    } else if (text.startsWith('+92')) {
      text = text.substring(3);
    }

    // Step 2: Only keep digits from the remaining text
    var digits = text.replaceAll(RegExp(r'\D'), '');

    // Step 3: Strip leading 0 if user typed it
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // Step 4: Strip leading 92 if user typed/pasted it
    if (digits.startsWith('92') && digits.length > 10) {
      digits = digits.substring(2);
    }

    // Step 5: Cap at 10 digits
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    // Step 6: If no digits → return empty
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Step 7: Build formatted string
    final buffer = StringBuffer();
    buffer.write('+92 ');

    for (int i = 0; i < digits.length; i++) {
      if (i == 3) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}