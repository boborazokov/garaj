import 'package:flutter/material.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/common/section_header.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      actionLabel: onSeeAll == null ? null : S.of(context).seeAll,
      onAction: onSeeAll,
    );
  }
}
