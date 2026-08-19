import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/tokens.dart';
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
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>();
    final controller = provider.controller;
    final s = S.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return AuthScaffold(
      isLoading: provider.isLoading,
      primaryLabel: s.createAccount,
      onPrimary: () {
        if (controller.validateForm()) {
          provider.signUp(context);
        }
      },
      body: Form(
        key: controller.formKey,
        child: ListView(
          controller: controller.scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          children: [
            AuthHeader(title: s.createAccount),
            CustomInput(
              controller: controller.nameController,
              focusNode: controller.nameFocus,
              label: s.name,
              required: true,
              hintText: s.name,
              type: TextInputType.name,
              icon: Icon(LucideIcons.user, color: primary),
            ),
            const SizedBox(height: AppSpacing.l),
            CustomInput(
              controller: controller.phoneController,
              focusNode: controller.phoneFocus,
              label: s.phone,
              required: true,
              hintText: s.phone,
              type: TextInputType.phone,
              icon: Icon(LucideIcons.phone, color: primary),
            ),
            const SizedBox(height: AppSpacing.l),
            CustomInput(
              controller: controller.passwordController,
              focusNode: controller.passwordFocus,
              label: s.password,
              required: true,
              hintText: s.password,
              type: TextInputType.visiblePassword,
              icon: Icon(LucideIcons.lock, color: primary),
            ),
            const SizedBox(height: AppSpacing.l),
            CustomInput(
              controller: controller.confirmPasswordController,
              label: '${s.confirm} ${s.password}',
              required: true,
              hintText: '${s.confirm} ${s.password}',
              type: TextInputType.visiblePassword,
              icon: Icon(LucideIcons.keyRound, color: primary),
              validator: (value) {
                if (value == null || value.isEmpty) return s.fieldRequired;
                if (value != controller.passwordController.text) {
                  return s.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            AuthFooterLink(
              prompt: s.alreadyHaveAccount,
              actionLabel: s.signIn,
              onTap: () => context.go(RoutesName.signin),
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}
