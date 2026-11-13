import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_top_bar.dart';
import 'package:my_auto/widgets/button/index.dart';

/// Auth shell: scrollable form on top, docked CTA in the thumb zone.
///
/// Uses a [Column] (not [Scaffold.bottomNavigationBar] + keyboard padding) so
/// fields never hide under the button, and the keyboard lifts the whole column.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.isLoading = false,
    this.showSkip = true,
    this.primaryEnabled = true,
    this.footer,
  });

  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final bool showSkip;
  final bool primaryEnabled;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final homePad = systemBottomInset(context);
    // Scaffold already shrinks above the keyboard — only pad the home indicator.
    final bottomPad = keyboard > 0 ? AppSpacing.m : homePad + AppSpacing.m;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.background,
      appBar: AuthTopBar(showSkip: showSkip),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.2),
            colors: [
              isDark
                  ? colors.primary.withValues(alpha: 0.10)
                  : AppPalette.primary100.withValues(alpha: 0.45),
              colors.background,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: body),
            Material(
              color: colors.surface,
              elevation: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.m,
                    AppSpacing.screenPadding,
                    bottomPad,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Button(
                        isLoading: isLoading,
                        title: primaryLabel,
                        onTap: primaryEnabled ? onPrimary : null,
                        height: 48,
                        borderRadius: AppRadius.m,
                        padding: EdgeInsets.zero,
                        textColor: colors.onDark,
                      ),
                      if (footer != null) footer!,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
