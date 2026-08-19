import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';

WorkshopDaySchedule? _scheduleForDay(List<WorkshopDaySchedule> list, int day) {
  for (final e in list) {
    if (e.day == day) return e;
  }
  return null;
}

/// User-facing open / hours line for workshop cards on the map.
String workshopOpenStatusLine(WorkshopProfile w) {
  if (w.open24Hours ||
      WorkshopProfile.scheduleLooks24x7(w.weeklySchedule)) {
    return 'Open 24/7';
  }
  if (w.isOpenNow) {
    final until = w.openUntil;
    if (until != null) {
      final mins = until.difference(DateTime.now()).inMinutes;
      if (mins > 0 && mins <= 60) {
        return 'Closing soon · ${mins}m left';
      }
    }
    return 'Open now';
  }

  final today = DateTime.now().weekday;
  final entry = _scheduleForDay(w.weeklySchedule, today);
  if (entry != null && !entry.closed && entry.openTime != null) {
    return 'Opens today at ${entry.openTime}';
  }

  for (var add = 1; add <= 7; add++) {
    final d = ((today + add - 1) % 7) + 1;
    final e = _scheduleForDay(w.weeklySchedule, d);
    if (e != null && !e.closed && e.openTime != null) {
      return 'Opens ${_weekdayShort(d)} ${e.openTime}';
    }
  }

  return 'Closed';
}

String _weekdayShort(int dartWeekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[(dartWeekday - 1).clamp(0, 6)];
}
