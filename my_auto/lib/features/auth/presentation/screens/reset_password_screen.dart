import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_coordinator.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:pinput/pinput.dart';

const _requestReset = r'''
mutation RequestPasswordReset($phone: String!) {
  requestPasswordReset(phone: $phone) {
    token
    correctCode
  }
}
''';

const _resetPassword = r'''
mutation ResetPassword($token: String!, $code: String!, $password: String!) {
  resetPassword(token: $token, code: $code, password: $password)
}
''';

/// Phone → 5-digit SMS code → new password twice → back to login.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0;
  bool _loading = false;
  String _token = '';

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _title(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Восстановление пароля';
      case 'en':
        return 'Reset password';
      default:
        return 'Parolni tiklash';
    }
  }

  String _newPasswordLabel(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Новый пароль';
      case 'en':
        return 'New password';
      default:
        return 'Yangi parol';
    }
  }

  String _doneMessage(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Пароль обновлён. Войдите с номером и новым паролем.';
      case 'en':
        return 'Password updated. Sign in with your phone and the new password.';
      default:
        return 'Parol yangilandi. Telefon raqami va yangi parol bilan kiring.';
    }
  }

  Future<void> _onPrimary() async {
    switch (_step) {
      case 0:
        await _sendCode();
      case 1:
        await _goToNewPassword();
      default:
        await _savePassword();
    }
  }

  Future<void> _sendCode() async {
    final phone = _phone.text.replaceAll(RegExp(r'[^+0-9]'), '');
    if (phone.length < 9) return;
    setState(() => _loading = true);
    try {
      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(_requestReset),
          operationName: 'RequestPasswordReset',
          variables: {'phone': phone},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );
      if (!mounted) return;
      final payload = result.data?['requestPasswordReset'];
      if (payload is! Map || payload['token'] == null) {
        UserFacingErrors.show(
          context,
          presentation: ErrorPresentation.userAction,
          result: result,
        );
        return;
      }
      _token = payload['token'].toString();
      final hint = payload['correctCode'];
      if (hint != null) {
        _code.text = hint.toString().padLeft(5, '0');
      }
      setState(() => _step = 1);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToNewPassword() async {
    final digits = _code.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 5 || _token.isEmpty) return;
    setState(() => _step = 2);
  }

  Future<void> _savePassword() async {
    final s = S.of(context);
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.passwordLength)),
      );
      return;
    }
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.passwordsDoNotMatch)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(_resetPassword),
          operationName: 'ResetPassword',
          variables: {
            'token': _token,
            'code': _code.text.replaceAll(RegExp(r'\D'), ''),
            'password': _password.text,
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );
      if (!mounted) return;
      if (result.data?['resetPassword'] != true) {
        UserFacingErrors.show(
          context,
          presentation: ErrorPresentation.userAction,
          result: result,
        );
        return;
      }
      final lang = Localizations.localeOf(context).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_doneMessage(lang))),
      );
      context.pop();
      await AuthCoordinator.instance.clearSession();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    final lang = Localizations.localeOf(context).languageCode;
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

    final primary = switch (_step) {
      0 => s.submit,
      1 => s.confirm,
      _ => s.saveChanges,
    };

    return AuthScaffold(
      showSkip: false,
      isLoading: _loading,
      primaryLabel: primary,
      onPrimary: _loading ? null : _onPrimary,
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(title: _title(lang), showLogo: false),
            if (_step == 0)
              CustomInput(
                controller: _phone,
                type: TextInputType.phone,
                label: s.phone,
                required: true,
                hintText: s.phone,
                icon: Icon(LucideIcons.phone, color: colors.primary),
              ),
            if (_step == 1) ...[
              Text(
                s.enterCodeMessage,
                style: TextStyle(color: colors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 16),
              Pinput(
                length: 5,
                autofocus: true,
                keyboardType: TextInputType.number,
                controller: _code,
                defaultPinTheme: pinTheme,
              ),
            ],
            if (_step == 2) ...[
              CustomInput(
                controller: _password,
                label: _newPasswordLabel(lang),
                required: true,
                hintText: _newPasswordLabel(lang),
                type: TextInputType.visiblePassword,
                icon: Icon(LucideIcons.lock, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              CustomInput(
                controller: _confirm,
                label: s.password,
                required: true,
                hintText: s.password,
                type: TextInputType.visiblePassword,
                icon: Icon(LucideIcons.lock, color: colors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
