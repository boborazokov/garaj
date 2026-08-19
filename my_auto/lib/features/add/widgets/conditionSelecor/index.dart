import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';

class SelectChipGroupFormField extends FormField<String> {
  SelectChipGroupFormField({
    super.key,
    required List<String> options,
    required ValueChanged<String> onChanged,
    super.initialValue,
    Axis direction = Axis.horizontal,
    bool wrap = false,
    super.validator,
  }) : super(
          builder: (FormFieldState<String> state) {
            final theme = Theme.of(state.context);
            final s = S.of(state.context);

            String _translate(String key) {
              const translationKeys = {
                "used": "used",
                "newPart": "newPart",
                "haveDelivery": "haveDelivery",
                "noDelivery": "noDelivery",
                "byAgreement": "byAgreement",
                "included": "haveDelivery",
                "notIncluded": "noDelivery",
                "underContract": "byAgreement",
              };
              final mappedKey = translationKeys[key] ?? key;

              switch (mappedKey) {
                case "used":
                  return s.used;
                case "newPart":
                  return s.newPart;
                case "haveDelivery":
                  return s.available;
                case "noDelivery":
                  return s.noAvailable;
                case "byAgreement":
                  return s.byAgreement;
                default:
                  return key;
              }
            }

            final selectedColor = theme.colorScheme.primary;
            final unselectedColor = theme.colorScheme.surface;
            final textColor = theme.colorScheme.onSurface;

            final children = options.map((key) {
              final isSelected = state.value == key;

              return GestureDetector(
                onTap: () {
                  state.didChange(key);
                  onChanged(key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? selectedColor : unselectedColor,
                    border: Border.all(
                      color: isSelected
                          ? selectedColor
                          : theme.dividerColor.withOpacity(0.5),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: selectedColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _translate(key),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : textColor.withOpacity(0.8),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wrap
                    ? Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceBetween,
                        children: children,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: children
                            .map((e) => Expanded(child: e))
                            .toList(growable: false),
                      ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 8),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

  @override
  FormFieldState<String> createState() => _SelectChipGroupFormFieldState();
}

class _SelectChipGroupFormFieldState extends FormFieldState<String> {
  @override
  void didUpdateWidget(covariant FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newWidget = widget as SelectChipGroupFormField;

    if (newWidget.initialValue != value) {
      setValue(newWidget.initialValue);
    }
  }
}
