import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

/// Clear workshop card — photo, title, open status, hours · place.
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rL,
        boxShadow: MarketUi.softElev(context),
        border: Border.all(color: colors.border.withValues(alpha: 0.55)),
      ),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
                      child: _StatusPill(isOpen: isOpen),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontSize: 14.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isOpen
                          ? '${s.workshopStatusOpen} · $hours'
                          : '${s.workshopStatusClosed} · $hours',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isOpen ? colors.success : colors.textMuted,
                        fontSize: 11.5,
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
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 11.5,
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
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isOpen;
  const _StatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final bg = isOpen ? colors.success : colors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOpen ? s.workshopStatusOpen : s.workshopStatusClosed,
        style: TextStyle(
          color: colors.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
