import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_top_bar.dart';
import 'package:my_auto/widgets/button/index.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.isLoading = false,
    this.showSkip = true,
    this.primaryEnabled = true,
  });

  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final bool showSkip;
  final bool primaryEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AuthTopBar(showSkip: showSkip),
      body: KeyboardSafeView(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: body,
        ),
      ),
      bottomNavigationBar: BottomSafeButton(
        child: Button(
          isLoading: isLoading,
          title: primaryLabel,
          onTap: primaryEnabled ? onPrimary : null,
        ),
      ),
    );
  }
}
