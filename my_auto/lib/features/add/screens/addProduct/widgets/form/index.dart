import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/core/model/category_names.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/provider/add/addPartProvider.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/features/add/widgets/conditionSelecor/index.dart';
import 'package:my_auto/features/add/widgets/customDropdown/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/widgets/button/index.dart';
import 'package:my_auto/widgets/form/field_label.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:my_auto/widgets/priceInput/index.dart';
import 'package:provider/provider.dart';

class FormPart extends StatefulWidget {
  final VoidCallback? onNext;
  const FormPart({super.key, this.onNext});

  @override
  State<FormPart> createState() => _FormPartState();
}

class _FormPartState extends State<FormPart> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _quantityController = TextEditingController();

  String? _condition;
  String? _delivery;
  CategoryCar? _selectedCategory;
  bool _negotiable = false;
  TextEditingController currency = TextEditingController(text: "UZS");

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final categoryProvider = context.read<GetCategories>();
      await categoryProvider.loadCategories(type.PART.name);

      final provider = context.read<AddPartProvider>();

      if (provider.id != null) {
        _titleController.text = provider.title ?? '';
        _descController.text = provider.description ?? '';
        _priceController.text =
            provider.price != null ? provider.price.toString() : '';
        _discountController.text =
            provider.discount != null ? provider.discount.toString() : '';
        _quantityController.text =
            provider.quantity != null ? provider.quantity.toString() : '';

        _condition = provider.condition;
        _delivery = provider.delivery;
        _negotiable = provider.negotiable;
        currency.text = provider.currency ?? 'UZS';

        final categories = categoryProvider.categories;
        final category = categories.firstWhere(
          (cat) => cat.id == provider.categoryId,
          orElse: () {
            final label = provider.categoriesName ?? '';
            return CategoryCar(
              id: provider.categoryId ?? '',
              names: CategoryNames(en: label, ru: label, uz: label),
              name: label,
            );
          },
        );

        setState(() {
          _selectedCategory = category;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AddPartProvider>();

    provider.setFormData(
      title: _titleController.text,
      description: _descController.text,
      categoryId: _selectedCategory!.id,
      price: int.tryParse(_priceController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      discount: int.tryParse(_discountController.text) ?? 0,
      currency: currency.text,
      negotiable: _negotiable,
      delivery: _delivery,
      categoriesName: _selectedCategory!.name,
      condition: _condition,
    );

    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.watch<GetCategories>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              FieldLabel(
                text: S.of(context).titleOfParts,
                required: true,
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: _titleController,
                required: true,
                hintText: S.of(context).exampleTittleParts,
                validator: (val) => val == null || val.isEmpty
                    ? S.of(context).enterTitleOfPart
                    : null,
              ),
              const SizedBox(height: 16),
              FieldLabel(
                text: S.of(context).modelOfCar,
                required: true,
              ),
              const SizedBox(height: 8),
              CustomDropdownField<CategoryCar>(
                hint: S.of(context).modelOfCar,
                items: categoriesProvider.categories,
                value: _selectedCategory,
                getLabel: (cat) => cat.localizedName(
                      Localizations.localeOf(context).languageCode,
                    ),
                getImage: (cat) => cat.iconUrl,
                validator: (value) {
                  if (value == null) return S.of(context).chooseCategory;
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              FieldLabel(
                text: S.of(context).condition,
                required: true,
              ),
              const SizedBox(height: 8),
              SelectChipGroupFormField(
                options: ['used', 'newPart'],
                initialValue: _condition,
                onChanged: (v) => _condition = v,
                validator: (value) {
                  if (value == null) return S.of(context).chooseCondition;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FieldLabel(
                text: S.of(context).price,
                required: true,
              ),
              PriceInput(
                controller: _priceController,
                partController: currency,
                validator: (val) => val == null || val.isEmpty
                    ? S.of(context).enterPrice
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(S.of(context).negotiable,
                    style: Theme.of(context).textTheme.titleSmall),
                trailing: CupertinoSwitch(
                  activeColor: Theme.of(context).primaryColor,
                  value: _negotiable,
                  onChanged: (val) => setState(() => _negotiable = val),
                ),
              ),
              const SizedBox(height: 16),
              Text(S.of(context).delivery,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SelectChipGroupFormField(
                options: ["haveDelivery", "noDelivery", "byAgreement"],
                initialValue: _delivery,
                onChanged: (val) => setState(() => _delivery = val),
                validator: (val) => val == null || val.isEmpty
                    ? S.of(context).chooseDeliveryMethod
                    : null,
              ),
              const SizedBox(height: 16),
              Text(S.of(context).descriptionOfParts,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              CustomInput(
                controller: _descController,
                hintText: S.of(context).enterDescription,
                isTextarea: true,
                validator: (val) => val == null || val.isEmpty
                    ? S.of(context).enterDescriptionPart
                    : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomSafeButton(
        child: Button(
          title: S.of(context).next,
          onTap: _onNext,
        ),
      ),
    );
  }
}
