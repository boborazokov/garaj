import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/phoneFormater.dart';
import 'package:my_auto/features/auth/presentation/providers/sign_in_provider.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().clearOrphanBearerIfGuest();
    });
  }

  void _submit() {
    context.read<SignInProvider>().signIn(context);
  }

  String _forgotLabel(String languageCode) {
    return switch (languageCode) {
      'ru' => 'Забыли пароль?',
      'en' => 'Forgot password?',
      _ => 'Parolni unutdingizmi?',
    };
  }

  String _subtitle(String languageCode) {
    return switch (languageCode) {
      'ru' => 'Телефон и пароль — и вы в магазине запчастей.',
      'en' => 'Phone and password — then browse parts.',
      _ => 'Telefon va parol — ehtiyot qismlar bozoriga kiring.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>();
    final controller = provider.controller;
    final s = S.of(context);
    final colors = context.appColors;
    final lang = Localizations.localeOf(context).languageCode;

    return AutofillGroup(
      child: AuthScaffold(
        isLoading: provider.isLoading,
        primaryLabel: s.signIn,
        onPrimary: _submit,
        footer: AuthFooterLink(
          prompt: s.noAccount,
          actionLabel: s.signUp,
          onTap: () => context.push(RoutesName.signup),
        ),
        body: Form(
          key: controller.formKey,
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
                title: s.logIn,
                subtitle: _subtitle(lang),
              ),
              CustomInput(
                controller: controller.phoneController,
                focusNode: controller.phoneFocus,
                type: TextInputType.phone,
                label: s.phone,
                required: true,
                hintText: UzbekPhone.hint,
                autofillHints: const [AutofillHints.telephoneNumber],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(controller.passwordFocus);
                },
                icon: Icon(LucideIcons.phone, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              CustomInput(
                controller: controller.passwordController,
                focusNode: controller.passwordFocus,
                label: s.password,
                required: true,
                hintText: s.password,
                type: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  TextInput.finishAutofillContext();
                  _submit();
                },
                icon: Icon(LucideIcons.lock, color: colors.primary),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push(RoutesName.resetPassword),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 44),
                    foregroundColor: colors.primary,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _forgotLabel(lang),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
