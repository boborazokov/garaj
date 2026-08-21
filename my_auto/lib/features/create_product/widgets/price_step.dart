import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/widgets/delivery_option_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_auto/generated/l10n.dart';

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
    _price = TextEditingController(text: p?.toString() ?? '');
  }

  @override
  void dispose() {
    _price.dispose();
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
          s.createProductPriceTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  filled: true,
                  fillColor: colors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.rL,
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) =>
                    bloc.add(CreateProductPriceChanged(int.tryParse(v))),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: state.draft.currency,
              items: const [
                DropdownMenuItem(value: 'UZS', child: Text('UZS')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
              ],
              onChanged: (v) {
                if (v != null) bloc.add(CreateProductCurrencyChanged(v));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [50, 100, 200, 500].map((p) {
            return ChoiceChip(
              label: Text('$p'),
              selected: state.draft.price == p,
              onSelected: (_) {
                _price.text = '$p';
                bloc.add(CreateProductPriceChanged(p));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s.createProductNegotiableTitle),
          subtitle: Text(s.createProductNegotiableSubtitle,
              style: TextStyle(color: colors.textMuted, fontSize: 12)),
          value: state.draft.negotiable,
          onChanged: (v) => bloc.add(CreateProductNegotiableChanged(v)),
        ),
        const SizedBox(height: 20),
        DeliveryOptionSelector(
          value: state.draft.delivery,
          onChanged: (d) => bloc.add(CreateProductDeliveryChanged(d)),
        ),
      ],
    );
  }
}
