import 'package:flutter/material.dart';
import 'package:my_auto/features/home/widgets/home_top_bar.dart';

/// Home screen top bar (logo, greeting, favorites, messages, notifications).
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTopBar();
  }
}
