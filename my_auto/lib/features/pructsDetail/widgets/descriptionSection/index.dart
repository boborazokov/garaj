import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';

class DescriptionSectionPart extends StatelessWidget {
  final String description;
  final String sellerPhone;

  const DescriptionSectionPart({
    super.key,
    required this.description,
    required this.sellerPhone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final text = description.trim().isEmpty ? '—' : description.trim();

    return SliverToBoxAdapter(
      child: ProductSection(
        title: S.of(context).description,
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            height: 1.55,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
