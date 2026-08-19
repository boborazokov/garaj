import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/generated/l10n.dart';

/// Read-only placeholder for guests on the messages screen.
class GuestChatsPlaceholder extends StatelessWidget {
  const GuestChatsPlaceholder({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    final content = Padding(
      padding:
          EdgeInsets.fromLTRB(32, 16, 32, embedded ? 108 : 32),
      child: Column(
        mainAxisAlignment: embedded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageCircle,
              size: 56, color: colors.textMuted),
          const SizedBox(height: 16),
          Text(
            s.signInToContinue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.signInToContinueHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push(RoutesName.signin),
            child: Text(s.signIn),
          ),
        ],
      ),
    );

    if (embedded) {
      return AppSafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                s.messages,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Expanded(child: SingleChildScrollView(child: content)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.messages),
        centerTitle: false,
      ),
      body: Center(child: content),
    );
  }
}
