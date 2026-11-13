import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_coordinator.dart';
import 'package:my_auto/core/errors/user_facing_errors.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/phoneFormater.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:pinput/pinput.dart';

const _requestReset = r'''
mutation RequestPasswordReset($phone: String!) {
  requestPasswordReset(phone: $phone) {
    token
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
  final _formKey = GlobalKey<FormState>();
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

  String _subtitle(String languageCode) {
    switch (_step) {
      case 0:
        return switch (languageCode) {
          'ru' => 'Введите номер телефона — отправим SMS с кодом.',
          'en' => 'Enter your phone number — we will send an SMS code.',
          _ => 'Telefon raqamingizni kiriting — SMS kod yuboramiz.',
        };
      case 1:
        return switch (languageCode) {
          'ru' => 'Введите 5-значный код из SMS.',
          'en' => 'Enter the 5-digit code from SMS.',
          _ => 'SMS dagi 5 xonali kodni kiriting.',
        };
      default:
        return switch (languageCode) {
          'ru' => 'Придумайте новый пароль для входа.',
          'en' => 'Choose a new password for sign in.',
          _ => 'Kirish uchun yangi parol o‘ylab toping.',
        };
    }
  }

  String _stepLabel(String languageCode) {
    final n = _step + 1;
    return switch (languageCode) {
      'ru' => 'Шаг $n из 3',
      'en' => 'Step $n of 3',
      _ => '$n / 3 qadam',
    };
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
    if (_loading) return;
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
    final s = S.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = UzbekPhone.normalize(_phone.text);
    if (!UzbekPhone.isComplete(_phone.text)) {
      Toaster.error(s.fieldRequired);
      return;
    }

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
          fallback: s.serverNotWorking,
        );
        return;
      }
      _token = payload['token'].toString();
      setState(() => _step = 1);
    } catch (_) {
      if (mounted) {
        UserFacingErrors.show(
          context,
          presentation: ErrorPresentation.userAction,
          fallback: s.errorGeneric,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToNewPassword() async {
    final s = S.of(context);
    final digits = _code.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 5) {
      Toaster.error(s.confirmationCodeNeedsToBe5Symbols);
      return;
    }
    if (_token.isEmpty) {
      Toaster.error(s.invalidOtpCode);
      setState(() => _step = 0);
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _savePassword() async {
    final s = S.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_password.text.length < 6) {
      Toaster.error(s.passwordLength);
      return;
    }
    if (_password.text != _confirm.text) {
      Toaster.error(s.passwordsDoNotMatch);
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
          fallback: s.serverNotWorking,
        );
        return;
      }
      final lang = Localizations.localeOf(context).languageCode;
      Toaster.success(_doneMessage(lang));
      if (!mounted) return;
      context.pop();
      await AuthCoordinator.instance.clearSession();
    } catch (_) {
      if (mounted) {
        UserFacingErrors.show(
          context,
          presentation: ErrorPresentation.userAction,
          fallback: s.errorGeneric,
        );
      }
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
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rM,
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
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.s,
            AppSpacing.screenPadding,
            AppSpacing.l,
          ),
          children: [
            AuthHeader(
              title: _title(lang),
              subtitle: _subtitle(lang),
              stepLabel: _stepLabel(lang),
              showLogo: false,
              compact: true,
            ),
            if (_step == 0)
              CustomInput(
                controller: _phone,
                type: TextInputType.phone,
                label: s.phone,
                required: true,
                hintText: UzbekPhone.hint,
                autofillHints: const [AutofillHints.telephoneNumber],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_loading) _onPrimary();
                },
                icon: Icon(LucideIcons.phone, color: colors.primary),
              ),
            if (_step == 1)
              AutofillGroup(
                child: Pinput(
                  length: 5,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  controller: _code,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyWith(
                    decoration: pinTheme.decoration?.copyWith(
                      border: Border.all(
                        color: colors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onCompleted: (_) {
                    if (!_loading) _onPrimary();
                  },
                ),
              ),
            if (_step == 2) ...[
              CustomInput(
                controller: _password,
                label: _newPasswordLabel(lang),
                required: true,
                hintText: _newPasswordLabel(lang),
                type: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                icon: Icon(LucideIcons.lock, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              CustomInput(
                controller: _confirm,
                label: '${s.confirm} ${s.password}',
                required: true,
                hintText: '${s.confirm} ${s.password}',
                type: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_loading) _onPrimary();
                },
                icon: Icon(LucideIcons.lock, color: colors.primary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return s.fieldRequired;
                  }
                  if (value != _password.text) {
                    return s.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}
