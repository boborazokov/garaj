import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/provider/theme/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/profile/widgets/action_type/index.dart';
import 'package:my_auto/features/profile/widgets/guest_card/index.dart';
import 'package:my_auto/features/profile/widgets/language_select/index.dart';
import 'package:my_auto/features/profile/widgets/logout/index.dart';
import 'package:my_auto/features/profile/widgets/userCard/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _protectedTap(
    BuildContext context, {
    required PendingAction pending,
    required VoidCallback onAuthed,
  }) async {
    final alreadyAuthed = AuthGuard.isAuthenticated(context);
    final ok = await AuthGuard.requireAuth(context, pending: pending);
    if (!ok || !context.mounted) return;
    if (!AuthGuard.isAuthenticated(context)) return;
    // Fresh login already replayed [pending]; only navigate if already signed in.
    if (alreadyAuthed) onAuthed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = context.watch<AuthProvider>();
    final s = S.of(context);
    final isGuest = auth.isGuest;

    return Scaffold(
      backgroundColor: colors.background,
      body: AppSafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            listPaddingAboveBottomNav(context, navBarHeight: 120),
          ),
          children: [
            if (isGuest) const GuestProfileCard() else const UserCard(),
            const SizedBox(height: 24),
            ActionCard(
              title: s.profileSectionMyActivity,
              items: [
                ProfileItem(
                  iconPath: const Icon(LucideIcons.package),
                  title: s.myProducts,
                  subtitle: s.profileSubtitleMyProducts,
                  onTap: () => _protectedTap(
                    context,
                    pending: const PendingRoute(path: RoutesName.myProducts),
                    onAuthed: () => context.push(RoutesName.myProducts),
                  ),
                ),
                ProfileItem(
                  iconPath: const Icon(LucideIcons.clipboardList),
                  title: s.myOrders,
                  subtitle: s.profileSubtitleMyOrders,
                  onTap: () => _protectedTap(
                    context,
                    pending: const PendingRoute(path: RoutesName.myOrders),
                    onAuthed: () => context.push(RoutesName.myOrders),
                  ),
                ),
                ProfileItem(
                  iconPath: const Icon(LucideIcons.wrench),
                  title: s.myServices,
                  subtitle: s.profileSubtitleMyServices,
                  onTap: () => _protectedTap(
                    context,
                    pending: const PendingRoute(path: RoutesName.myServices),
                    onAuthed: () => context.push(RoutesName.myServices),
                  ),
                ),
                ProfileItem(
                  iconPath: const Icon(LucideIcons.heart),
                  title: s.favorites,
                  onTap: () => _protectedTap(
                    context,
                    pending: const PendingRoute(path: RoutesName.favorites),
                    onAuthed: () => context.push(RoutesName.favorites),
                  ),
                ),
                ProfileItem(
                  iconPath: const Icon(LucideIcons.messageCircle),
                  title: s.messages,
                  subtitle: s.profileSubtitleMessages,
                  onTap: () => _protectedTap(
                    context,
                    pending: const PendingRoute(path: RoutesName.chats),
                    onAuthed: () => context.push(RoutesName.chats),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ActionCard(
              title: s.profileSectionPreferences,
              items: [
                ProfileItem(
                  iconPath: const Icon(LucideIcons.languages),
                  title: s.language,
                  trailing: Consumer<LocaleNotifier>(
                    builder: (context, localeNotifier, _) {
                      return Text(
                        getLanguageFlag(
                          localeNotifier.locale?.languageCode ??
                              Localizations.localeOf(context).languageCode,
                        ),
                        style: const TextStyle(fontSize: 22),
                      );
                    },
                  ),
                  onTap: () => selectLanguage(context),
                ),
                ProfileItem(
                  iconPath: Icon(
                    themeProvider.isDarkMode
                        ? LucideIcons.moon
                        : LucideIcons.sun,
                  ),
                  title: s.darkTheme,
                  trailing: CupertinoSwitch(
                    activeTrackColor: colors.primary,
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ActionCard(
              title: s.profileSectionSupport,
              items: [
                ProfileItem(
                  iconPath: const Icon(LucideIcons.mail),
                  title: s.contactUs,
                  onTap: () => context.push(RoutesName.contactUs),
                ),
                ProfileItem(
                  iconPath: const Icon(LucideIcons.shieldCheck),
                  title: s.privacyPolicy,
                  onTap: () => context.push(RoutesName.privacyPolicy),
                ),
              ],
            ),
            if (!isGuest) ...[
              const SizedBox(height: 24),
              ActionCard(
                title: s.profileSectionAccount,
                items: [
                  ProfileItem(
                    iconPath: const Icon(LucideIcons.logOut),
                    title: s.logout,
                    trailing: const SizedBox.shrink(),
                    onTap: () => logOut(context),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
