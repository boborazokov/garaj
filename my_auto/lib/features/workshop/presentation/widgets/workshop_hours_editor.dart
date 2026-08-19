import 'dart:io';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/workshop/domain/workshop_weekly_schedule.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';

class WorkshopHoursEditor extends StatelessWidget {
  const WorkshopHoursEditor({
    super.key,
    required this.schedule,
    required this.open24Hours,
    required this.onScheduleChanged,
    required this.onOpen24HoursChanged,
  });

  final List<Map<String, dynamic>> schedule;
  final bool open24Hours;
  final ValueChanged<List<Map<String, dynamic>>> onScheduleChanged;
  final ValueChanged<bool> onOpen24HoursChanged;

  Future<void> _pickTime(
    BuildContext context,
    int uiIndex, {
    required bool isOpenTime,
  }) async {
    final day = Map<String, dynamic>.from(schedule[uiIndex]);
    final key = isOpenTime ? 'openTime' : 'closeTime';
    final fallback = isOpenTime
        ? const TimeOfDay(hour: 9, minute: 0)
        : const TimeOfDay(hour: 18, minute: 0);
    final initial = _timeFromHm(day[key]?.toString(), fallback: fallback);

    TimeOfDay? picked;
    if (Platform.isIOS) {
      picked = await _pickTimeCupertino(context, initial);
    } else {
      picked = await showTimePicker(
        context: context,
        initialTime: initial,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    }

    if (picked == null || !context.mounted) return;
    final next = List<Map<String, dynamic>>.from(schedule);
    next[uiIndex] = WorkshopWeeklySchedule.updateUiIndex(
      next,
      uiIndex,
      {key: _hmFromTime(picked)},
    );
    onScheduleChanged(next);
  }

  Future<TimeOfDay?> _pickTimeCupertino(
    BuildContext context,
    TimeOfDay initial,
  ) async {
    var selected = initial;
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(
                  2020,
                  1,
                  1,
                  initial.hour,
                  initial.minute,
                ),
                onDateTimeChanged: (dt) {
                  selected = TimeOfDay(hour: dt.hour, minute: dt.minute);
                },
              ),
            ),
            CupertinoButton(
              child: Text(S.of(context).select),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    );
    return result == true ? selected : null;
  }

  Future<void> _pickDayRange(BuildContext context, int uiIndex) async {
    if (!Platform.isAndroid) {
      await _pickTime(context, uiIndex, isOpenTime: true);
      if (!context.mounted) return;
      await _pickTime(context, uiIndex, isOpenTime: false);
      return;
    }

    BottomPicker.rangeTime(
      height: MediaQuery.of(context).size.height * 0.42,
      displayCloseIcon: false,
      pickerTitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          WorkshopWeeklySchedule.uiDayNames[uiIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      showTimeSeparator: true,
      use24hFormat: true,
      dismissable: true,
      buttonWidth: MediaQuery.of(context).size.width - 32,
      buttonPadding: 14,
      buttonStyle: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      buttonContent: Text(
        S.of(context).select,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onRangeTimeSubmitPressed: (startTime, endTime) {
        final next = List<Map<String, dynamic>>.from(schedule);
        next[uiIndex] = WorkshopWeeklySchedule.updateUiIndex(
          next,
          uiIndex,
          {
            'openTime': _hmFromDateTime(startTime),
            'closeTime': _hmFromDateTime(endTime),
          },
        );
        onScheduleChanged(next);
      },
    ).show(context);
  }

  void _applyHoursToAllOpenDays(BuildContext context, int sourceIndex) {
    final src = schedule[sourceIndex];
    if (src['closed'] == true) return;
    final next = List<Map<String, dynamic>>.from(schedule);
    for (var i = 0; i < next.length; i++) {
      final day = Map<String, dynamic>.from(next[i]);
      if (day['closed'] == true) continue;
      next[i] = WorkshopWeeklySchedule.updateUiIndex(
        next,
        i,
        {
          'openTime': src['openTime'],
          'closeTime': src['closeTime'],
        },
      );
    }
    onScheduleChanged(next);
    Toaster.success('Hours applied to all open days');
  }

  void _toggleOpen24Hours(bool value) {
    onOpen24HoursChanged(value);
    if (value) {
      onScheduleChanged(WorkshopWeeklySchedule.schedule24x7());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Open 24/7',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Workshop is always open',
            style: TextStyle(color: colors.textMuted),
          ),
          value: open24Hours,
          onChanged: _toggleOpen24Hours,
        ),
        if (!open24Hours) ...[
          const SizedBox(height: 8),
          Text(
            'Set when your workshop is open.',
            style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 12),
          ...List.generate(7, (i) => _dayCard(context, colors, i)),
        ],
      ],
    );
  }

  Widget _dayCard(BuildContext context, AppColors colors, int uiIndex) {
    final day = Map<String, dynamic>.from(schedule[uiIndex]);
    final closed = day['closed'] == true;
    final openHm = day['openTime']?.toString() ?? '09:00';
    final closeHm = day['closeTime']?.toString() ?? '18:00';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                WorkshopWeeklySchedule.uiDayNames[uiIndex],
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                closed ? 'Closed' : '$openHm – $closeHm',
                style: TextStyle(color: colors.textMuted),
              ),
              value: !closed,
              onChanged: (open) {
                final next = List<Map<String, dynamic>>.from(schedule);
                next[uiIndex] = WorkshopWeeklySchedule.updateUiIndex(
                  next,
                  uiIndex,
                  {
                    'closed': !open,
                    if (open && day['openTime'] == null) 'openTime': '09:00',
                    if (open && day['closeTime'] == null) 'closeTime': '18:00',
                  },
                );
                onScheduleChanged(next);
              },
            ),
            if (!closed) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: OutlinedButton(
                  onPressed: () => _pickDayRange(context, uiIndex),
                  child: Text(
                    '$openHm – $closeHm\nTap to change',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _applyHoursToAllOpenDays(context, uiIndex),
                  child: const Text('Apply to all open days'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static TimeOfDay _timeFromHm(
    String? hm, {
    TimeOfDay fallback = const TimeOfDay(hour: 9, minute: 0),
  }) {
    if (hm == null || hm.isEmpty) return fallback;
    final parts = hm.split(':');
    if (parts.length < 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return fallback;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  static String _hmFromTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _hmFromDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
