import 'package:flutter/services.dart';

/// Whether to auto-capitalize the first letter (and sentence starts for multiline).
bool shouldAutoCapitalizeText({
  TextInputType? keyboardType,
  bool obscureText = false,
  List<TextInputFormatter>? formatters,
  bool? enabled,
}) {
  if (enabled == false) return false;
  if (enabled == true) return true;
  if (obscureText) return false;

  final type = keyboardType ?? TextInputType.text;
  if (type == TextInputType.phone ||
      type == TextInputType.emailAddress ||
      type == TextInputType.number ||
      type == TextInputType.datetime ||
      type == TextInputType.visiblePassword ||
      type == TextInputType.url) {
    return false;
  }

  for (final f in formatters ?? const []) {
    if (f is FilteringTextInputFormatter) {
      final pattern = f.filterPattern.toString();
      if (pattern.contains(r'[0-9') && !pattern.contains(r'a-z')) {
        return false;
      }
    }
  }

  return true;
}

TextCapitalization textCapitalizationFor({
  required bool autoCapitalize,
  required bool multiline,
}) {
  if (!autoCapitalize) return TextCapitalization.none;
  return multiline ? TextCapitalization.sentences : TextCapitalization.sentences;
}

List<TextInputFormatter> mergeCapitalizationFormatters({
  List<TextInputFormatter>? formatters,
  required bool autoCapitalize,
  required bool multiline,
}) {
  final merged = <TextInputFormatter>[...?formatters];
  if (!autoCapitalize) return merged;
  merged.add(
    multiline
        ? const SentenceCapitalizationFormatter()
        : const FirstLetterCapitalizationFormatter(),
  );
  return merged;
}

/// Uppercases the first letter in the field (titles, names).
class FirstLetterCapitalizationFormatter extends TextInputFormatter {
  const FirstLetterCapitalizationFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final fixed = capitalizeFirstLetter(text);
    if (fixed == text) return newValue;
    return newValue.copyWith(
      text: fixed,
      composing: TextRange.empty,
    );
  }
}

/// Uppercases the first letter and after line breaks / sentence endings.
class SentenceCapitalizationFormatter extends TextInputFormatter {
  const SentenceCapitalizationFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final fixed = capitalizeSentences(text);
    if (fixed == text) return newValue;
    return newValue.copyWith(
      text: fixed,
      composing: TextRange.empty,
    );
  }
}

final RegExp _letter = RegExp(r'[a-zA-Zа-яА-ЯёЁіІқҚғҒўЎ]');

String capitalizeFirstLetter(String text) {
  final i = _firstLetterIndex(text);
  if (i < 0) return text;
  return text.replaceRange(i, i + 1, text[i].toUpperCase());
}

String capitalizeSentences(String text) {
  final buf = StringBuffer();
  var capNext = true;

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (capNext && _letter.hasMatch(c)) {
      buf.write(c.toUpperCase());
      capNext = false;
    } else {
      buf.write(c);
      if (c == '\n' || c == '.' || c == '!' || c == '?') {
        capNext = true;
      } else if (c != ' ' && c != '\t') {
        capNext = false;
      }
    }
  }

  return buf.toString();
}

int _firstLetterIndex(String text) {
  for (var i = 0; i < text.length; i++) {
    if (_letter.hasMatch(text[i])) return i;
  }
  return -1;
}
