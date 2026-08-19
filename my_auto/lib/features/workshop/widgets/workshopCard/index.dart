import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';

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
    final isOpen = _isOpenNow();
    final imageUrl =
        workshop.images.isNotEmpty ? workshop.images.first : null;

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rL,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          '${RoutesName.workshopDetailScreen}/${workshop.id}',
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.rL,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: colors.surfaceMuted,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? ImageCacheNetwork(url: imageUrl)
                          : Icon(LucideIcons.wrench,
                              size: 36, color: colors.textMuted),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _StatusPill(
                        isOpen: isOpen,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Text(
                        workshop.title ?? "Workshop",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.clock,
                            size: 14, color: colors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${_formatTime(workshop.openFrom)} – ${_formatTime(workshop.openUntil)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin,
                            size: 14, color: colors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            workshop.location ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textMuted,
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
    final color = isOpen ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? s.workshopStatusOpen : s.workshopStatusClosed,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
