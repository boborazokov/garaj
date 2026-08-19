import 'package:flutter/material.dart';

class SignInController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneFocus = FocusNode();
  final passwordFocus = FocusNode();

  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  void clearForm() => formKey.currentState?.reset();
}
