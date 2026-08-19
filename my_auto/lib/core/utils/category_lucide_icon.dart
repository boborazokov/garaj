import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Maps backend [Category.icon] (Lucide camelCase) to [IconData].
IconData? categoryLucideIcon(String? iconId) {
  if (iconId == null || iconId.trim().isEmpty) return null;
  return _lucideByName[iconId.trim()];
}

const Map<String, IconData> _lucideByName = {
  'activity': LucideIcons.activity,
  'airVent': LucideIcons.airVent,
  'armchair': LucideIcons.armchair,
  'arrowUpDown': LucideIcons.arrowUpDown,
  'batteryCharging': LucideIcons.batteryCharging,
  'batteryFull': LucideIcons.batteryFull,
  'boxes': LucideIcons.boxes,
  'car': LucideIcons.car,
  'circuitBoard': LucideIcons.circuitBoard,
  'cog': LucideIcons.cog,
  'crosshair': LucideIcons.crosshair,
  'disc2': LucideIcons.disc2,
  'disc3': LucideIcons.disc3,
  'droplet': LucideIcons.droplet,
  'droplets': LucideIcons.droplets,
  'fan': LucideIcons.fan,
  'filter': LucideIcons.filter,
  'flame': LucideIcons.flame,
  'flashlight': LucideIcons.flashlight,
  'fuel': LucideIcons.fuel,
  'gem': LucideIcons.gem,
  'gitBranch': LucideIcons.gitBranch,
  'glasses': LucideIcons.glasses,
  'hammer': LucideIcons.hammer,
  'layers': LucideIcons.layers,
  'lifeBuoy': LucideIcons.lifeBuoy,
  'navigation': LucideIcons.navigation,
  'navigation2': LucideIcons.navigation2,
  'nut': LucideIcons.nut,
  'package': LucideIcons.package,
  'paintbrush': LucideIcons.paintbrush,
  'plugZap': LucideIcons.plugZap,
  'radar': LucideIcons.radar,
  'refreshCw': LucideIcons.refreshCw,
  'settings2': LucideIcons.settings2,
  'shieldCheck': LucideIcons.shieldCheck,
  'snowflake': LucideIcons.snowflake,
  'sparkles': LucideIcons.sparkles,
  'speaker': LucideIcons.speaker,
  'sunDim': LucideIcons.sunDim,
  'thermometerSnowflake': LucideIcons.thermometerSnowflake,
  'thermometerSun': LucideIcons.thermometerSun,
  'truck': LucideIcons.truck,
  'wind': LucideIcons.wind,
  'wrench': LucideIcons.wrench,
  'zap': LucideIcons.zap,
};
