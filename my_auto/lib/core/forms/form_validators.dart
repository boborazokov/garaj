import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';

/// Shared [FormFieldValidator]s for the app.
abstract final class FormValidators {
  static String? required(
    BuildContext context,
    String? value, {
    int minLength = 1,
  }) {
    final t = (value ?? '').trim();
    if (t.length < minLength) {
      return S.of(context).fieldRequired;
    }
    return null;
  }

  static String? title(BuildContext context, String? value) =>
      required(context, value, minLength: 2);

  static String? phone(BuildContext context, String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      return S.of(context).fieldRequired;
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return S.of(context).fieldRequired;
    if (t.length < 6) return S.of(context).passwordLength;
    return null;
  }

  static String? optionalPhone(BuildContext context, String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return null;
    return phone(context, value);
  }
}
