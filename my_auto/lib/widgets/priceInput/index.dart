import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/generated/l10n.dart';

class PriceInput extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController partController;
  final String? Function(String?)? validator;

  const PriceInput({
    super.key,
    required this.controller,
    required this.partController,
    this.validator,
  });

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // 🔹 Инициализация контроллера вкладок
    _tabController = TabController(length: 2, vsync: this);

    // 🔹 Когда пользователь меняет вкладку — обновляем currency
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final newCurrency = _tabController.index == 0 ? "UZS" : "USD";
      if (widget.partController.text != newCurrency) {
        widget.partController.text = newCurrency;
      }
    });

    // 🔹 Следим за изменением внешнего контроллера
    widget.partController.addListener(_syncCurrency);

    // 🔹 Устанавливаем правильный индекс после сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCurrency();
    });
  }

  void _syncCurrency() {
    final currency = widget.partController.text.trim().toUpperCase();
    final index = currency == "USD" ? 1 : 0;
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    widget.partController.removeListener(_syncCurrency);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return Row(
      children: [
        Expanded(
          child: AppInputField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hintText: s.enterPrice,
            validator: widget.validator,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 50,
          width: 130,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.4),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor:
                  theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              tabs: const [
                Tab(text: "UZS"),
                Tab(text: "USD"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;

  const AppInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      inputFormatters: inputFormatters,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return s.fieldRequired;
            }
            return null;
          },
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface,
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
}
