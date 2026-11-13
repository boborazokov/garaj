import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Uzbekistan mobile format: `+998 90 123 45 67` (2-3-2-2 after country code).
abstract final class UzbekPhone {
  static const countryCode = '998';
  static const prefix = '+998';
  static const inputPrefix = '+998 ';
  static const hint = '+998 90 123 45 67';

  /// Digits after country code only (max 9).
  static String localDigits(String? input) {
    var digits = (input ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(countryCode)) {
      digits = digits.substring(countryCode.length);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }
    return digits;
  }

  /// Display / input mask: `+998 90 123 45 67`.
  static String format(String? input) {
    final digits = localDigits(input);
    final buf = StringBuffer(prefix);
    if (digits.isEmpty) return inputPrefix;

    void chunk(int start, int end) {
      if (digits.length <= start) return;
      buf.write(' ');
      buf.write(digits.substring(start, end.clamp(start, digits.length)));
    }

    chunk(0, 2);
    chunk(2, 5);
    chunk(5, 7);
    chunk(7, 9);
    return buf.toString();
  }

  /// Wire format for API: `+998901234567`.
  static String normalize(String? input) {
    final digits = localDigits(input);
    return '$prefix$digits';
  }

  static bool isComplete(String? input) => localDigits(input).length == 9;

  /// Formats [controller] text in place (e.g. after loading from API).
  static void applyToController(TextEditingController controller) {
    final formatted = format(controller.text);
    if (controller.text == formatted) return;
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UzbekPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = UzbekPhone.format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
