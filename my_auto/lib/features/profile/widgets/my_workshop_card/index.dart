import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/workshop/getWorkshop/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/promotion/presentation/promote_workshop_sheet.dart';
import 'package:my_auto/features/profile/widgets/my_listing_card_helpers.dart';
import 'package:my_auto/features/workshop/data/workshops_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';

class MyWorkshopCard extends StatefulWidget {
  const MyWorkshopCard({
    super.key,
    required this.workshop,
    this.isMine = false,
    this.isDepleted = false,
    this.ownerFilters,
    this.search,
  });

  final Workshop workshop;
  final bool isMine;
  final bool isDepleted;
  final Map<String, dynamic>? ownerFilters;
  final String? search;

  @override
  State<MyWorkshopCard> createState() => _MyWorkshopCardState();
}

class _MyWorkshopCardState extends State<MyWorkshopCard> {
  bool _deleting = false;

  String _formatTime(DateTime? d) {
    if (d == null) return '—';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _confirmDelete() async {
    final s = S.of(context);
    final colors = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteWorkshopTitle),
        content: Text(s.areYouSureToDeleteWorkshop),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.no),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.yes),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await workshopsRepository.deleteWorkshop(widget.workshop.id);
      if (!mounted) return;
      context.read<GetWorkshop>().removeWorkshopLocally(
            widget.workshop.id,
            filters: widget.ownerFilters,
            search: widget.search,
          );
      Toaster.success(s.workshopDeleted);
    } catch (_) {
      if (mounted) Toaster.error(s.errorOccurred);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    final theme = Theme.of(context);
    final imageUrl =
        widget.workshop.images.isNotEmpty ? widget.workshop.images.first : null;

    final statusLabel = widget.isDepleted
        ? s.depleted
        : (widget.workshop.activeUntil != null
            ? s.availableUntil(
                DateFormat('d MMMM')
                    .format(DateTime.parse(widget.workshop.activeUntil!)),
              )
            : s.availableUntil('—'));

    void openDetail() => context.push(
          '${RoutesName.workshopDetailScreen}/${widget.workshop.id}',
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.s,
        AppSpacing.screenPadding,
        0,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openDetail,
          child: Ink(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.rL,
              border: Border.all(color: colors.border),
              boxShadow: AppShadows.card(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 2.1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: colors.surfaceMuted,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ImageCacheNetwork(url: imageUrl)
                            : Icon(
                                LucideIcons.wrench,
                                size: 40,
                                color: colors.textMuted,
                              ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: MyListingStatusChip(
                          label: statusLabel,
                          isActive: !widget.isDepleted,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Text(
                          widget.workshop.title ?? s.workshopUntitled,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
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
                      _MetaRow(
                        icon: LucideIcons.clock,
                        text:
                            '${_formatTime(widget.workshop.openFrom)} – ${_formatTime(widget.workshop.openUntil)}',
                      ),
                      if (widget.workshop.location != null) ...[
                        const SizedBox(height: 6),
                        _MetaRow(
                          icon: LucideIcons.mapPin,
                          text: widget.workshop.location!,
                        ),
                      ],
                      if (widget.isMine) ...[
                        const SizedBox(height: AppSpacing.m),
                        MyListingPromoteButton(
                          label: s.promotedTop,
                          onTap: _deleting
                              ? null
                              : () async {
                                  await showPromoteWorkshopByIdSheet(
                                    context,
                                    workshopId: widget.workshop.id,
                                    title:
                                        widget.workshop.title ?? s.workshopUntitled,
                                  );
                                },
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Row(
                          children: [
                            MyListingActionButton(
                              icon: LucideIcons.pencil,
                              label: s.edit,
                              color: colors.primary,
                              onTap: _deleting
                                  ? null
                                  : () async {
                                      final updated = await context.push<bool>(
                                        '${RoutesName.editWorkshop}/${widget.workshop.id}',
                                      );
                                      if (!mounted || updated != true) return;
                                      final auth = context.read<AuthProvider>();
                                      final ownerId = auth.auth?.user.id;
                                      if (ownerId == null) return;
                                      context.read<GetWorkshop>().loadList(
                                            reset: true,
                                            filters: {'owner': ownerId},
                                            search: widget.search,
                                          );
                                    },
                            ),
                            const SizedBox(width: AppSpacing.s),
                            MyListingActionButton(
                              icon: LucideIcons.trash2,
                              label: s.delete,
                              color: colors.danger,
                              isLoading: _deleting,
                              onTap: _deleting ? null : _confirmDelete,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 14, color: colors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
