import 'package:my_auto/core/provider/add/addPartProvider.dart';

import 'package:my_auto/core/provider/add/createWorkshop.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/features/auth/auth_providers.dart';
import 'package:my_auto/core/provider/home/getProductById/index.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/provider/orders/orders_provider.dart';
import 'package:my_auto/core/provider/profile/backToStock/index.dart';
import 'package:my_auto/core/provider/profile/removePartsById/index.dart';
import 'package:my_auto/core/provider/profile/updateProfile/index.dart';
import 'package:my_auto/core/provider/theme/index.dart';
import 'package:my_auto/core/provider/workshop/getWorkshop/index.dart';
import 'package:my_auto/core/provider/workshop/getworkshpsById/index.dart';
import 'package:my_auto/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  // AuthProvider — один экземпляр в `main.dart` (`ChangeNotifierProvider.value`).
  ...authProviders,
  ChangeNotifierProvider(create: (_) => GetCategories()),
  ChangeNotifierProvider(create: (_) => SetFavoriteProvider()),
  ChangeNotifierProvider(
    create: (ctx) {
      final hub = ProductProvider();
      hub.onProductsLoaded = (parts) {
        ctx.read<SetFavoriteProvider>().applyFromParts(parts);
      };
      return hub;
    },
  ),
  ChangeNotifierProvider(create: (_) => GetProductById()),
  ChangeNotifierProvider(create: (_) => RestorePart()),
  ChangeNotifierProvider(create: (_) => RemovePartsByIdProvider()),
  ChangeNotifierProvider(
    create: (_) => LocaleNotifier()..loadLocale(),
  ),
  ChangeNotifierProvider(create: (_) => UpdateProfileProvider()),
  ChangeNotifierProvider(create: (_) => CreateWorkshopProvider()),
  ChangeNotifierProvider(create: (_) => GetWorkshop()),
  ChangeNotifierProvider(create: (_) => GetWorkshopById()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(
    create: (_) => AddPartProvider(),
  ),
  ChangeNotifierProvider(create: (_) => OrdersProvider()),
  ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
];
