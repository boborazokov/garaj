import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

typedef MapChipHandler = void Function(String key);

/// Quick filters for workshop map discovery (wired to backend WorkshopFiltersInput).
class MapFilterChips extends StatelessWidget {
  const MapFilterChips({
    super.key,
    required this.colors,
    required this.activeKeys,
    required this.onChipToggle,
  });

  final AppColors colors;
  final LinkedHashSet<String> activeKeys;
  final MapChipHandler onChipToggle;

  static final List<({String key, String label, IconData icon})> chips = [
    (key: 'open_now', label: 'Open Now', icon: LucideIcons.clock),
    (key: 'nearby', label: 'Nearby', icon: LucideIcons.crosshair),
    (key: 'verified', label: 'Verified', icon: LucideIcons.shieldCheck),
    (key: 'top_rated', label: 'Top Rated', icon: LucideIcons.star),
    (key: 'premium', label: 'Premium', icon: LucideIcons.sparkles),
    (key: 'svc_tires', label: 'Tires', icon: LucideIcons.circleDot),
    (key: 'svc_engine', label: 'Engine', icon: LucideIcons.cog),
    (key: 'svc_diagnostics', label: 'Diag', icon: LucideIcons.activity),
    (key: 'emergency_only', label: 'Emergency', icon: LucideIcons.siren),
    (key: 'brand_bmw', label: 'BMW', icon: LucideIcons.car),
    (key: 'brand_toyota', label: 'Toyota', icon: LucideIcons.car),
    (key: 'brand_mercedes', label: 'Merc', icon: LucideIcons.car),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        itemBuilder: (_, i) {
          final c = chips[i];
          final on = activeKeys.contains(c.key);
          final accent = c.key.contains('emergency')
              ? colors.danger
              : c.key.contains('premium')
                  ? const Color(0xFFD4AF37)
                  : colors.primary;
          return Padding(
            padding: EdgeInsets.only(right: i == chips.length - 1 ? 0 : 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChipToggle(c.key);
                },
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: on
                        ? accent.withValues(alpha: 0.18)
                        : colors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: on
                          ? accent.withValues(alpha: 0.55)
                          : colors.border.withValues(alpha: 0.35),
                    ),
                    boxShadow: on
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c.icon,
                        size: 15,
                        color: on ? accent : colors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: on ? colors.textPrimary : colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
