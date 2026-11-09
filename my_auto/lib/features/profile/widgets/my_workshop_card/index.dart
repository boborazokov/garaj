import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/workshop/getWorkshop/index.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/place_label.dart';
import 'package:my_auto/features/home/presentation/market_ui.dart';
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

  Future<void> _reloadOwnerList() async {
    final auth = context.read<AuthProvider>();
    final ownerId = auth.auth?.user.id;
    if (ownerId == null) return;
    await context.read<GetWorkshop>().loadList(
          reset: true,
          filters: {'owner': ownerId},
          search: widget.search,
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.appColors;
    final theme = Theme.of(context);
    final imageUrl =
        widget.workshop.images.isNotEmpty ? widget.workshop.images.first : null;
    final place = widget.workshop.displayPlace;
    final hours =
        '${_formatTime(widget.workshop.openFrom)} – ${_formatTime(widget.workshop.openUntil)}';

    final lang = Localizations.localeOf(context).languageCode;
    final until = widget.workshop.activeUntil != null
        ? DateTime.tryParse(widget.workshop.activeUntil!)
        : null;
    final statusLabel = widget.isDepleted
        ? s.depleted
        : (until != null
            ? s.availableUntil(
                cardPostedLabel(until, languageCode: lang),
              )
            : s.active);

    void openDetail() => context.push(
          '${RoutesName.workshopDetailScreen}/${widget.workshop.id}',
        );

    return MarketCardShell(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.s,
        AppSpacing.screenPadding,
        0,
      ),
      onTap: openDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.rM,
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: ColoredBox(
                      color: colors.surfaceMuted,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? ImageCacheNetwork(url: imageUrl)
                          : Icon(
                              LucideIcons.wrench,
                              size: 28,
                              color: colors.textMuted,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workshop.title ?? s.workshopUntitled,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyListingStatusChip(
                        label: statusLabel,
                        isActive: !widget.isDepleted,
                      ),
                      const SizedBox(height: 8),
                      _MetaRow(icon: LucideIcons.clock, text: hours),
                      if (place.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _MetaRow(icon: LucideIcons.mapPin, text: place),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.isMine) ...[
            Divider(height: 1, color: colors.divider),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.isDepleted) ...[
                    MyListingPromoteButton(
                      label: s.promotionManage,
                      isActive: true,
                      onTap: _deleting
                          ? null
                          : () async {
                              await showPromoteWorkshopByIdSheet(
                                context,
                                workshopId: widget.workshop.id,
                                title: widget.workshop.title ??
                                    s.workshopUntitled,
                              );
                              if (!mounted) return;
                              await _reloadOwnerList();
                            },
                    ),
                    const SizedBox(height: AppSpacing.s),
                  ],
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
                                await _reloadOwnerList();
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
              ),
            ),
          ],
        ],
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
