import 'package:flutter/services.dart';

class UzbekPhoneNumberFormatter extends TextInputFormatter {
  static const String prefix = '+998 ';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('998')) {
      digits = digits.substring(3);
    }

    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    final buffer = StringBuffer(prefix);
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();

    int offset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
