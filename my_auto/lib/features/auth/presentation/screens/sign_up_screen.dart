import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/phoneFormater.dart';
import 'package:my_auto/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_auto/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  void _submit() {
    context.read<SignUpProvider>().signUp(context);
  }

  String _subtitle(String languageCode) {
    return switch (languageCode) {
      'ru' => 'Продавайте запчасти, пишите продавцам, сохраняйте избранное.',
      'en' => 'Sell parts, message sellers, and save favorites.',
      _ => 'Ehtiyot qism sotish, yozishish va sevimlilarni saqlash.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>();
    final controller = provider.controller;
    final s = S.of(context);
    final colors = context.appColors;
    final lang = Localizations.localeOf(context).languageCode;

    return AutofillGroup(
      child: AuthScaffold(
        isLoading: provider.isLoading,
        primaryLabel: s.createAccount,
        onPrimary: _submit,
        footer: AuthFooterLink(
          prompt: s.alreadyHaveAccount,
          actionLabel: s.signIn,
          onTap: () => context.go(RoutesName.signin),
        ),
        body: Form(
          key: controller.formKey,
          child: ListView(
            controller: controller.scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.s,
              AppSpacing.screenPadding,
              AppSpacing.l,
            ),
            children: [
              AuthHeader(
                title: s.createAccount,
                subtitle: _subtitle(lang),
                compact: true,
              ),
              CustomInput(
                controller: controller.nameController,
                focusNode: controller.nameFocus,
                label: s.name,
                required: true,
                hintText: s.name,
                type: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(controller.phoneFocus);
                },
                icon: Icon(LucideIcons.user, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              CustomInput(
                controller: controller.phoneController,
                focusNode: controller.phoneFocus,
                label: s.phone,
                required: true,
                hintText: UzbekPhone.hint,
                type: TextInputType.phone,
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
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                icon: Icon(LucideIcons.lock, color: colors.primary),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  left: AppSpacing.xs,
                  bottom: AppSpacing.m,
                ),
                child: Text(
                  s.passwordLength,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
              ),
              CustomInput(
                controller: controller.confirmPasswordController,
                label: '${s.confirm} ${s.password}',
                required: true,
                hintText: '${s.confirm} ${s.password}',
                type: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  TextInput.finishAutofillContext();
                  _submit();
                },
                icon: Icon(LucideIcons.keyRound, color: colors.primary),
                validator: (value) {
                  if (value == null || value.isEmpty) return s.fieldRequired;
                  if (value != controller.passwordController.text) {
                    return s.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              // Extra space so last field can scroll fully above the docked CTA.
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }
}
