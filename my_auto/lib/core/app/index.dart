import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/provider/theme/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/provider/language/index.dart';
import 'package:my_auto/core/routes/app_router.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/l10n/locale_resolution.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = PartShopTheme.light.copyWith(
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppPalette.primary500,
        barBackgroundColor: AppPalette.white,
      ),
    );

    final darkTheme = PartShopTheme.dark.copyWith(
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppPalette.primary400,
        barBackgroundColor: AppPalette.carbon800,
      ),
    );

    return GraphQLProvider(
      client: GraphQLConfig.graphqlClient(),
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Garage',
        theme: lightTheme,
        themeMode: themeProvider.themeMode,
        darkTheme: darkTheme,
        routerConfig: appRouter,
        locale: localeNotifier.locale,
        localeResolutionCallback: (deviceLocale, supportedLocales) =>
            resolveAppLocale(
          localeNotifier.locale ?? deviceLocale,
          supportedLocales,
        ),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
    );
  }
}
