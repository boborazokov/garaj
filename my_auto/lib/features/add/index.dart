import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/add/widgets/card/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';

class Add extends StatelessWidget {
  const Add({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.whatDoYouWantSell),
      body: AppSafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            SellCard(
              title: s.parts,
              subtitle: 'Spare parts & accessories',
              icon: LucideIcons.cog,
              image: 'assets/images/parts.png',
              gradient: [colors.primary, colors.primaryHover],
              onTap: () => context.push(RoutesName.addProduct),
              animationDelay: 50,
            ),
            const SizedBox(height: 14),
            SellCard(
              title: s.service,
              subtitle: 'Workshops & services',
              icon: LucideIcons.wrench,
              image: 'assets/images/service.png',
              gradient: const [Color(0xFF1F2937), Color(0xFF0B0F14)],
              onTap: () => context.push(RoutesName.createWorkshop),
              animationDelay: 150,
            ),
            const SizedBox(height: 14),
            SellCard(
              title: s.announcements,
              subtitle: s.createRequestSubtitle,
              icon: LucideIcons.megaphone,
              image: 'assets/images/announcements.png',
              gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
              onTap: () => context.push(RoutesName.createOrder),
              animationDelay: 250,
            ),
          ],
        ),
      ),
    );
  }
}
