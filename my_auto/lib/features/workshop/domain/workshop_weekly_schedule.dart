import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';

/// Weekly hours use Dart weekday in the `day` field: Mon=1 … Sun=7.
/// UI rows are ordered Sun … Sat (index 0 = Sunday).
class WorkshopWeeklySchedule {
  WorkshopWeeklySchedule._();

  static const uiDayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static int dartWeekdayForUiIndex(int uiIndex) =>
      uiIndex == 0 ? DateTime.sunday : uiIndex;

  static int uiIndexForDartWeekday(int dartWeekday) =>
      dartWeekday == DateTime.sunday ? 0 : dartWeekday;

  static int uiIndexForStoredDay(int storedDay) {
    if (storedDay >= 0 && storedDay <= 6) return storedDay;
    return uiIndexForDartWeekday(storedDay);
  }

  static String hmFromDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static Map<String, dynamic> entryForUiIndex(
    int uiIndex, {
    required bool closed,
    required String openTime,
    required String closeTime,
  }) {
    return {
      'day': dartWeekdayForUiIndex(uiIndex),
      'closed': closed,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  static List<Map<String, dynamic>> defaultSchedule() {
    return List.generate(
      7,
      (i) => entryForUiIndex(
        i,
        closed: i == 0,
        openTime: '09:00',
        closeTime: '18:00',
      ),
    );
  }

  static List<Map<String, dynamic>> schedule24x7() {
    return List.generate(
      7,
      (i) => entryForUiIndex(
        i,
        closed: false,
        openTime: '00:00',
        closeTime: '23:59',
      ),
    );
  }

  static List<Map<String, dynamic>> fromProfile({
    List<WorkshopDaySchedule> weeklySchedule = const [],
    DateTime? openFrom,
    DateTime? openUntil,
    bool open24Hours = false,
  }) {
    if (open24Hours) return schedule24x7();

    final byUiIndex = <int, Map<String, dynamic>>{};
    for (final d in weeklySchedule) {
      final uiIndex = uiIndexForStoredDay(d.day);
      byUiIndex[uiIndex] = entryForUiIndex(
        uiIndex,
        closed: d.closed,
        openTime: d.openTime ?? '09:00',
        closeTime: d.closeTime ?? '18:00',
      );
    }

    if (byUiIndex.isEmpty && openFrom != null && openUntil != null) {
      final openHm = hmFromDateTime(openFrom.toLocal());
      final closeHm = hmFromDateTime(openUntil.toLocal());
      return List.generate(
        7,
        (i) => entryForUiIndex(
          i,
          closed: false,
          openTime: openHm,
          closeTime: closeHm,
        ),
      );
    }

    return List.generate(
      7,
      (i) => byUiIndex[i] ?? defaultSchedule()[i],
    );
  }

  static Map<String, dynamic> updateUiIndex(
    List<Map<String, dynamic>> schedule,
    int uiIndex,
    Map<String, dynamic> patch,
  ) {
    final current = Map<String, dynamic>.from(schedule[uiIndex]);
    return {
      ...current,
      ...patch,
      'day': dartWeekdayForUiIndex(uiIndex),
    };
  }

  static bool hasOpenDay(List<Map<String, dynamic>> schedule) =>
      schedule.any((d) => d['closed'] != true);

  static bool is24x7Schedule(List<Map<String, dynamic>> schedule) {
    if (schedule.length < 7) return false;
    for (final d in schedule) {
      if (d['closed'] == true) return false;
      if (d['openTime']?.toString() != '00:00') return false;
      final close = d['closeTime']?.toString();
      if (close != '23:59' && close != '24:00') return false;
    }
    return true;
  }
}
