import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';

typedef RadiusPick = void Function(double km);

class MapRadiusSelector extends StatelessWidget {
  const MapRadiusSelector({
    super.key,
    required this.colors,
    required this.valueKm,
    required this.onPick,
    this.values = const [5, 10, 25, 50],
  });

  final AppColors colors;
  final double valueKm;
  final RadiusPick onPick;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Search radius',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final v in values)
                ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    child: Text(
                      '$v km',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  selectedColor: colors.primary.withValues(alpha: 0.16),
                  checkmarkColor: colors.primary,
                  selected: valueKm == v.toDouble(),
                  onSelected: (_) => onPick(v.toDouble()),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
