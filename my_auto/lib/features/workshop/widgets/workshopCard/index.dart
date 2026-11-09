import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Workshop grid card — photo, title, open status, hours · place.
class WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  const WorkshopCard({super.key, required this.workshop});

  bool _isOpenNow() {
    final now = DateTime.now();
    final from = workshop.openFrom;
    final until = workshop.openUntil;
    if (from == null || until == null) return false;
    final fromMinutes = from.hour * 60 + from.minute;
    final untilMinutes = until.hour * 60 + until.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    if (untilMinutes >= fromMinutes) {
      return nowMinutes >= fromMinutes && nowMinutes <= untilMinutes;
    }
    return nowMinutes >= fromMinutes || nowMinutes <= untilMinutes;
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '—';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final s = S.of(context);
    final isOpen = _isOpenNow();
    final imageUrl =
        workshop.images.isNotEmpty ? workshop.images.first : null;
    final title = (workshop.title ?? '').trim().isEmpty
        ? s.services
        : workshop.title!.trim();
    final place = workshop.displayPlace;
    final hasPlace = place.isNotEmpty && place != '—';
    final hours =
        '${_formatTime(workshop.openFrom)} – ${_formatTime(workshop.openUntil)}';

    return MarketCardShell(
      onTap: () => context.push(
        '${RoutesName.workshopDetailScreen}/${workshop.id}',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: colors.surfaceMuted,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ImageCacheNetwork(
                          url: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          LucideIcons.wrench,
                          size: 36,
                          color: colors.textMuted,
                        ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: MarketBadgeChip(
                    label: isOpen
                        ? s.workshopStatusOpen
                        : s.workshopStatusClosed,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOpen
                      ? '${s.workshopStatusOpen} · $hours'
                      : '${s.workshopStatusClosed} · $hours',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOpen ? colors.success : colors.textMuted,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 12,
                      color: hasPlace
                          ? colors.textMuted
                          : colors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hasPlace ? place : s.region,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
