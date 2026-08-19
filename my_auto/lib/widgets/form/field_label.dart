import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Field caption with optional red asterisk for required inputs.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.text,
    this.required = false,
    this.padding = const EdgeInsets.only(left: 4, bottom: 6),
    this.style,
  });

  final String text;
  final bool required;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = style ??
        TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        );

    return Padding(
      padding: padding,
      child: RichText(
        text: TextSpan(
          style: base,
          children: [
            TextSpan(text: text),
            if (required)
              TextSpan(
                text: ' *',
                style: base.copyWith(
                  color: colors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Decoration label with trailing `*` when [required].
String formDecorationLabel(String label, {bool required = false}) =>
    required ? '$label *' : label;
