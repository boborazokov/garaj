import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/widgets/toaster/index.dart';

class BookWorkshopSheet extends StatefulWidget {
  const BookWorkshopSheet({super.key, required this.workshop});

  final WorkshopProfile workshop;

  static Future<void> show(BuildContext context, WorkshopProfile workshop) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookWorkshopSheet(workshop: workshop),
    );
  }

  @override
  State<BookWorkshopSheet> createState() => _BookWorkshopSheetState();
}

class _BookWorkshopSheetState extends State<BookWorkshopSheet> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _notes = TextEditingController();
  final _service = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final scheduled = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
      await workshopsRepository.bookWorkshop(
        workshopId: widget.workshop.id,
        scheduledAt: scheduled,
        notes: _notes.text,
        serviceLabel: _service.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      Toaster.success('Booking request sent');
    } catch (e) {
      Toaster.error('Could not book: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        stickyBottomPadding(context, homeExtra: 20),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Book ${widget.workshop.name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(
              '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Time'),
            subtitle: Text(_time.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (picked != null) setState(() => _time = picked);
            },
          ),
          TextField(
            controller: _service,
            decoration: const InputDecoration(
              labelText: 'Service (optional)',
              hintText: 'Oil change, diagnostics…',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Request booking'),
          ),
        ],
      ),
    );
  }
}
