String formatCompactCount(int value) {
  if (value < 1000) return value.toString();
  if (value < 1000000) {
    final k = value / 1000;
    return k >= 10 ? '${k.round()}K' : '${k.toStringAsFixed(1)}K';
  }
  final m = value / 1000000;
  return m >= 10 ? '${m.round()}M' : '${m.toStringAsFixed(1)}M';
}
