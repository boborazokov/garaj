import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart'
    show type;
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

/// Horizontal gradient category cards (replacing bulky grid).
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.isLoading,
    this.showHeader = true,
  });

  final List<CategoryCar> categories;
  final bool isLoading;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final lang = context.watch<LocaleNotifier>().locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: MarketUi.spacingLG),
        child: SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Container(
              width: 112,
              decoration: MarketUi.card(context, colors),
            ),
          ),
        ),
      );
    }

    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: MarketUi.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            MarketSectionTitle(
              title: s.parts,
              trailingLabel: s.seeAll,
              onTrailing: () => context.push(
                RoutesName.categoriesScreen,
                extra: type.PART.name,
              ),
            ),
          ],
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: MarketUi.spacingMD),
              itemCount: categories.length > 24 ? 24 : categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final c = categories[i];
                final fullLabel = c.localizedName(lang);
                final shortLabel =
                    c.names.compactForLocale(lang, maxChars: 20);
                return _GradientCategoryCard(
                  name: shortLabel,
                  iconUrl: c.iconUrl,
                  onTap: () => context.push(
                    RoutesName.search,
                    extra: {
                      'unifiedSearch': true,
                      'unifiedInitialQuery': fullLabel,
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientCategoryCard extends StatelessWidget {
  const _GradientCategoryCard({
    required this.name,
    required this.iconUrl,
    required this.onTap,
  });

  final String name;
  final String? iconUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: MarketUi.cardRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: MarketUi.cardRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: 0.12),
                colors.surface,
              ],
            ),
            boxShadow: MarketUi.softElev(context),
          ),
          child: SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (iconUrl != null && iconUrl!.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Image.network(
                          iconUrl!,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.category_rounded,
                            color: colors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(Icons.category_rounded,
                        color: colors.primary, size: 26),
                  const Spacer(),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.2,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
