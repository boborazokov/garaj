import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/core/forms/text_input_capitalization.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/widgets/form/field_label.dart';

/// Labeled [TextFormField] with optional required marker and validation.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.minLength = 2,
    this.capitalize,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final int minLength;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  /// When null, capitalizes text fields except phone/email/number/password.
  final bool? capitalize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final autoCap = shouldAutoCapitalizeText(
      keyboardType: keyboardType,
      formatters: inputFormatters,
      enabled: capitalize,
    );
    final formatters = mergeCapitalizationFormatters(
      formatters: inputFormatters,
      autoCapitalize: autoCap,
      multiline: maxLines > 1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: required),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          textCapitalization: textCapitalizationFor(
            autoCapitalize: autoCap,
            multiline: maxLines > 1,
          ),
          inputFormatters: formatters,
          validator: validator ??
              (required
                  ? (v) {
                      if (keyboardType == TextInputType.phone) {
                        return FormValidators.phone(context, v);
                      }
                      if (maxLines > 1 && (v ?? '').trim().isEmpty) {
                        return null;
                      }
                      return FormValidators.required(
                        context,
                        v,
                        minLength: minLength,
                      );
                    }
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(icon, size: 18, color: colors.primary),
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: colors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide(color: colors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
