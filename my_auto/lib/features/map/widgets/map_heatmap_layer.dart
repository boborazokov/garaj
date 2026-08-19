import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Placeholder for future heatmap layer (no extra native SDK required).
/// When [enabled] is true, draws a soft density accent over workshop clusters.
class MapHeatmapLayer extends StatelessWidget {
  const MapHeatmapLayer({
    super.key,
    required this.enabled,
    required this.colors,
    required this.points,
  });

  final bool enabled;
  final AppColors colors;
  final List<LatLng> points;

  @override
  Widget build(BuildContext context) {
    if (!enabled || points.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _SoftHeatPainter(
          color: colors.primary.withValues(alpha: 0.08),
          count: points.length,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Very lightweight visual cue — replace with tessellated heat overlay later.
class _SoftHeatPainter extends CustomPainter {
  _SoftHeatPainter({required this.color, required this.count});
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final step = ((count / 120).clamp(0.08, 0.42)) * size.shortestSide;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.35), step, paint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.52), step * 0.85,
        paint);
  }

  @override
  bool shouldRepaint(covariant _SoftHeatPainter oldDelegate) =>
      oldDelegate.count != count || oldDelegate.color != color;
}
