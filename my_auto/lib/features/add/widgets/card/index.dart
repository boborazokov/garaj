import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

class SellCard extends StatefulWidget {
  const SellCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.image,
    this.subtitle,
    this.icon,
    this.animationDelay = 0,
    this.height,
    this.gradient,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final String image;
  final int animationDelay;
  final double? height;
  /// Kept for call-site compatibility; unused after unslop.
  final List<Color>? gradient;

  @override
  State<SellCard> createState() => _SellCardState();
}

class _SellCardState extends State<SellCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final height = widget.height ?? MediaQuery.of(context).size.height * 0.18;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          borderRadius: AppRadius.rL,
          color: colors.surface,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.rL,
            child: Ink(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.rL,
                border: Border.all(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.icon != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: AppRadius.rM,
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(
                          widget.icon,
                          color: colors.textSecondary,
                          size: 20,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.arrowRight,
                          color: colors.primary,
                          size: 14,
                        ),
                      ],
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
