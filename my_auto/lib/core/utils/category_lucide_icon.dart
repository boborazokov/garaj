import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';

/// Resolves a thematic Lucide icon for a marketplace category.
/// Prefers backend [CategoryCar.icon], then [CategoryCar.key], then name keywords.
IconData resolveCategoryIcon(CategoryCar category) {
  return categoryLucideIcon(category.icon) ??
      categoryIconByKey(category.key) ??
      categoryIconByName(category.name) ??
      categoryIconByName(category.names.en) ??
      categoryIconByName(category.names.ru) ??
      categoryIconByName(category.names.uz) ??
      LucideIcons.package;
}

/// Maps backend [Category.icon] (Lucide camelCase) to [IconData].
IconData? categoryLucideIcon(String? iconId) {
  if (iconId == null || iconId.trim().isEmpty) return null;
  return _lucideByName[iconId.trim()];
}

IconData? categoryIconByKey(String? key) {
  if (key == null || key.trim().isEmpty) return null;
  return _iconByKey[key.trim().toLowerCase()];
}

IconData? categoryIconByName(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final n = raw.toLowerCase();

  bool has(String a) => n.contains(a);

  if (has('двигател') || has('engine') || has('dvigatel')) {
    return LucideIcons.cog;
  }
  if (has('трансмисс') || has('transmission') || has('коробк') || has('akpp') || has('акпп')) {
    return LucideIcons.settings2;
  }
  if (has('подвеск') || has('suspension') || has('osma') || has('амортиз')) {
    return LucideIcons.arrowUpDown;
  }
  if (has('тормоз') || has('brake') || has('tormoz')) {
    return LucideIcons.circleDot;
  }
  if (has('рулев') || has('steering') || has('rul ')) {
    return LucideIcons.circleGauge;
  }
  if (has('электрообор') || has('electrical') || has('elektr jihoz')) {
    return LucideIcons.zap;
  }
  if (has('охлажд') || has('cooling') || has('sovutish') || has('радиатор') || has('radiator')) {
    return LucideIcons.fan;
  }
  if (has('топлив') || has('fuel') || has('yoqilg') || has('бензин') || has('дизел')) {
    return LucideIcons.fuel;
  }
  if (has('впуск') || has('intake') || has('havo qabul')) {
    return LucideIcons.wind;
  }
  if (has('выпуск') || has('exhaust') || has('chiqindi') || has('глушител') || has('выхлоп')) {
    return LucideIcons.cloudFog;
  }
  if (has('кондиц') || has('отоплени') || has('air condition') || has('heating') || has('isitish')) {
    return LucideIcons.snowflake;
  }
  if (has('кузов') || has('body') || has('kuzov') || has('бампер') || has('крыло') || has('капот')) {
    return LucideIcons.car;
  }
  if (has('освещ') ||
      has('light') ||
      has('yorit') ||
      has('фар') ||
      has('фара') ||
      has('fara') ||
      has('фонар') ||
      has('fonar')) {
    return LucideIcons.lightbulb;
  }
  if (has('стекл') || has('зеркал') || has('glass') || has('mirror') || has('oyna') || has('ko‘zgu') || has('kozgu')) {
    return LucideIcons.scan;
  }
  if (has('салон') || has('interior') || has('сидень') || has('obivka')) {
    return LucideIcons.armchair;
  }
  if (has('шин') || has('tire') || has('tyre') || has('колёс') || has('колес') || has('g‘ildirak') || has('gildirak') || has('wheel')) {
    return LucideIcons.circleDashed;
  }
  if (has('диск') || has('rim') || has('disklar') || has('литой')) {
    return LucideIcons.circle;
  }
  if (has('аккумул') || has('batter') || has('akkum')) {
    return LucideIcons.batteryCharging;
  }
  if (has('фильтр') || has('filter') || has('filtr')) {
    return LucideIcons.filter;
  }
  if (has('масл') || has('жидкост') || has('oil') || has('fluid') || has('moy') || has('антифриз') || has('antifreeze')) {
    return LucideIcons.droplets;
  }
  if (has('ремен') || has('ролик') || has('belt') || has('roller') || has('kamar')) {
    return LucideIcons.refreshCw;
  }
  if (has('свеч') || has('spark') || has('sham')) {
    return LucideIcons.zap;
  }
  if (has('подшипник') || has('bearing') || has('podship')) {
    return LucideIcons.circleDot;
  }
  if (has('датчик') || has('sensor') || has('datchik')) {
    return LucideIcons.radar;
  }
  if (has('электрон') || has('electronics') || has('avtoelektron')) {
    return LucideIcons.cpu;
  }
  if (has('звук') ||
      has('audio') ||
      has('avtoaudio') ||
      has('магнитол') ||
      has('динамик')) {
    return LucideIcons.speaker;
  }
  if (has('сигнализ') || has('безопасност') || has('security') || has('signaliz')) {
    return LucideIcons.shieldCheck;
  }
  if (has('инструмент') || has('tool') || has('asbob') || has('ключ')) {
    return LucideIcons.wrench;
  }
  if (has('аксессуар') || has('accessor') || has('aksessuar')) {
    return LucideIcons.gift;
  }
  if (has('расходн') || has('consumable') || has('sarf')) {
    return LucideIcons.boxes;
  }
  if (has('диагност') || has('diagnost')) {
    return LucideIcons.stethoscope;
  }
  if (has('мойк') || has('detail') || has('химчист') || has('washing')) {
    return LucideIcons.sparkles;
  }
  if (has('эвакуатор') || has('tow') || has('evacuat')) {
    return LucideIcons.truck;
  }
  if (has('шиномонтаж') || has('tyre service') || has('tire service')) {
    return LucideIcons.circleDashed;
  }
  if (has('автозвук') || has('car audio')) {
    return LucideIcons.speaker;
  }

  return null;
}

/// Stable Lucide map by category seed `key`.
const Map<String, IconData> _iconByKey = {
  'engine': LucideIcons.cog,
  'transmission': LucideIcons.settings2,
  'suspension': LucideIcons.arrowUpDown,
  'brakes': LucideIcons.circleDot,
  'steering': LucideIcons.circleGauge,
  'electrical': LucideIcons.zap,
  'cooling': LucideIcons.fan,
  'fuel': LucideIcons.fuel,
  'intake': LucideIcons.wind,
  'exhaust': LucideIcons.cloudFog,
  'air_conditioning': LucideIcons.snowflake,
  'body': LucideIcons.car,
  'lighting': LucideIcons.lightbulb,
  'glass_mirrors': LucideIcons.scan,
  'interior': LucideIcons.armchair,
  'wheels_tires': LucideIcons.circleDashed,
  'rims': LucideIcons.circle,
  'batteries': LucideIcons.batteryCharging,
  'filters': LucideIcons.filter,
  'oils_fluids': LucideIcons.droplets,
  'belts_rollers': LucideIcons.refreshCw,
  'spark_plugs': LucideIcons.zap,
  'bearings': LucideIcons.circleDot,
  'sensors': LucideIcons.radar,
  'electronics': LucideIcons.cpu,
  'audio': LucideIcons.speaker,
  'security': LucideIcons.shieldCheck,
  'tools': LucideIcons.wrench,
  'accessories': LucideIcons.gift,
  'consumables': LucideIcons.boxes,
};

const Map<String, IconData> _lucideByName = {
  'activity': LucideIcons.activity,
  'airVent': LucideIcons.airVent,
  'armchair': LucideIcons.armchair,
  'arrowUpDown': LucideIcons.arrowUpDown,
  'batteryCharging': LucideIcons.batteryCharging,
  'batteryFull': LucideIcons.batteryFull,
  'boxes': LucideIcons.boxes,
  'car': LucideIcons.car,
  'circle': LucideIcons.circle,
  'circleDashed': LucideIcons.circleDashed,
  'circleDot': LucideIcons.circleDot,
  'circleGauge': LucideIcons.circleGauge,
  'circuitBoard': LucideIcons.circuitBoard,
  'cloudFog': LucideIcons.cloudFog,
  'cog': LucideIcons.cog,
  'cpu': LucideIcons.cpu,
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
  'gift': LucideIcons.gift,
  'gitBranch': LucideIcons.gitBranch,
  'glasses': LucideIcons.glasses,
  'hammer': LucideIcons.hammer,
  'layers': LucideIcons.layers,
  'lifeBuoy': LucideIcons.lifeBuoy,
  'lightbulb': LucideIcons.lightbulb,
  'navigation': LucideIcons.navigation,
  'navigation2': LucideIcons.navigation2,
  'nut': LucideIcons.nut,
  'package': LucideIcons.package,
  'paintbrush': LucideIcons.paintbrush,
  'plugZap': LucideIcons.plugZap,
  'radar': LucideIcons.radar,
  'refreshCw': LucideIcons.refreshCw,
  'scan': LucideIcons.scan,
  'settings2': LucideIcons.settings2,
  'shieldCheck': LucideIcons.shieldCheck,
  'snowflake': LucideIcons.snowflake,
  'sparkles': LucideIcons.sparkles,
  'speaker': LucideIcons.speaker,
  'stethoscope': LucideIcons.stethoscope,
  'sunDim': LucideIcons.sunDim,
  'thermometerSnowflake': LucideIcons.thermometerSnowflake,
  'thermometerSun': LucideIcons.thermometerSun,
  'truck': LucideIcons.truck,
  'wind': LucideIcons.wind,
  'wrench': LucideIcons.wrench,
  'zap': LucideIcons.zap,
};
