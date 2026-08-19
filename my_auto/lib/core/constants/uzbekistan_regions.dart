import 'package:my_auto/generated/l10n.dart';

/// Stable ids stored in profile `region` when possible; labels are localized.
enum UzbekistanRegion {
  andijan,
  bukhara,
  jizzakh,
  kashkadarya,
  navoi,
  namangan,
  samarkand,
  surkhandarya,
  syrdarya,
  tashkentRegion,
  fergana,
  khorezm,
  karakalpakstan,
  tashkentCity,
}

const List<UzbekistanRegion> uzbekistanRegions = UzbekistanRegion.values;

String uzbekistanRegionLabel(S s, UzbekistanRegion region) {
  switch (region) {
    case UzbekistanRegion.andijan:
      return s.regionAndijan;
    case UzbekistanRegion.bukhara:
      return s.regionBukhara;
    case UzbekistanRegion.jizzakh:
      return s.regionJizzakh;
    case UzbekistanRegion.kashkadarya:
      return s.regionKashkadarya;
    case UzbekistanRegion.navoi:
      return s.regionNavoi;
    case UzbekistanRegion.namangan:
      return s.regionNamangan;
    case UzbekistanRegion.samarkand:
      return s.regionSamarkand;
    case UzbekistanRegion.surkhandarya:
      return s.regionSurkhandarya;
    case UzbekistanRegion.syrdarya:
      return s.regionSyrdarya;
    case UzbekistanRegion.tashkentRegion:
      return s.regionTashkentRegion;
    case UzbekistanRegion.fergana:
      return s.regionFergana;
    case UzbekistanRegion.khorezm:
      return s.regionKhorezm;
    case UzbekistanRegion.karakalpakstan:
      return s.regionKarakalpakstan;
    case UzbekistanRegion.tashkentCity:
      return s.regionTashkentCity;
  }
}

const Map<UzbekistanRegion, String> _englishRegionLabels = {
  UzbekistanRegion.andijan: 'Andijan',
  UzbekistanRegion.bukhara: 'Bukhara',
  UzbekistanRegion.jizzakh: 'Jizzakh',
  UzbekistanRegion.kashkadarya: 'Kashkadarya',
  UzbekistanRegion.navoi: 'Navoi',
  UzbekistanRegion.namangan: 'Namangan',
  UzbekistanRegion.samarkand: 'Samarkand',
  UzbekistanRegion.surkhandarya: 'Surkhandarya',
  UzbekistanRegion.syrdarya: 'Syrdarya',
  UzbekistanRegion.tashkentRegion: 'Tashkent region',
  UzbekistanRegion.fergana: 'Fergana',
  UzbekistanRegion.khorezm: 'Khorezm',
  UzbekistanRegion.karakalpakstan: 'Republic of Karakalpakstan',
  UzbekistanRegion.tashkentCity: 'Tashkent city',
};

/// Resolves saved region text (any locale / legacy list) to enum.
UzbekistanRegion? uzbekistanRegionFromStored(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  for (final region in uzbekistanRegions) {
    if (value == region.name) return region;
    if (value == _englishRegionLabels[region]) return region;
  }

  const legacy = {
    'Toshkent': UzbekistanRegion.tashkentCity,
    'Samarqand': UzbekistanRegion.samarkand,
    'Buxoro': UzbekistanRegion.bukhara,
    'Andijon': UzbekistanRegion.andijan,
    "Farg'ona": UzbekistanRegion.fergana,
    'Namangan': UzbekistanRegion.namangan,
    'Qashqadaryo': UzbekistanRegion.kashkadarya,
    'Surxondaryo': UzbekistanRegion.surkhandarya,
    'Jizzax': UzbekistanRegion.jizzakh,
    'Sirdaryo': UzbekistanRegion.syrdarya,
    'Navoiy': UzbekistanRegion.navoi,
    'Xorazm': UzbekistanRegion.khorezm,
    "Qoraqalpog'iston Respublikasi": UzbekistanRegion.karakalpakstan,
  };
  return legacy[value];
}
