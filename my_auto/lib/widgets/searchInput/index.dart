import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';

/// Canonical search field — same look everywhere (no ink/splash artifacts).
class CustomSearchInput extends StatefulWidget {
  const CustomSearchInput({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autoFocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.showClear = true,
  });

  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autoFocus;
  final bool readOnly;
  final bool enabled;
  final bool showClear;

  static const double height = 48;
  static const double iconSize = 20;
  static const double clearIconSize = 18;

  @override
  State<CustomSearchInput> createState() => _CustomSearchInputState();
}

class _CustomSearchInputState extends State<CustomSearchInput> {
  FocusNode? _ownedFocus;
  late VoidCallback _controllerListener;

  FocusNode get _focus => widget.focusNode ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _focus.addListener(_onFocusChanged);
    _controllerListener = () {
      if (mounted) setState(() {});
    };
    widget.controller.addListener(_controllerListener);
  }

  @override
  void didUpdateWidget(covariant CustomSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_controllerListener);
      widget.controller.addListener(_controllerListener);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _ownedFocus?.removeListener(_onFocusChanged);
      if (widget.focusNode == null) {
        _ownedFocus ??= FocusNode();
      } else {
        _ownedFocus?.dispose();
        _ownedFocus = null;
      }
      _focus.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _focus.removeListener(_onFocusChanged);
    _ownedFocus?.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasText = widget.controller.text.isNotEmpty;
    final focused = _focus.hasFocus;
    final borderColor = focused
        ? colors.primary.withValues(alpha: 0.45)
        : colors.border.withValues(alpha: 0.7);
    final borderWidth = focused ? 1.5 : 1.0;

    return SizedBox(
      height: CustomSearchInput.height,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autoFocus,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        onTap: widget.onTap,
        cursorColor: colors.primary,
        cursorWidth: 1.5,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        enableSuggestions: false,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: colors.surfaceMuted,
          hintText: widget.hintText ?? S.of(context).search,
          hintStyle: TextStyle(
            color: colors.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            size: CustomSearchInput.iconSize,
            color: colors.textMuted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: CustomSearchInput.height,
          ),
          suffixIcon: widget.showClear && hasText && !widget.readOnly
              ? IconButton(
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    setState(() {});
                  },
                  icon: Icon(
                    LucideIcons.x,
                    size: CustomSearchInput.clearIconSize,
                    color: colors.textMuted,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
          border: _border(borderColor, width: borderWidth),
          enabledBorder: _border(borderColor, width: borderWidth),
          focusedBorder: _border(
            colors.primary.withValues(alpha: 0.45),
            width: 1.5,
          ),
          disabledBorder: _border(colors.border.withValues(alpha: 0.4)),
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
