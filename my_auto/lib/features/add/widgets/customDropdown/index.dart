import 'package:flutter/material.dart';

class CustomDropdownField<T> extends FormField<T> {
  CustomDropdownField({
    super.key,
    T? value,
    required List<T> items,
    required String hint,
    required String Function(T) getLabel,
    String? Function(T)? getImage,
    required void Function(T?) onChanged,
    bool enabled = true,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<T> state) {
            final theme = Theme.of(state.context);
            final selectedValue = state.value;
            final labelText =
                selectedValue != null ? getLabel(selectedValue) : hint;

            void openBottomSheet() {
              showModalBottomSheet(
                context: state.context,
                showDragHandle: true,
                isScrollControlled: true,
                backgroundColor: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = selectedValue == item;

                        return ListTile(
                          leading: getImage != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(getImage(item) ?? ''),
                                )
                              : null,
                          title: Text(
                            getLabel(item),
                            style: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyLarge?.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            onChanged(item);
                            state.didChange(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  );
                },
              );
            }

            return GestureDetector(
              onTap: enabled && items.isNotEmpty ? openBottomSheet : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: enabled
                      ? theme.colorScheme.surface
                      : theme.disabledColor.withOpacity(0.1),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  labelText,
                  style: TextStyle(
                    color: selectedValue == null
                        ? theme.hintColor
                        : theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );

  @override
  FormFieldState<T> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends FormFieldState<T> {
  @override
  void didUpdateWidget(covariant FormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newWidget = widget as CustomDropdownField<T>;

    // 👇 если значение обновилось во внешнем состоянии — обновляем форму
    if (newWidget.initialValue != value) {
      setValue(newWidget.initialValue);
    }
  }
}
