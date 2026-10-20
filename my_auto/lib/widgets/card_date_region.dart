import 'package:flutter/material.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/utils/place_label.dart';

/// Card footer: date on the left, selected viloyat on the right.
class CardDateRegion extends StatelessWidget {
  const CardDateRegion({
    super.key,
    required this.createdAt,
    this.region,
    this.fontSize = 11,
  });

  final DateTime createdAt;
  final String? region;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).languageCode;
    final date = cardPostedLabel(createdAt, languageCode: locale);
    final place = regionOnlyLabel(region);
    final style = TextStyle(
      color: colors.textMuted,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );

    return Row(
      children: [
        Flexible(
          child: Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (place.isNotEmpty) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: style,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
