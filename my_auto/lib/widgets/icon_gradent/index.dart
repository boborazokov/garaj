import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconGradient extends StatelessWidget {
  final int selectedIndex;
  final int currentIndex;
  final String icon;

  const IconGradient({
    super.key,
    required this.selectedIndex,
    required this.currentIndex,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(icon, width: 24, height: 24, color: Colors.grey);
  }
}
