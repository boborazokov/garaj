import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/widgets/delivery_option_selector.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/form/field_label.dart';

/// Listing price only — no promotion / TOP packages on this step.
class PriceStep extends StatefulWidget {
  const PriceStep({super.key, this.compact = false});

  final bool compact;

  @override
  State<PriceStep> createState() => _PriceStepState();
}

class _PriceStepState extends State<PriceStep> {
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    final p = context.read<CreateProductBloc>().state.draft.price;
    _price = TextEditingController(text: p == null ? '' : _group(p));
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  static String _group(int value) {
    final digits = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  int? _parsePrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  void _onPriceChanged(String raw) {
    final parsed = _parsePrice(raw);
    final formatted = parsed == null ? '' : _group(parsed);
    if (formatted != raw) {
      _price.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    context.read<CreateProductBloc>().add(CreateProductPriceChanged(parsed));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final state = context.watch<CreateProductBloc>().state;
    final bloc = context.read<CreateProductBloc>();
    final theme = Theme.of(context);

    return ListView(
      shrinkWrap: widget.compact,
      physics:
          widget.compact ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(
        widget.compact ? 0 : AppSpacing.screenPadding,
        widget.compact ? 0 : AppSpacing.s,
        widget.compact ? 0 : AppSpacing.screenPadding,
        widget.compact ? 0 : 120,
      ),
      children: [
        Text(
          s.createProductPriceTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          s.createProductPriceHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        FieldLabel(text: s.price, required: true),
        const SizedBox(height: AppSpacing.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  letterSpacing: -0.3,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.l,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.rL,
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rL,
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.rL,
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
                onChanged: _onPriceChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Column(
              children: [
                for (final code in const ['UZS', 'USD']) ...[
                  if (code != 'UZS') const SizedBox(height: AppSpacing.s),
                  SizedBox(
                    width: 88,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () =>
                          bloc.add(CreateProductCurrencyChanged(code)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: state.draft.currency == code
                            ? colors.primary.withValues(alpha: 0.08)
                            : colors.surface,
                        foregroundColor: state.draft.currency == code
                            ? colors.primary
                            : colors.textSecondary,
                        side: BorderSide(
                          color: state.draft.currency == code
                              ? colors.primary
                              : colors.border,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.rM,
                        ),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Material(
          color: colors.surface,
          borderRadius: AppRadius.rL,
          child: InkWell(
            borderRadius: AppRadius.rL,
            onTap: () => bloc.add(
              CreateProductNegotiableChanged(!state.draft.negotiable),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: AppRadius.rL,
                border: Border.all(color: colors.border),
              ),
              child: SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.xs,
                ),
                title: Text(
                  s.createProductNegotiableTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  s.createProductNegotiableSubtitle,
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
                value: state.draft.negotiable,
                onChanged: (v) => bloc.add(CreateProductNegotiableChanged(v)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          s.delivery,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        DeliveryOptionSelector(
          value: state.draft.delivery,
          onChanged: (d) => bloc.add(CreateProductDeliveryChanged(d)),
        ),
      ],
    );
  }
}
