import 'package:flutter/material.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/orders/presentation/screens/orders_screen.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/app_bar.dart';
import 'package:provider/provider.dart';

/// "My requests" – wraps [OrdersListScreen] with the current user's id as
/// the author filter so only their own announcements are shown.
class MyOrders extends StatelessWidget {
  const MyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final userId = context.watch<AuthProvider>().auth?.user.id;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopBar(title: s.myRequests),
      body: OrdersScreen(authorId: userId),
    );
  }
}
