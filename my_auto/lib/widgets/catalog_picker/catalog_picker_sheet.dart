import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/form/field_label.dart';

/// Searchable bottom sheet to pick a catalog item (brand, model, part category).
Future<void> showCatalogPickerSheet(
  BuildContext context, {
  required String title,
  required List<CategoryNode> items,
  required ValueChanged<CategoryNode> onPick,
}) {
  final colors = context.appColors;
  final lang = categoryLanguageCode(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      var query = '';
      return StatefulBuilder(
        builder: (ctx, setState) {
          final filtered =
              items.where((i) => i.matchesSearch(query)).toList();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: S.of(ctx).search,
                      prefixIcon: const Icon(LucideIcons.search, size: 20),
                      filled: true,
                      fillColor: colors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.rL,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            S.of(ctx).noAvailable,
                            style: TextStyle(color: colors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final label = item.localizedName(lang);
                            return ListTile(
                              title: Text(
                                label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                              onTap: () {
                                onPick(item);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class CatalogPickerTile extends StatelessWidget {
  const CatalogPickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.required = false,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(
            text: label,
            required: required,
            padding: const EdgeInsets.only(left: 4, bottom: 6),
          ),
          Material(
            color: colors.surface,
            borderRadius: AppRadius.rL,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: AppRadius.rL,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.rL,
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        color: enabled ? colors.primary : colors.textMuted),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        value ?? s.select,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.2,
                          color: value != null
                              ? colors.textPrimary
                              : colors.textMuted,
                        ),
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: colors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
