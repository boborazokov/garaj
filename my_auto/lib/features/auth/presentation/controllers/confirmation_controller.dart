import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class ConfirmationController extends ChangeNotifier with CodeAutoFill {
  final TextEditingController codeController = TextEditingController();
  String? _code;

  String? get code => _code;

  void startListening() => listenForCode();

  @override
  void codeUpdated() {
    _code = code;
    codeController.text = code ?? '';
    notifyListeners();
  }

  @override
  void dispose() {
    cancel();
    codeController.dispose();
    super.dispose();
  }
}
