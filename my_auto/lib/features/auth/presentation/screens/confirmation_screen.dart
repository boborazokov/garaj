import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_auto/core/auth/pending_signup_token.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/auth/presentation/providers/confirmation_provider.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({
    super.key,
    required this.token,
    required this.correctCode,
  });

  final String token;
  final int correctCode;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  String _signupToken = '';
  bool _tokenReady = false;

  @override
  void initState() {
    super.initState();
    context.read<ConfirmationProvider>().controller.startListening();
    _resolveSignupToken();
  }

  Future<void> _resolveSignupToken() async {
    final cached = (await readPendingSignupToken())?.trim() ?? '';
    final fromExtra = widget.token.trim();
    final token = cached.isNotEmpty ? cached : fromExtra;
    if (!mounted) return;
    setState(() {
      _signupToken = token;
      _tokenReady = true;
    });
  }

  void _submit() {
    final provider = context.read<ConfirmationProvider>();
    final s = S.of(context);
    if (!_tokenReady) return;
    if (_signupToken.isEmpty) {
      Toaster.error(s.invalidOtpCode);
      return;
    }
    provider.confirmCode(context, _signupToken);
  }

  String _stepLabel(String languageCode) {
    return switch (languageCode) {
      'ru' => 'Шаг 2 из 2',
      'en' => 'Step 2 of 2',
      _ => '2 / 2 qadam',
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfirmationProvider>();
    final controller = provider.controller;
    final s = S.of(context);
    final colors = context.appColors;
    final lang = Localizations.localeOf(context).languageCode;

    if (kDebugMode && widget.correctCode > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.codeController.text.isEmpty) {
          controller.codeController.text = widget.correctCode.toString();
        }
      });
    }

    final pinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rM,
        border: Border.all(color: colors.border),
      ),
    );

    return AuthScaffold(
      showSkip: false,
      isLoading: provider.isLoading,
      primaryLabel: s.confirm,
      onPrimary: _submit,
      primaryEnabled: _tokenReady,
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.s,
          AppSpacing.screenPadding,
          AppSpacing.l,
        ),
        children: [
          AuthHeader(
            title: s.confirm,
            subtitle: s.enterCodeMessage,
            stepLabel: _stepLabel(lang),
            showLogo: false,
            compact: true,
          ),
          AutofillGroup(
            child: Pinput(
              length: 5,
              autofocus: true,
              closeKeyboardWhenCompleted: true,
              keyboardType: TextInputType.number,
              controller: controller.codeController,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: colors.primary, width: 1.5),
                ),
              ),
              errorPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: colors.danger, width: 1.5),
                ),
              ),
              onCompleted: (_) {
                if (_tokenReady && _signupToken.isNotEmpty) _submit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
