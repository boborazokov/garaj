import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
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
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).description,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                height: 1.55,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
