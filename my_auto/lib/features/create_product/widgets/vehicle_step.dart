import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_auto/generated/l10n.dart';

class VehicleStep extends StatelessWidget {
  const VehicleStep({super.key, this.compact = false});

  final bool compact;

  void _openSheet(
    BuildContext context, {
    required String title,
    required List<CategoryNode> items,
    required ValueChanged<CategoryNode> onPick,
  }) {
    final colors = context.appColors;
    final lang = categoryLanguageCode(context);
    showModalBottomSheet<void>(
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
                    padding: const EdgeInsets.all(16),
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: S.of(ctx).search,
                        prefixIcon: const Icon(LucideIcons.search),
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
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        return ListTile(
                          title: Text(item.localizedName(lang)),
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

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateProductBloc>();
    final state = context.watch<CreateProductBloc>().state;
    final v = state.draft.vehicle;
    final colors = context.appColors;
    final s = S.of(context);
    final lang = categoryLanguageCode(context);

    final brands = state.categoryTree;
    List<CategoryNode> partCats = state.partCategories;
    if (v.modelId != null) {
      CategoryNode? modelNode;
      for (final brand in state.categoryTree) {
        modelNode = brand.findById(v.modelId!);
        if (modelNode != null) break;
      }
      final fromModel = modelNode?.children.where((c) => c.isPart).toList() ?? [];
      if (fromModel.isNotEmpty) partCats = fromModel;
    }

    return ListView(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(
        compact ? 0 : 16,
        compact ? 0 : 8,
        compact ? 0 : 16,
        compact ? 0 : 120,
      ),
      children: [
        Text(
          s.createProductVehicleTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          s.createProductVehicleHint,
          style: TextStyle(color: colors.textMuted),
        ),
        if (state.recentVehicles.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(s.createProductRecentlyUsed,
              style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.recentVehicles.map((rv) {
              final label =
                  '${rv.brandName ?? ''} ${rv.modelName ?? ''}'.trim();
              return ActionChip(
                label: Text(label.isEmpty ? s.createProductStepVehicle : label),
                onPressed: () => bloc.add(CreateProductVehicleUpdated(rv)),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 20),
        _PickerTile(
          label: s.createProductBrand,
          value: v.brandName,
          icon: LucideIcons.car,
          onTap: () => _openSheet(
            context,
            title: s.selectBrand,
            items: brands,
            onPick: (n) => bloc.add(
                  CreateProductVehicleUpdated(
                    VehicleSelection(
                      brandId: n.id,
                      brandName: n.localizedName(lang),
                      year: v.year,
                    ),
                  ),
                ),
          ),
        ),
        _PickerTile(
          label: s.carModel,
          value: v.modelName,
          icon: LucideIcons.layers,
          enabled: v.brandId != null,
          onTap: v.brandId == null
              ? null
              : () async {
                  final models =
                      await bloc.loadModelsForBrand(v.brandId!);
                  if (!context.mounted) return;
                  if (models.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.createProductNoModels),
                      ),
                    );
                    return;
                  }
                  _openSheet(
                    context,
                    title: s.selectModel,
                    items: models,
                    onPick: (n) => bloc.add(
                      CreateProductVehicleUpdated(
                        VehicleSelection(
                          brandId: v.brandId,
                          brandName: v.brandName,
                          modelId: n.id,
                          modelName: n.localizedName(lang),
                          year: v.year,
                        ),
                      ),
                    ),
                  );
                },
        ),
        _PickerTile(
          label: s.createProductPartCategory,
          value: v.partCategoryName,
          icon: LucideIcons.tag,
          onTap: () => _openSheet(
            context,
            title: s.selectPartCategory,
            items: partCats,
            onPick: (n) => bloc.add(
                  CreateProductVehicleUpdated(
                    v.copyWith(
                      partCategoryId: n.id,
                      partCategoryName: n.localizedName(lang),
                    ),
                  ),
                ),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        _VehicleYearField(
          initialYear: v.year,
          onChanged: (year) => bloc.add(
            CreateProductVehicleUpdated(v.copyWith(year: year)),
          ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: AppRadius.rL,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: enabled ? colors.primary : colors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        value?.isNotEmpty == true ? value! : '—',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: enabled
                              ? colors.textPrimary
                              : colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: enabled ? colors.textMuted : colors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleYearField extends StatefulWidget {
  const _VehicleYearField({
    required this.initialYear,
    required this.onChanged,
  });

  final int? initialYear;
  final ValueChanged<int?> onChanged;

  @override
  State<_VehicleYearField> createState() => _VehicleYearFieldState();
}

class _VehicleYearFieldState extends State<_VehicleYearField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialYear?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _VehicleYearField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialYear != widget.initialYear) {
      _controller.text = widget.initialYear?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: s.createProductYearOptional,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: AppRadius.rL),
      ),
      onChanged: (v) {
        final parsed = int.tryParse(v.trim());
        widget.onChanged(parsed);
      },
    );
  }
}
