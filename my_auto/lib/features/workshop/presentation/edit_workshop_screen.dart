import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/features/workshop/domain/create_workshop_draft.dart';
import 'package:my_auto/features/workshop/domain/workshop_weekly_schedule.dart';
import 'package:my_auto/features/workshop/presentation/widgets/workshop_hours_editor.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/form/app_form_field.dart';
import 'package:my_auto/widgets/form/field_label.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:my_auto/widgets/toaster/index.dart';

/// Edit workshop profile: basic info, working hours, and gallery.
class EditWorkshopScreen extends StatefulWidget {
  const EditWorkshopScreen({super.key, required this.workshopId});

  final String workshopId;

  @override
  State<EditWorkshopScreen> createState() => _EditWorkshopScreenState();
}

class _EditWorkshopScreenState extends State<EditWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _telegramCtrl = TextEditingController();

  WorkshopProfile? _workshop;
  List<Map<String, dynamic>> _weeklySchedule =
      WorkshopWeeklySchedule.defaultSchedule();
  bool _open24Hours = false;
  List<String> _galleryUrls = [];
  final List<File> _newGalleryFiles = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final w = await workshopsRepository.details(widget.workshopId);
      if (!mounted) return;
      if (w == null) {
        setState(() => _loading = false);
        return;
      }
      _workshop = w;
      _nameCtrl.text = w.name;
      _descCtrl.text = w.description;
      _phoneCtrl.text = w.phone;
      _telegramCtrl.text = w.telegram;
      _weeklySchedule = WorkshopWeeklySchedule.fromProfile(
        weeklySchedule: w.weeklySchedule,
        openFrom: w.openFrom,
        openUntil: w.openUntil,
        open24Hours: w.open24Hours,
      );
      _open24Hours = w.open24Hours ||
          WorkshopWeeklySchedule.is24x7Schedule(_weeklySchedule);
      _galleryUrls = List<String>.from(w.allImages);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Toaster.error(GraphqlErrorUi.localizeRaw(context, e.toString()));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _telegramCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_open24Hours && !WorkshopWeeklySchedule.hasOpenDay(_weeklySchedule)) {
      Toaster.error('Mark at least one day as open');
      return;
    }

    setState(() => _saving = true);
    try {
      final schedule = _open24Hours
          ? WorkshopWeeklySchedule.schedule24x7()
          : _weeklySchedule;
      final hours = _open24Hours
          ? (
              openFrom: DateTime(2000, 1, 1, 0, 0),
              openUntil: DateTime(2000, 1, 1, 23, 59),
            )
          : CreateWorkshopDraft.legacyHoursFromSchedule(schedule);
      await workshopsRepository.updateWorkshopProfile(
        workshopId: widget.workshopId,
        data: {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'telegram': _telegramCtrl.text.trim(),
          'weeklySchedule': schedule,
          'openFrom': hours.openFrom.toUtc().toIso8601String(),
          'openUntil': hours.openUntil.toUtc().toIso8601String(),
        },
        retainedGalleryUrls: _galleryUrls,
        newGalleryFiles: _newGalleryFiles,
      );
      if (!mounted) return;
      Toaster.success(S.of(context).success);
      context.pop(true);
    } catch (e) {
      if (mounted) Toaster.error(S.of(context).errorOccurred);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickPhotos() async {
    final total = _galleryUrls.length + _newGalleryFiles.length;
    if (total >= 10) {
      Toaster.error(S.of(context).youCanUploadUpTo5Photos);
      return;
    }
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty || !mounted) return;
    setState(() {
      _newGalleryFiles.addAll(files.map((x) => File(x.path)));
    });
  }

  void _removeGalleryUrl(int index) {
    setState(() => _galleryUrls.removeAt(index));
  }

  void _removeNewFile(int index) {
    setState(() => _newGalleryFiles.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppTopBar(title: s.edit),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_workshop == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppTopBar(title: s.edit),
        body: Center(child: Text(s.noServices)),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.edit),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle(s.photos, colors),
            const SizedBox(height: 12),
            _gallerySection(colors, s),
            const SizedBox(height: 24),
            _sectionTitle('Workshop name', colors),
            const SizedBox(height: 12),
            AppFormField(
              controller: _nameCtrl,
              label: 'Workshop name',
              required: true,
              validator: (v) => FormValidators.title(context, v),
            ),
            const SizedBox(height: 16),
            AppFormField(
              controller: _descCtrl,
              label: s.description,
              required: false,
              maxLines: 4,
              minLength: 0,
            ),
            const SizedBox(height: 16),
            FieldLabel(text: s.phoneNumber, required: true),
            const SizedBox(height: 8),
            CustomInput(
              controller: _phoneCtrl,
              type: TextInputType.phone,
              required: true,
              hintText: s.phone,
              icon: Icon(LucideIcons.phone, color: colors.primary),
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: _telegramCtrl,
              label: 'Telegram',
              required: false,
              minLength: 0,
            ),
            const SizedBox(height: 24),
            _sectionTitle(s.workingTime, colors),
            const SizedBox(height: 12),
            WorkshopHoursEditor(
              schedule: _weeklySchedule,
              open24Hours: _open24Hours,
              onScheduleChanged: (next) =>
                  setState(() => _weeklySchedule = next),
              onOpen24HoursChanged: (value) =>
                  setState(() => _open24Hours = value),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
    );
  }

  Widget _gallerySection(AppColors colors, S s) {
    final hasImages = _galleryUrls.isNotEmpty || _newGalleryFiles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickPhotos,
          icon: const Icon(LucideIcons.imagePlus),
          label: Text(s.addPhoto),
        ),
        if (hasImages) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._galleryUrls.asMap().entries.map((entry) {
                return _galleryTile(
                  child: ImageCacheNetwork(
                    url: entry.value,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                  onRemove: () => _removeGalleryUrl(entry.key),
                );
              }),
              ..._newGalleryFiles.asMap().entries.map((entry) {
                return _galleryTile(
                  child: Image.file(
                    entry.value,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                  onRemove: () => _removeNewFile(entry.key),
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  Widget _galleryTile({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.rM,
          child: child,
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

}
