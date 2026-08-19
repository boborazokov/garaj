import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/auth/presentation/providers/confirmation_provider.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_auto/core/auth/pending_signup_token.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfirmationProvider>();
    final controller = provider.controller;
    final s = S.of(context);
    final colors = context.appColors;

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
        fontWeight: FontWeight.w800,
        color: colors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
      ),
    );

    return AuthScaffold(
      showSkip: false,
      isLoading: provider.isLoading,
      primaryLabel: s.confirm,
      onPrimary: _submit,
      primaryEnabled: _tokenReady,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          children: [
            AuthHeader(
              title: s.confirm,
              subtitle: s.enterCodeMessage,
              showLogo: false,
            ),
            Pinput(
              length: 5,
              autofocus: true,
              closeKeyboardWhenCompleted: true,
              keyboardType: TextInputType.number,
              controller: controller.codeController,
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: colors.primary, width: 2),
                ),
              ),
              errorPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: colors.danger, width: 2),
                ),
              ),
              onCompleted: (_) {
                if (_tokenReady && _signupToken.isNotEmpty) _submit();
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
