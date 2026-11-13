import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/presentation/shimmer_skeletons.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/advertisement/data/advertisement_repository.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/domain/advertisement_plan_price.dart';
import 'package:my_auto/features/wallet/data/wallet_repository.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/toaster/index.dart';

String _formatUzs(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(' ');
  }
  return '${buf.toString()} UZS';
}

/// Buy a banner: placement → plan → creative → preview → pay from wallet.
class PurchaseAdvertisementScreen extends StatefulWidget {
  const PurchaseAdvertisementScreen({super.key, this.initialSurface});

  final AdSurface? initialSurface;

  @override
  State<PurchaseAdvertisementScreen> createState() =>
      _PurchaseAdvertisementScreenState();
}

class _PurchaseAdvertisementScreenState
    extends State<PurchaseAdvertisementScreen> {
  final _repo = advertisementRepository;
  final _title = TextEditingController();
  final _link = TextEditingController();
  final _picker = ImagePicker();
  final _scroll = ScrollController();

  late AdSurface _surface;
  AdPlan _plan = AdPlan.week;
  List<AdvertisementPlanPrice> _prices = const [];
  AdSlotInfo? _slot;
  File? _imageFile;
  int? _walletTotal;
  bool _loadingMeta = true;
  bool _paying = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _surface = widget.initialSurface ?? AdSurface.brand;
    _loadMeta();
  }

  @override
  void dispose() {
    _title.dispose();
    _link.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMeta() async {
    setState(() => _loadingMeta = true);
    final prices = await _repo.planPrices();
    final slot = await _repo.slotInfo(_surface);
    final wallet = await walletRepository.fetchWallet();
    if (!mounted) return;
    setState(() {
      _prices = prices;
      _slot = slot;
      _walletTotal = wallet?.availableTotal;
      _loadingMeta = false;
    });
  }

  Future<void> _onSurfaceChanged(AdSurface next) async {
    if (next == _surface) return;
    setState(() {
      _surface = next;
      _showPreview = false;
    });
    final slot = await _repo.slotInfo(next);
    if (!mounted) return;
    setState(() => _slot = slot);
  }

  int? get _amount {
    for (final row in _prices) {
      if (row.placement == _surface && row.plan == _plan) return row.amount;
    }
    return null;
  }

  int? amountFor(AdPlan plan) {
    for (final row in _prices) {
      if (row.placement == _surface && row.plan == plan) return row.amount;
    }
    return null;
  }

  String _placementLabel(S s, AdSurface surface) {
    return switch (surface) {
      AdSurface.brand => s.advertisePlacementBrand,
      AdSurface.part => s.advertisePlacementPart,
      AdSurface.service => s.advertisePlacementService,
      AdSurface.announcement => s.advertisePlacementAnnouncement,
      AdSurface.tuning => s.advertisePlacementTuning,
      AdSurface.model => s.advertisePlacementModel,
    };
  }

  String _planLabel(S s, AdPlan plan) {
    return switch (plan) {
      AdPlan.day => s.advertisePlanDay,
      AdPlan.week => s.advertisePlanWeek,
      AdPlan.month => s.advertisePlanMonth,
      AdPlan.quarter => s.advertisePlanQuarter,
    };
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (x == null) return;
    setState(() {
      _imageFile = File(x.path);
      _showPreview = true;
    });
  }

  bool get _formReady {
    return _title.text.trim().isNotEmpty &&
        _link.text.trim().isNotEmpty &&
        _imageFile != null &&
        _amount != null;
  }

  Future<void> _pay() async {
    if (_paying || !_formReady) return;
    if (!_showPreview) {
      setState(() => _showPreview = true);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (_scroll.hasClients) {
        await _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    final amount = _amount!;
    final wallet = _walletTotal ?? 0;
    if (wallet < amount) {
      Toaster.error(S.of(context).walletInsufficientFunds, context: context);
      return;
    }

    setState(() => _paying = true);
    try {
      final key = await _repo.uploadBanner(_imageFile!);
      final ad = await _repo.purchase(
        type: _surface,
        plan: _plan,
        title: _title.text.trim(),
        link: _link.text.trim(),
        bannerImageUrl: key,
      );
      if (!mounted) return;
      final s = S.of(context);
      final msg = ad.status == AdCampaignStatus.queued
          ? s.adPurchaseQueuedSuccess
          : s.adPurchaseLiveSuccess;
      Toaster.success(msg, context: context);
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      Toaster.error(
        GraphqlErrorUi.localizeRaw(context, e.toString()),
        context: context,
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final theme = Theme.of(context);
    final amount = _amount;
    final canPay = _formReady && !_paying;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(s.adPurchaseTitle),
        backgroundColor: colors.surface,
      ),
      body: AppSafeArea(
        top: false,
        child: _loadingMeta
            ? const FormPageSkeleton(fields: 4)
            : ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SectionCard(
                    title: s.adPurchasePlacement,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final surface in AdSurface.values) ...[
                          _SelectTile(
                            selected: _surface == surface,
                            title: _placementLabel(s, surface),
                            onTap: () => _onSurfaceChanged(surface),
                          ),
                          if (surface != AdSurface.values.last)
                            const SizedBox(height: 8),
                        ],
                        if (_slot != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceMuted.withValues(alpha: 0.65),
                              borderRadius: AppRadius.rM,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _slot!.hasFreeSlot
                                      ? LucideIcons.circleCheck
                                      : LucideIcons.listOrdered,
                                  size: 16,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _slot!.hasFreeSlot
                                        ? s.adSlotFree(
                                            '${_slot!.activeCount}',
                                            '${_slot!.maxSlots}',
                                          )
                                        : s.adSlotFull(
                                            '${_slot!.queueLength + 1}',
                                            '${_slot!.maxSlots}',
                                          ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.textMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: s.adPurchasePlan,
                    child: Column(
                      children: [
                        for (final plan in AdPlan.values) ...[
                          _PlanTile(
                            selected: _plan == plan,
                            title: _planLabel(s, plan),
                            price: amountFor(plan),
                            onTap: () => setState(() {
                              _plan = plan;
                              _showPreview = false;
                            }),
                          ),
                          if (plan != AdPlan.values.last)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: s.adPurchaseCreative,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _title,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: s.adPurchaseTitleField,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.rM,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _link,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: s.adPurchaseLinkField,
                            hintText: 'https://…  /product/…',
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.rM,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        Material(
                          color: colors.surfaceMuted.withValues(alpha: 0.45),
                          borderRadius: AppRadius.rL,
                          child: InkWell(
                            onTap: _pickImage,
                            borderRadius: AppRadius.rL,
                            child: Ink(
                              height: 168,
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.rL,
                                border: Border.all(color: colors.border),
                              ),
                              child: _imageFile == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.imagePlus,
                                          size: 28,
                                          color: colors.textMuted,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          s.adPurchasePickImage,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: AppRadius.rL,
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 168,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (_imageFile != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(LucideIcons.refreshCw, size: 16),
                              label: Text(s.adPurchasePickImage),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_showPreview && _imageFile != null) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: s.adPurchasePreview,
                      child: ClipRRect(
                        borderRadius: AppRadius.rL,
                        child: AspectRatio(
                          aspectRatio: 16 / 7,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_imageFile!, fit: BoxFit.cover),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    28,
                                    12,
                                    10,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    _title.text.trim().isEmpty
                                        ? s.adPurchaseTitleField
                                        : _title.text.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'AD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_walletTotal != null || amount != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.rL,
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_walletTotal != null)
                            Text(
                              s.adPurchaseWalletBalance(
                                _formatUzs(_walletTotal!),
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          if (amount != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              s.adPurchaseTotal(_formatUzs(amount)),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: Material(
        color: colors.surface,
        elevation: 8,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: canPay ? _pay : null,
                child: _paying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _showPreview && _formReady
                            ? s.adPurchasePayCta
                            : s.adPurchasePreviewCta,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : colors.surfaceMuted.withValues(alpha: 0.35),
      borderRadius: AppRadius.rM,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rM,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rM,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Icon(
                selected ? LucideIcons.circleCheck : LucideIcons.circle,
                size: 18,
                color: selected ? colors.primary : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.selected,
    required this.title,
    required this.price,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final int? price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : colors.surfaceMuted.withValues(alpha: 0.35),
      borderRadius: AppRadius.rM,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rM,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rM,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (price != null)
                Text(
                  _formatUzs(price!),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? colors.primary : colors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
