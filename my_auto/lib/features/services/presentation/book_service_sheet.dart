import 'package:flutter/material.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/services/data/services_repository.dart';
import 'package:my_auto/widgets/toaster/index.dart';

Future<bool?> showBookServiceSheet(
  BuildContext context, {
  required String serviceId,
  required String serviceTitle,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _BookServiceSheet(
      serviceId: serviceId,
      serviceTitle: serviceTitle,
    ),
  );
}

class _BookServiceSheet extends StatefulWidget {
  const _BookServiceSheet({
    required this.serviceId,
    required this.serviceTitle,
  });

  final String serviceId;
  final String serviceTitle;

  @override
  State<_BookServiceSheet> createState() => _BookServiceSheetState();
}

class _BookServiceSheetState extends State<_BookServiceSheet> {
  DateTime _when = DateTime.now().add(const Duration(hours: 2));
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (time == null || !mounted) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    final authed = await AuthGuard.requireAuth(
      context,
      message: 'Sign in to book this service',
    );
    if (!authed || !mounted) return;

    setState(() => _submitting = true);
    final ok = await servicesRepository.bookService(
      serviceId: widget.serviceId,
      scheduledAt: _when,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.pop(context, true);
      Toaster.success('Booking request sent');
    } else {
      Toaster.error('Could not book. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: stickyBottomPadding(context, keyboardExtra: 0, homeExtra: 0),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Book service',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              widget.serviceTitle,
              style: TextStyle(color: colors.textMuted),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date & time'),
              subtitle: Text(_when.toLocal().toString().substring(0, 16)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notes for the workshop (optional)',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Text('Confirm booking'),
            ),
          ],
        ),
      ),
    );
  }
}
