import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
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

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 16, bottom: 10),
              child: Row(
                children: [
                  Icon(LucideIcons.fileText, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.of(context).description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.rL,
                border: Border.all(color: colors.border),
              ),
              child: Text(
                description.isEmpty ? '—' : description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
