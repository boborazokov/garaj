import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/utils/category_lucide_icon.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/widgets/sticky_continue_bar.dart';
import 'package:my_auto/features/workshop/data/models/workshop_category.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/features/workshop/domain/create_workshop_draft.dart';
import 'package:my_auto/features/workshop/presentation/widgets/workshop_hours_editor.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/form/field_label.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:my_auto/widgets/toaster/index.dart';

class CreateWorkshopFlowScreen extends StatefulWidget {
  const CreateWorkshopFlowScreen({super.key});

  @override
  State<CreateWorkshopFlowScreen> createState() =>
      _CreateWorkshopFlowScreenState();
}

class _CreateWorkshopFlowScreenState extends State<CreateWorkshopFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _draft = CreateWorkshopDraft(
    weeklySchedule: CreateWorkshopDraft.defaultWeeklySchedule(),
  );
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _telegramCtrl = TextEditingController();
  List<WorkshopCategory> _categories = [];
  bool _loadingCats = true;
  bool _publishing = false;

  static const _steps = CreateWorkshopStep.values;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await workshopsRepository.categories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _loadingCats = false;
      });
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

  bool _canContinue() {
    switch (_draft.step) {
      case CreateWorkshopStep.basicInfo:
        return _draft.canContinueBasic;
      case CreateWorkshopStep.services:
        return _draft.canContinueServices;
      case CreateWorkshopStep.location:
        return _draft.canContinueLocation;
      case CreateWorkshopStep.hours:
        return _draft.canContinueHours;
      case CreateWorkshopStep.gallery:
        return _draft.canContinueGallery;
      case CreateWorkshopStep.preview:
        return _draft.canPublish;
    }
  }

  void _syncBasicFields() {
    _draft.name = _nameCtrl.text;
    _draft.description = _descCtrl.text;
    _draft.phone = _phoneCtrl.text;
    _draft.telegram = _telegramCtrl.text;
  }

  void _syncLocationFields() {
    _draft.address = '';
    _draft.city = '';
    if (_draft.geo != null) {
      _draft.locationLabel =
          '${_draft.geo!.latitude.toStringAsFixed(5)}, ${_draft.geo!.longitude.toStringAsFixed(5)}';
    }
  }

  bool _validateCurrentStep() {
    final s = S.of(context);
    switch (_draft.step) {
      case CreateWorkshopStep.basicInfo:
        _syncBasicFields();
        return _formKey.currentState?.validate() ?? false;
      case CreateWorkshopStep.services:
        if (_draft.selectedCategoryIds.isEmpty) {
          Toaster.error(s.fieldRequired);
          return false;
        }
        return true;
      case CreateWorkshopStep.location:
        if (_draft.geo == null) {
          Toaster.error('Pick location on map *');
          return false;
        }
        return true;
      case CreateWorkshopStep.hours:
        if (!_draft.open24Hours && !_draft.canContinueHours) {
          Toaster.error('Mark at least one day as open');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _next() {
    if (_draft.step == CreateWorkshopStep.preview) {
      _publish();
      return;
    }
    if (!_validateCurrentStep()) return;
    final i = _steps.indexOf(_draft.step);
    if (i < _steps.length - 1) {
      setState(() => _draft.step = _steps[i + 1]);
    }
  }

  void _back() {
    final i = _steps.indexOf(_draft.step);
    if (i > 0) {
      setState(() => _draft.step = _steps[i - 1]);
    } else {
      context.pop();
    }
  }

  Future<void> _pickLocation() async {
    final result = await context.push<GeoLocation?>(RoutesName.map);
    if (result != null) {
      setState(() {
        _draft.geo = result;
        _draft.locationLabel =
            '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
      });
    }
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() {
      _draft.galleryFiles = [
        ..._draft.galleryFiles,
        ...files.map((x) => File(x.path)),
      ];
    });
  }

  Future<void> _publish() async {
    _syncBasicFields();
    _syncLocationFields();
    if (!(_formKey.currentState?.validate() ?? false) ||
        !_draft.canContinueServices ||
        _draft.geo == null) {
      Toaster.error(S.of(context).fieldRequired);
      return;
    }

    setState(() => _publishing = true);
    try {
      final id = await workshopsRepository.createWorkshop(_draft);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Toaster.success('Workshop published');
      context.go(RoutesName.buttonNavigationBar);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.push('${RoutesName.workshopDetailScreen}/$id');
      });
    } catch (e) {
      Toaster.error('Failed to publish workshop: $e');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  String _hoursPreviewSummary() {
    if (_draft.open24Hours) return 'Open 24/7';
    const short = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final open = <String>[];
    for (var i = 0; i < _draft.weeklySchedule.length && i < 7; i++) {
      final d = _draft.weeklySchedule[i];
      if (d['closed'] == true) continue;
      open.add(
        '${short[i]} ${d['openTime'] ?? '09:00'}–${d['closeTime'] ?? '18:00'}',
      );
    }
    if (open.isEmpty) return 'No open days set';
    if (open.length <= 2) return open.join(' · ');
    return '${open.length} open days configured';
  }

  String _stepTitle() {
    switch (_draft.step) {
      case CreateWorkshopStep.basicInfo:
        return 'Basic info';
      case CreateWorkshopStep.services:
        return 'Services';
      case CreateWorkshopStep.location:
        return 'Location';
      case CreateWorkshopStep.hours:
        return 'Working hours';
      case CreateWorkshopStep.gallery:
        return 'Photos';
      case CreateWorkshopStep.preview:
        return 'Preview';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stepIndex = _steps.indexOf(_draft.step);

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
        title: Text('Create workshop · ${_stepTitle()}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.rXl,
                  child: LinearProgressIndicator(
                    value: (stepIndex + 1) / _steps.length,
                    minHeight: 6,
                    backgroundColor: colors.surfaceMuted,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${stepIndex + 1} of ${_steps.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: KeyboardSafeView(child: _buildStep(colors)),
            ),
          ),
          StickyContinueBar(
            label: _draft.step == CreateWorkshopStep.preview
                ? 'Publish workshop'
                : 'Continue',
            enabled: _canContinue() && !_publishing,
            isLoading: _publishing,
            onPressed: _canContinue() ? _next : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppColors colors) {
    switch (_draft.step) {
      case CreateWorkshopStep.basicInfo:
        return _basicStep(colors);
      case CreateWorkshopStep.services:
        return _servicesStep(colors);
      case CreateWorkshopStep.location:
        return _locationStep(colors);
      case CreateWorkshopStep.hours:
        return _hoursStep(colors);
      case CreateWorkshopStep.gallery:
        return _galleryStep(colors);
      case CreateWorkshopStep.preview:
        return _previewStep(colors);
    }
  }

  Widget _basicStep(AppColors colors) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FieldLabel(text: 'Workshop name', required: true),
        const SizedBox(height: 8),
        CustomInput(
          controller: _nameCtrl,
          required: true,
          hintText: 'AutoPro Service',
          validator: (v) => FormValidators.title(context, v),
          onChanged: (_) => setState(() => _draft.name = _nameCtrl.text),
        ),
        const SizedBox(height: 16),
        const FieldLabel(text: 'Description', required: false),
        const SizedBox(height: 8),
        CustomInput(
          controller: _descCtrl,
          required: false,
          isTextarea: true,
          hintText: 'Tell customers what makes your workshop special',
          validator: (_) => null,
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
          onChanged: (_) => setState(() => _draft.phone = _phoneCtrl.text),
        ),
        const SizedBox(height: 12),
        const FieldLabel(text: 'Telegram', required: false),
        const SizedBox(height: 8),
        CustomInput(
          controller: _telegramCtrl,
          required: false,
          hintText: '@username',
          validator: (_) => null,
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('Fast response badge'),
          subtitle: const Text('Show as quick to reply'),
          value: _draft.fastResponse,
          onChanged: (v) => setState(() => _draft.fastResponse = v),
        ),
      ],
    );
  }

  Widget _servicesStep(AppColors colors) {
    if (_loadingCats) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load service categories.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() => _loadingCats = true);
                  _loadCategories();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final lang = categoryLanguageCode(context);
    final l10n = S.of(context);
    final popular =
        _categories.where((c) => c.popular).toList(growable: false);
    final other =
        _categories.where((c) => !c.popular).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FieldLabel(
          text: l10n.createWorkshopServicesTitle,
          required: true,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.createWorkshopServicesHint(_categories.length),
          style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
        ),
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 16),
          _serviceSectionTitle(l10n.createWorkshopPopular, colors),
          const SizedBox(height: 10),
          _serviceChips(popular, lang, colors),
        ],
        if (other.isNotEmpty) ...[
          const SizedBox(height: 20),
          _serviceSectionTitle(l10n.createWorkshopAllServices, colors),
          const SizedBox(height: 10),
          _serviceChips(other, lang, colors),
        ],
      ],
    );
  }

  Widget _serviceSectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
    );
  }

  Widget _serviceChips(
    List<WorkshopCategory> items,
    String lang,
    AppColors colors,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((c) {
        final selected = _draft.selectedCategoryIds.contains(c.id);
        final icon = categoryLucideIcon(c.icon) ?? LucideIcons.wrench;
        return FilterChip(
          avatar: Icon(
            icon,
            size: 18,
            color: selected ? colors.onPrimary : colors.primary,
          ),
          label: Text(c.localizedName(lang)),
          selected: selected,
          showCheckmark: false,
          onSelected: (v) {
            setState(() {
              if (v) {
                _draft.selectedCategoryIds = [
                  ..._draft.selectedCategoryIds,
                  c.id,
                ];
              } else {
                _draft.selectedCategoryIds = _draft.selectedCategoryIds
                    .where((id) => id != c.id)
                    .toList();
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _locationStep(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const FieldLabel(text: 'Location on map', required: true),
        const SizedBox(height: 6),
        Text(
          'Pin your workshop on the map so customers can find you and see you in nearby search.',
          style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickLocation,
          icon: const Icon(LucideIcons.mapPin),
          label: Text(
            _draft.geo == null
                ? 'Pick on map *'
                : 'Update location (${_draft.geo!.latitude.toStringAsFixed(4)}, ${_draft.geo!.longitude.toStringAsFixed(4)})',
          ),
        ),
        const SizedBox(height: 24),
        FieldLabel(
          text: 'Service radius',
          required: true,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'How far from your workshop you are ready to serve (km). Used on the map and in “nearby workshops”.',
          style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _draft.serviceRadiusKm,
          min: 5,
          max: 50,
          divisions: 9,
          label: '${_draft.serviceRadiusKm.round()} km',
          onChanged: (v) => setState(() => _draft.serviceRadiusKm = v),
        ),
        Text(
          '${_draft.serviceRadiusKm.round()} km',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _hoursStep(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WorkshopHoursEditor(
          schedule: _draft.weeklySchedule,
          open24Hours: _draft.open24Hours,
          onScheduleChanged: (next) =>
              setState(() => _draft.weeklySchedule = next),
          onOpen24HoursChanged: (value) =>
              setState(() => _draft.open24Hours = value),
        ),
      ],
    );
  }

  Widget _galleryStep(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        OutlinedButton.icon(
          onPressed: _pickPhotos,
          icon: const Icon(LucideIcons.imagePlus),
          label: const Text('Add photos'),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _draft.galleryFiles.map((f) {
            return ClipRRect(
              borderRadius: AppRadius.rM,
              child: Image.file(f, width: 96, height: 96, fit: BoxFit.cover),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _previewStep(AppColors colors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _nameCtrl.text.isEmpty ? 'Your workshop' : _nameCtrl.text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(_descCtrl.text, style: TextStyle(color: colors.textSecondary)),
        const SizedBox(height: 16),
        Text('${_draft.selectedCategoryIds.length} services selected'),
        Text(_draft.geo != null ? 'Location set' : 'No location'),
        Text(_hoursPreviewSummary()),
        Text('${_draft.galleryFiles.length} photos'),
      ],
    );
  }
}
