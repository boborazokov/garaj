import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

class CustomSearchInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  const CustomSearchInput({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.autoFocus = false,
  });

  @override
  State<CustomSearchInput> createState() => _CustomSearchInputState();
}

class _CustomSearchInputState extends State<CustomSearchInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        if (mounted) setState(() {});
      });

    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasText = widget.controller.text.isNotEmpty;
    final isFocused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(
          color: isFocused ? colors.primary : colors.border,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autoFocus,
        textCapitalization: TextCapitalization.none,
        style: TextStyle(color: colors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText ?? S.of(context).search,
          hintStyle: TextStyle(color: colors.textMuted, fontSize: 15),
          filled: false,
          prefixIcon:
              Icon(LucideIcons.search, size: 20, color: colors.textSecondary),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(LucideIcons.x, size: 18, color: colors.textSecondary),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
