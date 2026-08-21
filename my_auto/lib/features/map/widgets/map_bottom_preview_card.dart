import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/features/map/domain/map_geo.dart';
import 'package:my_auto/features/map/domain/map_open_status.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';
import 'package:my_auto/features/workshop/data/models/workshop_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class MapBottomPreviewCard extends StatelessWidget {
  const MapBottomPreviewCard({
    super.key,
    required this.pin,
    required this.workshop,
    required this.colors,
    required this.userLocation,
    required this.onClose,
    required this.onOpen,
    required this.onNavigate,
    required this.onCall,
    required this.onShare,
  });

  final MapPin pin;
  final WorkshopProfile? workshop;
  final AppColors colors;
  final LatLng? userLocation;
  final VoidCallback onClose;
  final VoidCallback onOpen;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final accent = switch (pin.kind) {
      MapPinKind.service => colors.primary,
      MapPinKind.emergency => colors.danger,
      MapPinKind.workshop => const Color(0xFF7C3AED),
      MapPinKind.product => colors.success,
      MapPinKind.order => colors.warning,
    };

    double? km;
    if (userLocation != null) {
      km = haversineKm(
        userLocation!,
        LatLng(pin.latitude, pin.longitude),
      );
    }

    final drive = km != null ? roughDriveEta(km) : null;
    final openLine =
        workshop != null ? workshopOpenStatusLine(workshop!) : null;

    final servicesPreview = workshop != null &&
            workshop!.categories.length > 1
        ? workshop!.categories.take(3).map((c) => c.name).join(' · ')
        : pin.categoryNames.take(4).join(' · ');
    final ratingLine = pin.rating > 0 ? pin.rating.toStringAsFixed(1) : '—';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: colors.border.withValues(alpha: 0.45)),
            boxShadow: AppShadows.floating(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onOpen,
                        borderRadius: AppRadius.rL,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.rL,
                              child: (pin.coverImage != null &&
                                      pin.coverImage!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: pin.coverImage!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          _placeholder(accent, pin),
                                    )
                                  : _placeholder(accent, pin),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (pin.verified)
                              _badge('VERIFIED', colors.info),
                            if (pin.premium) _badge('PREMIUM', const Color(0xFFD4AF37)),
                            if (pin.fastResponse && pin.kind == MapPinKind.workshop)
                              _badge('FAST', colors.primary),
                            if (pin.open24Hours)
                              _badge('24/7', colors.success),
                            if ((workshop?.rating ?? pin.rating) >= 4.5 &&
                                workshop != null &&
                                workshop!.reviewCount >= 8)
                              _badge('TOP RATED', accent),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pin.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.star,
                                  size: 13,
                                  color: colors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ratingLine,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (km != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.navigation2,
                                    size: 13,
                                    color: colors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDistanceKm(km),
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (drive != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '~${drive.inMinutes} min',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                        if (openLine != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            openLine,
                            style: TextStyle(
                              color: pin.isOpenNow || pin.open24Hours
                                  ? colors.success
                                  : colors.warning,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if ((pin.pricePreview ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            pin.pricePreview!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                        if (servicesPreview.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            servicesPreview,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
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
                  IconButton(
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                    icon:
                        Icon(LucideIcons.x, color: colors.textMuted, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.rL,
                        ),
                      ),
                      icon: const Icon(LucideIcons.arrowUpRight, size: 18),
                      label: const Text('Open'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: colors.success.withValues(alpha: 0.15),
                      foregroundColor: colors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.rL,
                      ),
                    ),
                    icon: Icon(LucideIcons.phoneCall, color: colors.success),
                    onPressed:
                        pin.phone != null ? onCall : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Route',
                    onPressed: onNavigate,
                    icon: Icon(LucideIcons.navigation,
                        color: colors.primary),
                  ),
                  IconButton(
                    tooltip: 'Share',
                    onPressed: onShare,
                    icon: Icon(LucideIcons.share2, color: colors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: c,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _placeholder(Color accent, MapPin p) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          accent,
          accent.withValues(alpha: 0.75),
        ]),
        borderRadius: AppRadius.rL,
      ),
      child: Icon(
        LucideIcons.mapPin,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

Future<void> launchPhone(String? raw) async {
  if (raw == null || raw.trim().isEmpty) return;
  final uri = Uri(scheme: 'tel', path: raw);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> sharePin(MapPin pin) async {
  final url =
      'https://www.google.com/maps/search/?api=1&query=${pin.latitude},${pin.longitude}';
  await SharePlus.instance.share(ShareParams(text: '${pin.title}\n$url'));
}
