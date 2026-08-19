import 'package:flutter/material.dart';

class SignUpController {
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final passwordFocus = FocusNode();

  void dispose() {
    scrollController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;
}
