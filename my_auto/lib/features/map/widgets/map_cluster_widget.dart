import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';

/// Cluster orb for aggregated markers.
class MapClusterWidget extends StatelessWidget {
  const MapClusterWidget({super.key, required this.count, required this.colors});
  final int count;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 180),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.primaryHover],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: AppShadows.glow(colors.primary),
        ),
        child: Center(
          child: Text(
            '$count',
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
