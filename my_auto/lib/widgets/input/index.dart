import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/core/forms/text_input_capitalization.dart';
import 'package:my_auto/core/utils/phoneFormater.dart';
import 'package:my_auto/widgets/form/field_label.dart';

class CustomInput extends StatefulWidget {
  final Widget? icon;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final TextInputType? type;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool isTextarea;
  final bool readOnly;
  final void Function()? onTap;
  final String? label;
  final bool required;

  const CustomInput({
    super.key,
    this.icon,
    this.prefix,
    this.suffix,
    this.hintText,
    this.onTap,
    this.readOnly = false,
    this.type,
    required this.controller,
    this.focusNode,
    this.maxLength,
    this.onChanged,
    this.initialValue,
    this.validator,
    this.isTextarea = false,
    this.label,
    this.required = true,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late final List<TextInputFormatter> _inputFormatters;
  late final VoidCallback _controllerListener;
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _inputFormatters = widget.type == TextInputType.phone
        ? [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,+]')),
            UzbekPhoneNumberFormatter(),
          ]
        : mergeCapitalizationFormatters(
            autoCapitalize: shouldAutoCapitalizeText(keyboardType: widget.type),
            multiline: widget.isTextarea,
          );

    _controllerListener = () {
      widget.onChanged?.call(widget.controller.text);
      setState(() {});
    };

    widget.controller.addListener(_controllerListener);
    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasText = widget.controller.text.isNotEmpty;

    final field = TextFormField(
      maxLength:
          widget.maxLength ?? (widget.type == TextInputType.number ? 19 : null),
      controller: widget.controller,
      keyboardType: widget.type,
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      minLines: widget.isTextarea ? 3 : 1,
      maxLines: widget.isTextarea ? null : 1,
      obscureText:
          widget.type == TextInputType.visiblePassword ? _obscureText : false,
      textCapitalization: textCapitalizationFor(
        autoCapitalize: shouldAutoCapitalizeText(
          keyboardType: widget.type,
          obscureText: widget.type == TextInputType.visiblePassword && _obscureText,
        ),
        multiline: widget.isTextarea,
      ),
      inputFormatters: _inputFormatters,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.colorScheme.surface,
        counterText: "",
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintText: widget.hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey),

        prefixIcon: widget.icon != null
            ? IconTheme(
                data: IconThemeData(
                  color: _isFocused
                      ? colorScheme.primary
                      : (hasText ? colorScheme.onSurface : Colors.grey),
                ),
                child: widget.icon!,
              )
            : null,
        prefix: widget.prefix,
        suffix: widget.suffix,
        suffixIcon: widget.type == TextInputType.visiblePassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: _isFocused
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,

        // --- Borders unified through theme ---
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      validator: widget.validator ??
          (widget.required
              ? (value) {
                  if (widget.type == TextInputType.phone) {
                    return FormValidators.phone(context, value);
                  }
                  if (widget.type == TextInputType.visiblePassword) {
                    return FormValidators.password(context, value);
                  }
                  return FormValidators.required(context, value, minLength: 2);
                }
              : null),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(text: widget.label!, required: widget.required),
        field,
      ],
    );
  }
}
