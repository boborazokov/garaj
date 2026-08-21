import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/orders/orders_provider.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/core/forms/form_validators.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:my_auto/widgets/form/field_label.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';

/// Form to create a buy-request (announcement / order).
///
/// Designed to be entered with an optional pre-fill from the search query
/// the user just made; passing [initialTitle] will populate the title field.
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key, this.initialTitle});

  final String? initialTitle;

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _budget = TextEditingController();

  @override
  void initState() {
    super.initState();
    if ((widget.initialTitle ?? '').isNotEmpty) {
      _title.text = widget.initialTitle!;
    }
    final authPhone = context.read<AuthProvider>().auth?.user.phone;
    if (authPhone != null && authPhone.isNotEmpty) {
      _phone.text = authPhone;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _phone.dispose();
    _location.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = S.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final budget = int.tryParse(_budget.text.replaceAll(' ', ''));
    final data = <String, dynamic>{
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'phone': _phone.text.trim(),
      if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
      if (budget != null && budget > 0) 'budget': budget,
    };

    try {
      await context.read<OrdersProvider>().createOrder(data);
      if (!mounted) return;
      Toaster.success(s.orderCreated);
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      Toaster.error(s.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final provider = context.watch<OrdersProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.createOrder),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Hero(colors: colors),
              const SizedBox(height: 16),
              _Field(
                controller: _title,
                label: s.title,
                required: true,
                hint: s.exampleTittleParts,
                icon: LucideIcons.tag,
                validator: (v) => FormValidators.title(context, v),
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _description,
                label: s.description,
                hint: s.enterDescription,
                icon: LucideIcons.fileText,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _phone,
                label: s.phoneNumber,
                required: true,
                hint: '+998 ...',
                icon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => FormValidators.phone(context, v),
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _location,
                label: s.location,
                hint: s.chooseLocation,
                icon: LucideIcons.mapPin,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _budget,
                label: s.budgetOptional,
                hint: s.enterPrice,
                icon: LucideIcons.wallet,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: provider.isCreating ? null : _submit,
                  icon: provider.isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.send),
                  label: Text(s.submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AppColors colors;
  const _Hero({required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.rL,
        boxShadow: AppShadows.glow(colors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.18),
              borderRadius: AppRadius.rM,
            ),
            child: Icon(LucideIcons.megaphone,
                color: colors.onPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.didntFindWhatYouNeed,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.createRequestSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final bool required;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: required),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(icon, size: 18),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}
