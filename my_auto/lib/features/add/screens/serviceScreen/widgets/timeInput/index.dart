import 'dart:io';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';

class TimeInput extends StatelessWidget {
  const TimeInput({
    super.key,
    required this.controller,
    required this.labelText,
  });

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () {
        if (Platform.isIOS) {
          showCupertinoModalPopup(
            context: context,
            builder: (_) => Container(
              height: 250,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime time) {
                        final formatted =
                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                        controller.text = formatted;
                      },
                    ),
                  ),
                  CupertinoButton(
                    child: Text(S.of(context).select),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        } else {
          BottomPicker.rangeTime(
            height: MediaQuery.of(context).size.height * 0.4,
            displayCloseIcon: false,
            pickerTitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                S.of(context).workingTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            showTimeSeparator: true,
            use24hFormat: true,
            dismissable: true,
            buttonWidth: MediaQuery.of(context).size.width - 32,
            buttonPadding: 14,
            buttonStyle: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            buttonContent: Text(
              textAlign: TextAlign.center,
              S.of(context).select,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onRangeTimeSubmitPressed: (DateTime startTime, DateTime endTime) {
              final formattedStart =
                  "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
              final formattedEnd =
                  "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
              controller.text = "$formattedStart - $formattedEnd";
            },
          ).show(context);
        }
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: labelText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? labelText : null,
    );
  }
}
