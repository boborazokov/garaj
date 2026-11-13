import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/core/forms/text_input_capitalization.dart';
import 'package:my_auto/core/theme/tokens.dart';
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
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

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
    this.autofillHints,
    this.textInputAction,
    this.onFieldSubmitted,
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

    final isPhone = widget.type == TextInputType.phone;
    _inputFormatters = isPhone
        ? [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
            UzbekPhoneNumberFormatter(),
          ]
        : mergeCapitalizationFormatters(
            autoCapitalize: shouldAutoCapitalizeText(keyboardType: widget.type),
            multiline: widget.isTextarea,
          );

    if (isPhone) {
      UzbekPhone.applyToController(widget.controller);
    }

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

    final mutedIcon = colorScheme.onSurfaceVariant;
    final isPassword = widget.type == TextInputType.visiblePassword;

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
      obscureText: isPassword ? _obscureText : false,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autocorrect: widget.type == TextInputType.phone || isPassword
          ? false
          : true,
      enableSuggestions: !isPassword,
      textCapitalization: textCapitalizationFor(
        autoCapitalize: shouldAutoCapitalizeText(
          keyboardType: widget.type,
          obscureText: isPassword && _obscureText,
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
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: 14,
        ),
        hintText: widget.hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: mutedIcon,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: widget.icon != null
            ? IconTheme(
                data: IconThemeData(
                  size: 20,
                  color: _isFocused
                      ? colorScheme.primary
                      : (hasText ? colorScheme.onSurface : mutedIcon),
                ),
                child: widget.icon!,
              )
            : null,
        prefix: widget.prefix,
        suffix: widget.suffix,
        suffixIcon: isPassword
            ? IconButton(
                tooltip: _obscureText ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 20,
                  color: _isFocused ? colorScheme.primary : mutedIcon,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rM,
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.55),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rM,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rM,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rM,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      validator: widget.validator ??
          (widget.required
              ? (value) {
                  if (widget.type == TextInputType.phone) {
                    return FormValidators.phone(context, value);
                  }
                  if (isPassword) {
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
