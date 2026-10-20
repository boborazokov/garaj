import 'package:flutter/material.dart';

import 'app_safe_area.dart';
import 'keyboard_safe_view.dart';

/// Opinionated scaffold: keyboard-safe body + optional top safe inset.
///
/// Set [applyTopSafeArea] to false when the body already uses [SliverAppBar],
/// [SafeArea] in headers, or an [AppBar] that should extend under the status bar.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.applyTopSafeArea = true,
    this.applyKeyboardPadding = true,
    this.extendBody = false,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool applyTopSafeArea;
  final bool applyKeyboardPadding;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (applyKeyboardPadding) {
      content = KeyboardSafeView(child: content);
    }
    // AppBar already accounts for the status bar — only pad body when none.
    final padTop = applyTopSafeArea && appBar == null;
    if (padTop) {
      content = AppSafeArea(
        top: true,
        bottom: false,
        left: false,
        right: false,
        child: content,
      );
    }

    return Scaffold(
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
