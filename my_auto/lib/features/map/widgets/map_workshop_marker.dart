import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';

enum _WorkshopMapCategoryVisual {
  workshop,
  tire,
  diagnostics,
  tuning,
  battery,
  towTruck,
  carWash,
  partsStore,
}

_WorkshopMapCategoryVisual _categoryVisual(String? slug, MapPinKind kind) {
  if (kind != MapPinKind.workshop) return _WorkshopMapCategoryVisual.workshop;
  final s = (slug ?? '').toLowerCase();
  if (s.contains('tire') || s.contains('tyre') || s.contains('шин')) {
    return _WorkshopMapCategoryVisual.tire;
  }
  if (s.contains('diagnostic')) return _WorkshopMapCategoryVisual.diagnostics;
  if (s.contains('tuning')) return _WorkshopMapCategoryVisual.tuning;
  if (s.contains('battery') || s.contains('akum')) {
    return _WorkshopMapCategoryVisual.battery;
  }
  if (s.contains('tow') || s.contains('evac')) {
    return _WorkshopMapCategoryVisual.towTruck;
  }
  if (s.contains('wash')) return _WorkshopMapCategoryVisual.carWash;
  if (s.contains('part')) return _WorkshopMapCategoryVisual.partsStore;
  return _WorkshopMapCategoryVisual.workshop;
}

(_WorkshopMapCategoryVisual vis, IconData icon, Color base) _pinKindStyle(
  MapPin pin,
  AppColors colors,
) {
  switch (pin.kind) {
    case MapPinKind.workshop:
      final v = _categoryVisual(pin.primaryCategorySlug, pin.kind);
      final base = switch (v) {
        _WorkshopMapCategoryVisual.workshop =>
          const Color(0xFF7C3AED),
        _WorkshopMapCategoryVisual.tire =>
          const Color(0xFFEA580C),
        _WorkshopMapCategoryVisual.diagnostics =>
          const Color(0xFF0EA5E9),
        _WorkshopMapCategoryVisual.tuning =>
          const Color(0xFFDB2777),
        _WorkshopMapCategoryVisual.battery =>
          const Color(0xFF059669),
        _WorkshopMapCategoryVisual.towTruck =>
          const Color(0xFF64748B),
        _WorkshopMapCategoryVisual.carWash =>
          const Color(0xFF2563EB),
        _WorkshopMapCategoryVisual.partsStore =>
          colors.success,
      };
      final icon = switch (v) {
        _WorkshopMapCategoryVisual.workshop => LucideIcons.building2,
        _WorkshopMapCategoryVisual.tire => LucideIcons.circleDot,
        _WorkshopMapCategoryVisual.diagnostics => LucideIcons.activity,
        _WorkshopMapCategoryVisual.tuning => LucideIcons.flame,
        _WorkshopMapCategoryVisual.battery => LucideIcons.batteryMedium,
        _WorkshopMapCategoryVisual.towTruck => LucideIcons.truck,
        _WorkshopMapCategoryVisual.carWash => LucideIcons.droplets,
        _WorkshopMapCategoryVisual.partsStore => LucideIcons.package,
      };
      return (v, icon, base);
    case MapPinKind.service:
      return (_WorkshopMapCategoryVisual.workshop, LucideIcons.wrench,
          colors.primary);
    case MapPinKind.emergency:
      return (_WorkshopMapCategoryVisual.towTruck, LucideIcons.siren,
          colors.danger);
    case MapPinKind.product:
      return (_WorkshopMapCategoryVisual.partsStore, LucideIcons.package,
          colors.success);
    case MapPinKind.order:
      return (_WorkshopMapCategoryVisual.workshop, LucideIcons.clipboardList,
          colors.warning);
  }
}

/// Category-aware marker with status tinting (open / verified / premium / closed).
class MapWorkshopMarker extends StatelessWidget {
  const MapWorkshopMarker({
    super.key,
    required this.pin,
    required this.selected,
    required this.colors,
    this.previewLabel,
  });

  final MapPin pin;
  final bool selected;
  final AppColors colors;
  final String? previewLabel;

  @override
  Widget build(BuildContext context) {
    final (_, icon, accent) = _pinKindStyle(pin, colors);

    final hasHours = pin.kind == MapPinKind.workshop;
    final closed = hasHours &&
        !(pin.isOpenNow || pin.open24Hours || pin.kind == MapPinKind.order);

    final gold = pin.premium ? const Color(0xFFD4AF37) : null;
    final verifiedRing = pin.verified ? const Color(0xFF2F80ED) : null;

    Color fill = accent;
    if (closed) {
      fill = Color.lerp(accent, const Color(0xFF94A3B8), 0.55)!;
    } else if (pin.isOpenNow || pin.open24Hours) {
      fill = Color.lerp(accent, const Color(0xFF22C55E), 0.35)!;
    }

    final scale = selected ? 1.18 : 1.0;
    final label = previewLabel ?? pin.pricePreview;

    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null && label.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border.withValues(alpha: 0.4)),
                boxShadow: AppShadows.floating(context),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (gold != null)
                Container(
                  width: selected ? 52 : 48,
                  height: selected ? 52 : 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              AnimatedContainer(
                duration: AppMotion.fast,
                width: selected ? 46 : 42,
                height: selected ? 46 : 42,
                decoration: BoxDecoration(
                  gradient: verifiedRing != null && gold != null
                      ? LinearGradient(
                          colors: [verifiedRing, gold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : verifiedRing != null && gold == null
                          ? RadialGradient(
                              colors: [verifiedRing, fill],
                              center: Alignment.topLeft,
                              radius: 1.4,
                            )
                          : LinearGradient(colors: [fill, Color.lerp(fill, Colors.black, 0.12)!]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: selected ? 3 : 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fill.withValues(alpha: 0.45),
                      blurRadius: selected ? 14 : 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: selected ? 22 : 19),
              ),
            ],
          ),
          CustomPaint(
            size: const Size(14, 8),
            painter: _PinTailPainter(color: fill),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  _PinTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter old) => old.color != color;
}
