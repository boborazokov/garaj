import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/catalog/vehicle_catalog_repository.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/create_product/data/models/category_node.dart';
import 'package:my_auto/features/create_product/domain/entities/create_product_draft.dart';
import 'package:my_auto/features/orders/domain/entities/order.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/features/orders/domain/failures/orders_failure.dart';
import 'package:my_auto/core/utils/category_locale.dart';
import 'package:my_auto/features/orders/orders_di.dart';
import 'package:my_auto/features/orders/presentation/widgets/order_images.dart';
import 'package:my_auto/widgets/form/app_form_field.dart';
import 'package:my_auto/widgets/form/field_label.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/catalog_picker/catalog_picker_sheet.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';

/// Multi-step create request: vehicle pickers → part → budget → preview.
class CreateOrderWizardScreen extends StatefulWidget {
  const CreateOrderWizardScreen({super.key, this.initialTitle});

  final String? initialTitle;

  @override
  State<CreateOrderWizardScreen> createState() =>
      _CreateOrderWizardScreenState();
}

class _CreateOrderWizardScreenState extends State<CreateOrderWizardScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _catalogRepo = VehicleCatalogRepository();
  int _step = 0;

  VehicleSelection _vehicle = const VehicleSelection();
  List<CategoryNode> _brands = [];
  List<CategoryNode> _partCategories = [];
  bool _catalogLoading = true;
  String? _catalogError;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  OrderUrgency _urgency = OrderUrgency.medium;
  double _budgetSlider = 500000;
  bool _submitting = false;
  final List<File> _photos = [];

  static const _partTemplateDefs = [
    ('engine', LucideIcons.cog),
    ('bumper', LucideIcons.car),
    ('lights', LucideIcons.lightbulb),
    ('brakes', LucideIcons.circleDot),
    ('suspension', LucideIcons.activity),
  ];

  String _partTemplateLabel(S s, String key) {
    switch (key) {
      case 'engine':
        return s.orderPartEngine;
      case 'bumper':
        return s.orderPartBumper;
      case 'lights':
        return s.orderPartHeadlights;
      case 'brakes':
        return s.orderPartBrakes;
      case 'suspension':
        return s.orderPartSuspension;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    if ((widget.initialTitle ?? '').isNotEmpty) {
      _titleCtrl.text = widget.initialTitle!;
    }
    final phone = context.read<AuthProvider>().auth?.user.phone;
    if (phone != null && phone.isNotEmpty) _phoneCtrl.text = phone;
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    try {
      final data = await _catalogRepo.load();
      if (!mounted) return;
      if (!data.isReady) {
        setState(() {
          _catalogLoading = false;
          _catalogError = S.of(context).errorOccurred;
          _brands = data.brands;
          _partCategories = data.partCategories;
        });
        return;
      }
      setState(() {
        _brands = data.brands;
        _partCategories = data.partCategories;
        _catalogLoading = false;
        _catalogError = null;
      });
    } on VehicleCatalogException catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogLoading = false;
        _catalogError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _catalogLoading = false;
        _catalogError = S.of(context).noInternetConnection;
      });
    }
  }

  Future<List<CategoryNode>> _loadModels() async {
    final brandId = _vehicle.brandId;
    if (brandId == null) return [];
    return _catalogRepo.modelsForBrand(brandId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _yearCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  String? _validateStep() {
    final s = S.of(context);
    switch (_step) {
      case 0:
        if (_vehicle.brandId == null) return '${s.selectBrand} *';
        if (_vehicle.modelId == null) return '${s.selectModel} *';
        return null;
      case 1:
        if (_vehicle.partCategoryId == null) return '${s.selectPartCategory} *';
        if (FormValidators.title(context, _titleCtrl.text) != null) {
          return s.fieldRequired;
        }
        return null;
      case 2:
        if (FormValidators.phone(context, _phoneCtrl.text) != null) {
          return s.fieldRequired;
        }
        return null;
      default:
        return null;
    }
  }

  Map<String, dynamic> _buildPayload() {
    final budget = int.tryParse(_budgetCtrl.text.replaceAll(' ', '')) ??
        _budgetSlider.round();

    final descLines = <String>[];
    if (_descCtrl.text.trim().isNotEmpty) {
      descLines.add(_descCtrl.text.trim());
    }
    if (_vehicle.year != null) {
      descLines.add('Year: ${_vehicle.year}');
    }
    // Only fields defined in GraphQL OrderInput (see backend order.input.ts).
    return {
      'title': _titleCtrl.text.trim(),
      'description': descLines.join('\n'),
      'phone': _phoneCtrl.text.trim(),
      'urgency': _urgency.toApi(),
      if (_locationCtrl.text.isNotEmpty) 'location': _locationCtrl.text.trim(),
      if (budget > 0) 'budget': budget.toDouble(),
      if (_vehicle.brandId != null) 'brand': _vehicle.brandId,
      if (_vehicle.modelId != null) 'carModel': _vehicle.modelId,
      if (_vehicle.partCategoryId != null)
        'partCategory': _vehicle.partCategoryId,
    };
  }

  Future<void> _submit() async {
    final err = _validateStep();
    if (err != null) {
      Toaster.error(err);
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      Toaster.error(S.of(context).requiredField);
      return;
    }
    setState(() => _submitting = true);
    try {
      final orderId = await ordersRepository.createOrder(_buildPayload());
      if (_photos.isNotEmpty) {
        await ordersRepository.uploadOrderImages(
          orderId: orderId,
          files: _photos,
        );
      }
      if (!mounted) return;
      Toaster.success(S.of(context).orderCreated);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final s = S.of(context);
      final msg = switch (e) {
        OrdersValidationFailure(:final message) =>
          GraphqlErrorUi.localizeRaw(context, message),
        OrdersAuthFailure() => s.signInToContinue,
        OrdersNetworkFailure() => s.noInternetConnection,
        OrdersFailure(:final message) =>
          GraphqlErrorUi.localizeRaw(context, message),
        _ => s.errorOccurred,
      };
      UserFacingErrors.show(
        context,
        presentation: ErrorPresentation.userAction,
        fallback: msg,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _next() {
    final err = _validateStep();
    if (err != null) {
      UserFacingErrors.show(
        context,
        presentation: ErrorPresentation.userAction,
        fallback: err,
      );
      return;
    }
    if (_step == 1 || _step == 2) {
      if (!(_formKey.currentState?.validate() ?? true)) return;
    }
    if (_step < 3) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: AppMotion.base,
        curve: AppMotion.standard,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: AppMotion.base,
        curve: AppMotion.standard,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _pickBrand() {
    showCatalogPickerSheet(
      context,
      title: S.of(context).selectBrand,
      items: _brands,
      onPick: (n) {
        final label = n.localizedName(categoryLanguageCode(context));
        setState(() {
          _vehicle = VehicleSelection(brandId: n.id, brandName: label);
          _yearCtrl.clear();
        });
      },
    );
  }

  Future<void> _pickModel() async {
    final models = await _loadModels();
    if (!mounted) return;
    if (models.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).selectBrand)),
      );
      return;
    }
    showCatalogPickerSheet(
      context,
      title: S.of(context).selectModel,
      items: models,
      onPick: (n) {
        final label = n.localizedName(categoryLanguageCode(context));
        setState(() {
          _vehicle = VehicleSelection(
            brandId: _vehicle.brandId,
            brandName: _vehicle.brandName,
            modelId: n.id,
            modelName: label,
            year: _vehicle.year,
            partCategoryId: _vehicle.partCategoryId,
            partCategoryName: _vehicle.partCategoryName,
          );
        });
      },
    );
  }

  void _pickPartCategory() {
    showCatalogPickerSheet(
      context,
      title: S.of(context).selectPartCategory,
      items: _partCategories,
      onPick: (n) {
        final label = n.localizedName(categoryLanguageCode(context));
        setState(() {
          _vehicle = _vehicle.copyWith(
            partCategoryId: n.id,
            partCategoryName: label,
          );
          if (_titleCtrl.text.trim().isEmpty) {
            _titleCtrl.text = S.of(context).orderDetailNeedsPart(label);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    const stepCount = 4;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppTopBar(title: s.createRequest),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: List.generate(stepCount, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < stepCount - 1 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step ? colors.primary : colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _stepLabel(s),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            ),
          ),
          Expanded(
            child: KeyboardSafeView(
              child: _buildBody(colors, s),
            ),
          ),
          BottomSafeButton(
            elevation: 6,
            backgroundColor: colors.background,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : _back,
                    child: Text(_step == 0 ? s.cancel : s.back),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: (_submitting || _catalogLoading || _catalogError != null)
                        ? null
                        : _next,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_step == 3 ? s.publish : s.next),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors colors, S s) {
    if (_catalogLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_catalogError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.database, size: 48, color: colors.textMuted),
              const SizedBox(height: 16),
              Text(
                _catalogError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                s.createRequestSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadCatalog,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: Text(s.update),
              ),
            ],
          ),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _stepVehicle(colors, s),
          _stepPart(colors, s),
          _stepBudget(colors, s),
          _stepPreview(colors, s),
        ],
      ),
    );
  }

  String _stepLabel(S s) {
    switch (_step) {
      case 0:
        return s.createProductStepVehicle;
      case 1:
        return s.partCategory;
      case 2:
        return s.budgetOptional;
      default:
        return s.createProductStepPreview;
    }
  }

  String _urgencyLabel(S s) {
    return switch (_urgency) {
      OrderUrgency.urgent => s.orderUrgencyUrgent,
      OrderUrgency.low => s.orderUrgencyLow,
      OrderUrgency.medium => s.orderUrgencyNormal,
    };
  }

  Widget _hero(AppColors colors, S s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.rL,
      ),
      child: Row(
        children: [
          Icon(LucideIcons.megaphone, color: colors.onPrimary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.didntFindWhatYouNeed,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.createRequestSubtitle,
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepVehicle(AppColors colors, S s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _hero(colors, s),
        Text(
          s.createProductStepVehicle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          s.createRequestSubtitle,
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        CatalogPickerTile(
          label: s.brand,
          value: _vehicle.brandName,
          icon: LucideIcons.car,
          required: true,
          onTap: _pickBrand,
        ),
        CatalogPickerTile(
          label: s.carModel,
          value: _vehicle.modelName,
          icon: LucideIcons.layers,
          required: true,
          enabled: _vehicle.brandId != null,
          onTap: _vehicle.brandId == null ? null : _pickModel,
        ),
        const FieldLabel(text: 'Year', required: false),
        TextFormField(
          controller: _yearCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '2020',
            filled: true,
            fillColor: colors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: AppRadius.rL,
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (y) => setState(() {
            _vehicle = _vehicle.copyWith(
              year: y.trim().isEmpty ? null : int.tryParse(y),
            );
          }),
        ),
      ],
    );
  }

  Widget _stepPart(AppColors colors, S s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.partCategory,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        CatalogPickerTile(
          label: s.partCategory,
          value: _vehicle.partCategoryName,
          icon: LucideIcons.tag,
          required: true,
          onTap: _pickPartCategory,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _partTemplateDefs.map((t) {
            final label = _partTemplateLabel(s, t.$1);
            return ActionChip(
              avatar: Icon(t.$2, size: 16),
              label: Text(label),
              onPressed: () => setState(
                () => _titleCtrl.text = s.orderDetailNeedsPart(label),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AppFormField(
          controller: _titleCtrl,
          label: s.title,
          required: true,
          hint: s.exampleTittleParts,
          validator: (v) => FormValidators.title(context, v),
        ),
        const SizedBox(height: 12),
        AppFormField(
          controller: _descCtrl,
          label: s.description,
          required: false,
          hint: s.enterDescription,
          maxLines: 4,
          minLength: 0,
        ),
        const SizedBox(height: 16),
        OrderPhotosPicker(
          photos: _photos,
          onChanged: (files) => setState(() {
            _photos
              ..clear()
              ..addAll(files);
          }),
        ),
        const SizedBox(height: 20),
        Text(
          s.orderUrgencyTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          s.orderUrgencyHint,
          style: TextStyle(fontSize: 13, color: colors.textMuted),
        ),
        const SizedBox(height: 10),
        SegmentedButton<OrderUrgency>(
          segments: [
            ButtonSegment(
              value: OrderUrgency.low,
              label: Text(s.orderUrgencyLow),
            ),
            ButtonSegment(
              value: OrderUrgency.medium,
              label: Text(s.orderUrgencyNormal),
            ),
            ButtonSegment(
              value: OrderUrgency.urgent,
              label: Text(s.orderUrgencyUrgent),
              icon: const Icon(LucideIcons.flame, size: 16),
            ),
          ],
          selected: {_urgency},
          onSelectionChanged: (sel) => setState(() => _urgency = sel.first),
        ),
      ],
    );
  }

  Widget _stepBudget(AppColors colors, S s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.budgetOptional,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Text(
          '${_budgetSlider.round()} UZS',
          style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        Slider(
          value: _budgetSlider,
          min: 0,
          max: 50000000,
          divisions: 100,
          onChanged: (v) => setState(() {
            _budgetSlider = v;
            _budgetCtrl.text = v.round().toString();
          }),
        ),
        AppFormField(
          controller: _budgetCtrl,
          label: s.budgetOptional,
          required: false,
          keyboardType: TextInputType.number,
          minLength: 0,
        ),
        const SizedBox(height: 16),
        AppFormField(
          controller: _locationCtrl,
          label: s.location,
          required: false,
          hint: s.chooseLocation,
          icon: LucideIcons.mapPin,
          minLength: 0,
        ),
        const SizedBox(height: 12),
        AppFormField(
          controller: _phoneCtrl,
          label: s.phoneNumber,
          required: true,
          keyboardType: TextInputType.phone,
          validator: (v) => FormValidators.phone(context, v),
        ),
      ],
    );
  }

  Widget _stepPreview(AppColors colors, S s) {
    final budget = _budgetCtrl.text.isEmpty
        ? _budgetSlider.round().toString()
        : _budgetCtrl.text;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          s.createProductStepPreview,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.rXl,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_photos.isNotEmpty) ...[
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: AppRadius.rL,
                      child: Image.file(
                        _photos[i],
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                _titleCtrl.text,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              if (_vehicle.partCategoryName != null) ...[
                const SizedBox(height: 6),
                Text(
                  _vehicle.partCategoryName!,
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                [
                  _vehicle.brandName,
                  _vehicle.modelName,
                  if (_vehicle.year != null) _vehicle.year.toString(),
                ].whereType<String>().join(' '),
                style: TextStyle(color: colors.textSecondary),
              ),
              if (_descCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_descCtrl.text),
              ],
              if (_urgency != OrderUrgency.medium) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_urgency == OrderUrgency.urgent)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          LucideIcons.flame,
                          size: 18,
                          color: colors.danger,
                        ),
                      ),
                    Text(
                      _urgencyLabel(s),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _urgency == OrderUrgency.urgent
                            ? colors.danger
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text('$budget UZS'),
              Text(_phoneCtrl.text),
              if (_locationCtrl.text.isNotEmpty) Text(_locationCtrl.text),
            ],
          ),
        ),
      ],
    );
  }
}
