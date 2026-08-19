import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerPlaceholder(BuildContext context,
    {double? width, double? height}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Shimmer.fromColors(
    baseColor: colorScheme.surface.withOpacity(0.3),
    highlightColor: colorScheme.onSurface.withOpacity(0.1),
    child: Container(
      width: width ?? double.infinity,
      height: height ?? 200,
      color: colorScheme.surface.withOpacity(0.3),
    ),
  );
}
