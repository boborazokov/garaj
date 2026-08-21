import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>();
    final controller = provider.controller;
    final s = S.of(context);

    return AuthScaffold(
      isLoading: provider.isLoading,
      primaryLabel: s.signIn,
      onPrimary: () {
        if (controller.validateForm()) {
          provider.signIn(context);
        }
      },
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(title: s.logIn),
              CustomInput(
                controller: controller.phoneController,
                focusNode: controller.phoneFocus,
                type: TextInputType.phone,
                label: s.phone,
                required: true,
                hintText: s.phone,
                icon: Icon(LucideIcons.phone, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.l),
              CustomInput(
                controller: controller.passwordController,
                focusNode: controller.passwordFocus,
                label: s.password,
                required: true,
                hintText: s.password,
                type: TextInputType.visiblePassword,
                icon: Icon(LucideIcons.lock, color: Theme.of(context).colorScheme.primary),
              ),
              AuthFooterLink(
                prompt: s.noAccount,
                actionLabel: s.signUp,
                onTap: () => context.push(RoutesName.signup),
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}
