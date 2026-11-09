import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/layout/bottom_safe_button.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/onboarding/data/onboarding_prefs.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/button/index.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.body,
    required this.imageAsset,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String body;
  final String imageAsset;
  final IconData icon;
  final Color accent;
}

/// Value-first intro shown once on first app open.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  static const _pageCount = 3;

  List<OnboardingPageData> _pages(S s, AppColors colors) => [
        OnboardingPageData(
          title: s.onboardingPartsTitle,
          body: s.onboardingPartsBody,
          imageAsset: 'assets/images/parts.png',
          icon: LucideIcons.cog,
          accent: colors.primary,
        ),
        OnboardingPageData(
          title: s.onboardingServicesTitle,
          body: s.onboardingServicesBody,
          imageAsset: 'assets/images/service.png',
          icon: LucideIcons.wrench,
          accent: colors.textPrimary,
        ),
        OnboardingPageData(
          title: s.onboardingRequestsTitle,
          body: s.onboardingRequestsBody,
          imageAsset: 'assets/images/announcements.png',
          icon: LucideIcons.megaphone,
          accent: AppPalette.warning600,
        ),
      ];

  bool get _isLast => _index >= _pageCount - 1;

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await OnboardingPrefs.markCompleted();
    if (!mounted) return;
    context.go(RoutesName.buttonNavigationBar);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppMotion.base,
      curve: AppMotion.standard,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final pages = _pages(s, colors);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          children: [
            SizedBox(height: systemTopInset(context) + AppSpacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo_mark.png',
                    height: 28,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    semanticLabel: s.appTitle,
                  ),
                  const Spacer(),
                  Semantics(
                    button: true,
                    label: s.skip,
                    child: TextButton(
                      onPressed: _finishing ? null : _finish,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: colors.textSecondary,
                      ),
                      child: Text(s.skip),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                physics: reduceMotion
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemBuilder: (context, i) {
                  final page = pages[i];
                  return _OnboardingSlide(
                    page: page,
                    pageIndex: i,
                    pageCount: pages.length,
                  );
                },
              ),
            ),
            Semantics(
              liveRegion: true,
              label: s.onboardingProgress(_index + 1, _pageCount),
              child: _ProgressDots(
                count: _pageCount,
                index: _index,
                activeColor: colors.primary,
                inactiveColor: colors.border,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            BottomSafeButton(
              elevation: 0,
              backgroundColor: colors.background,
              child: Button(
                title: _isLast ? s.onboardingGetStarted : s.next,
                isLoading: _finishing,
                onTap: _finishing ? null : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.page,
    required this.pageIndex,
    required this.pageCount,
  });

  final OnboardingPageData page;
  final int pageIndex;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      label: '${page.title}. ${page.body}',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.l,
          AppSpacing.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: _HeroBanner(
                imageAsset: page.imageAsset,
                icon: page.icon,
                accent: page.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            ExcludeSemantics(
              child: Text(
                '${pageIndex + 1} / $pageCount',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.imageAsset,
    required this.icon,
    required this.accent,
  });

  final String imageAsset;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.rXl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: accent.withValues(alpha: 0.12),
                child: Icon(icon, size: 64, color: accent),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background.withValues(alpha: 0.05),
                    colors.background.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.l,
              bottom: AppSpacing.l,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.92),
                  borderRadius: AppRadius.rM,
                  border: Border.all(color: colors.border),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.count,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: AppRadius.rXl,
          ),
        );
      }),
    );
  }
}
