import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/domain/create_product_messages.dart';
import 'package:my_auto/features/create_product/widgets/product_condition_selector.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/core/forms/text_input_capitalization.dart';
import 'package:my_auto/widgets/form/field_label.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_auto/generated/l10n.dart';

class ProductInfoStep extends StatefulWidget {
  const ProductInfoStep({super.key, this.compact = false});

  final bool compact;

  @override
  State<ProductInfoStep> createState() => _ProductInfoStepState();
}

class _ProductInfoStepState extends State<ProductInfoStep> {
  late final TextEditingController _title;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    final d = context.read<CreateProductBloc>().state.draft;
    _title = TextEditingController(text: d.title);
    _desc = TextEditingController(text: d.description);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final state = context.watch<CreateProductBloc>().state;
    final bloc = context.read<CreateProductBloc>();

    return ListView(
      shrinkWrap: widget.compact,
      physics: widget.compact
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: EdgeInsets.fromLTRB(
        widget.compact ? 0 : 16,
        widget.compact ? 0 : 8,
        widget.compact ? 0 : 16,
        widget.compact ? 0 : 120,
      ),
      children: [
        Text(
          s.createProductInfoTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        FieldLabel(text: s.title, required: true),
        TextFormField(
          controller: _title,
          textCapitalization: textCapitalizationFor(
            autoCapitalize: true,
            multiline: false,
          ),
          inputFormatters: mergeCapitalizationFormatters(
            autoCapitalize: true,
            multiline: false,
          ),
          validator: (v) => FormValidators.title(context, v),
          decoration: InputDecoration(
            hintText: s.createProductTitleHint,
            filled: true,
            fillColor: colors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => bloc.add(CreateProductTitleChanged(v)),
        ),
        if (state.duplicateWarning != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.12),
              borderRadius: AppRadius.rM,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.alertTriangle, color: colors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizeCreateProductError(s, state.duplicateWarning!),
                    style: TextStyle(fontSize: 12, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        ProductConditionSelector(
          value: state.draft.condition,
          onChanged: (c) => bloc.add(CreateProductConditionChanged(c)),
        ),
        const SizedBox(height: 16),
        FieldLabel(text: s.description, required: false),
        TextField(
          controller: _desc,
          maxLines: 5,
          textCapitalization: textCapitalizationFor(
            autoCapitalize: true,
            multiline: true,
          ),
          inputFormatters: mergeCapitalizationFormatters(
            autoCapitalize: true,
            multiline: true,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            filled: true,
            fillColor: colors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => bloc.add(CreateProductDescriptionChanged(v)),
        ),
        if (state.draft.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: state.draft.tags
                .map((t) => Chip(label: Text('#$t'), visualDensity: VisualDensity.compact))
                .toList(),
          ),
        ],
      ],
    );
  }
}
