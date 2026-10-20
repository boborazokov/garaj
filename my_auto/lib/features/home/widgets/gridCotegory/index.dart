import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/category_lucide_icon.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class GridCategories extends StatelessWidget {
  const GridCategories({
    super.key,
    required this.listCategory,
    this.onMoreTap,
    this.showAll = false,
  });

  final List<CategoryCar> listCategory;
  final VoidCallback? onMoreTap;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleNotifier>().locale?.languageCode ??
        categoryLanguageCode(context);

    if (listCategory.isEmpty) {
      return showAll
          ? Center(
              child: Text(
                S.of(context).noAvailable,
                style: TextStyle(color: context.appColors.textMuted),
              ),
            )
          : const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 600 ? 5 : 4;
        final maxVisible = crossAxisCount * 2 - 1;
        final visibleItems =
            showAll ? listCategory : listCategory.take(maxVisible).toList();

        final items = <Widget>[
          ...visibleItems.map(
            (item) => _CategoryTile(
              title: item.names.forLocale(lang),
              lucideIcon: resolveCategoryIcon(item),
              onTap: () => context.push(
                RoutesName.listOfItems,
                extra: item,
              ),
            ),
          ),
        ];

        if (!showAll) {
          items.add(_MoreTile(
            onTap: onMoreTap ??
                () => context.push(
                      RoutesName.categoriesScreen,
                      extra: type.PART.name,
                    ),
          ));
        }

        return GridView.builder(
          shrinkWrap: !showAll,
          physics: showAll
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: showAll ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: showAll ? 8 : 6,
            mainAxisSpacing: showAll ? 8 : 4,
            // Home: denser tiles so the grid doesn't look sparse/messy.
            childAspectRatio: showAll ? 0.88 : 0.82,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.lucideIcon,
    required this.onTap,
  });

  final String title;
  final IconData lucideIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rM,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.rM,
                ),
                child: Center(
                  child: Icon(
                    lucideIcon,
                    size: 22,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rM,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.rM,
                ),
                child: Icon(LucideIcons.layoutGrid, size: 22, color: colors.primary),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  S.of(context).more,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
