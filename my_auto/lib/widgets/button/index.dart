import 'package:flutter/material.dart';

enum ButtonStyleType { filled, outlined, text }

class Button extends StatelessWidget {
  final String title;
  final bool isLoading;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double height;
  final IconData? icon;
  final ButtonStyleType style;

  const Button({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.height = 48,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
    this.style = ButtonStyleType.filled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor = switch (style) {
      ButtonStyleType.filled => backgroundColor ?? theme.colorScheme.primary,
      ButtonStyleType.outlined => Colors.transparent,
      ButtonStyleType.text => Colors.transparent,
    };

    final txtColor = textColor ??
        (style == ButtonStyleType.filled
            ? theme.colorScheme.onPrimary
            : backgroundColor ?? theme.colorScheme.primary);

    final border = style == ButtonStyleType.outlined
        ? BorderSide(
            color: borderColor ?? theme.colorScheme.primary, width: 1.5)
        : BorderSide.none;

    return Padding(
      padding: padding,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: txtColor.withOpacity(0.1),
          highlightColor: txtColor.withOpacity(0.05),
          child: SizedBox(
            height: height,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.linear,
                switchOutCurve: Curves.linear,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: txtColor,
                        ),
                      )
                    : Row(
                        key: const ValueKey('text'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 18, color: txtColor),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: txtColor,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
