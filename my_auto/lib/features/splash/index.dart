import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _checkAuth();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    final authed = await authProvider.tryAutoLogin();
    if (authed) {
      await authProvider.notifySessionRestored();
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    context.go(RoutesName.buttonNavigationBar);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryHover],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.rXl,
                  boxShadow: AppShadows.glow(colors.primary),
                ),
                child: Icon(LucideIcons.car,
                    color: colors.onPrimary, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                s.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                s.appMarketplaceTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
