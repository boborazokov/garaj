import 'dart:io';

import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/features/workshop/domain/workshop_weekly_schedule.dart';

enum CreateWorkshopStep {
  basicInfo,
  services,
  location,
  hours,
  gallery,
  preview,
}

class CreateWorkshopDraft {
  CreateWorkshopDraft({
    this.step = CreateWorkshopStep.basicInfo,
    this.name = '',
    this.description = '',
    this.phone = '',
    this.telegram = '',
    this.selectedCategoryIds = const [],
    this.geo,
    this.address = '',
    this.city = '',
    this.locationLabel = '',
    this.serviceRadiusKm = 15,
    this.servicePricing = const [],
    this.weeklySchedule = const [],
    this.galleryFiles = const [],
    this.fastResponse = false,
    this.open24Hours = false,
    this.responseTimeMinutes,
  });

  CreateWorkshopStep step;
  String name;
  String description;
  String phone;
  String telegram;
  List<String> selectedCategoryIds;
  GeoLocation? geo;
  String address;
  String city;
  String locationLabel;
  double serviceRadiusKm;
  List<Map<String, dynamic>> servicePricing;
  List<Map<String, dynamic>> weeklySchedule;
  List<File> galleryFiles;
  bool fastResponse;
  bool open24Hours;
  int? responseTimeMinutes;

  static List<Map<String, dynamic>> defaultWeeklySchedule() =>
      WorkshopWeeklySchedule.defaultSchedule();

  bool get canContinueBasic =>
      name.trim().length >= 2 && phone.replaceAll(RegExp(r'\D'), '').length >= 9;
  bool get canContinueServices => selectedCategoryIds.isNotEmpty;
  bool get canContinueLocation => geo != null;
  bool get canContinueHours =>
      open24Hours || WorkshopWeeklySchedule.hasOpenDay(weeklySchedule);
  bool get canContinueGallery => true;
  bool get canPublish =>
      canContinueBasic && canContinueServices && canContinueLocation;

  static DateTime _dateTimeFromHm(String hm) {
    final parts = hm.split(':');
    final h = int.tryParse(parts.first) ?? 9;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  /// Legacy openFrom/openUntil from the first open day in weekly schedule.
  static ({DateTime openFrom, DateTime openUntil}) legacyHoursFromSchedule(
    List<Map<String, dynamic>> schedule,
  ) {
    final resolved =
        schedule.isEmpty ? defaultWeeklySchedule() : schedule;
    final openDays =
        resolved.where((d) => d['closed'] != true).toList(growable: false);
    if (openDays.isEmpty) {
      final now = DateTime.now();
      return (
        openFrom: DateTime(now.year, now.month, now.day, 9, 0),
        openUntil: DateTime(now.year, now.month, now.day, 18, 0),
      );
    }
    final day = openDays.first;
    final openHm = day['openTime']?.toString() ?? '09:00';
    final closeHm = day['closeTime']?.toString() ?? '18:00';
    return (
      openFrom: _dateTimeFromHm(openHm),
      openUntil: _dateTimeFromHm(closeHm),
    );
  }

  (DateTime openFrom, DateTime openUntil) _legacyHoursFrom(
    List<Map<String, dynamic>> schedule,
  ) {
    final h = legacyHoursFromSchedule(schedule);
    return (h.openFrom, h.openUntil);
  }

  Map<String, dynamic> toGraphQLInput() {
    final schedule = open24Hours
        ? WorkshopWeeklySchedule.schedule24x7()
        : (weeklySchedule.isEmpty ? defaultWeeklySchedule() : weeklySchedule);
    final (openFrom, openUntil) = open24Hours
        ? (
            DateTime(2000, 1, 1, 0, 0),
            DateTime(2000, 1, 1, 23, 59),
          )
        : _legacyHoursFrom(schedule);

    return {
      'name': name.trim(),
      'description': description.trim(),
      'location': geo != null
          ? '${geo!.latitude.toStringAsFixed(5)}, ${geo!.longitude.toStringAsFixed(5)}'
          : locationLabel.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'geoLocation': {
        'latitude': geo!.latitude,
        'longitude': geo!.longitude,
      },
      'serviceRadiusKm': serviceRadiusKm,
      'categoryIds': selectedCategoryIds,
      'servicePricing': servicePricing,
      'weeklySchedule': schedule,
      'openFrom': openFrom.toUtc().toIso8601String(),
      'openUntil': openUntil.toUtc().toIso8601String(),
      'phone': phone.trim(),
      'telegram': telegram.trim(),
      'fastResponse': fastResponse,
      if (responseTimeMinutes != null)
        'responseTimeMinutes': responseTimeMinutes,
    };
  }
}
