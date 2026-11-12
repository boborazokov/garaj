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

    // Readable groups of 3 after +998 → +998 901 234 567
    final buffer = StringBuffer(prefix);
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
