import 'package:flutter/material.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/setFavorite/index.dart';
import 'package:provider/provider.dart';

/// Loads favorite ids after sign-in and clears them on sign-out.
class FavoritesAuthListener extends StatefulWidget {
  const FavoritesAuthListener({super.key, required this.child});

  final Widget child;

  @override
  State<FavoritesAuthListener> createState() => _FavoritesAuthListenerState();
}

class _FavoritesAuthListenerState extends State<FavoritesAuthListener> {
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _wasAuthenticated = auth.isAuthenticated;
    if (_wasAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavorites());
    }
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    await context.read<SetFavoriteProvider>().loadFavoritesFromServer();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAuth = auth.isAuthenticated;

    if (isAuth && !_wasAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavorites());
    } else if (!isAuth && _wasAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SetFavoriteProvider>().clear();
      });
    }
    _wasAuthenticated = isAuth;

    return widget.child;
  }
}
