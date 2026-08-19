import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

/// Opens coordinates in the device's maps app (Apple Maps, Google Maps, Yandex, etc.).
Future<bool> openLocationInExternalMaps({
  required double latitude,
  required double longitude,
  String? label,
}) async {
  final q = label != null && label.trim().isNotEmpty
      ? Uri.encodeComponent(label.trim())
      : '$latitude,$longitude';

  final uris = <Uri>[
    if (Platform.isIOS)
      Uri.parse('https://maps.apple.com/?ll=$latitude,$longitude&q=$q'),
    Uri.parse('geo:$latitude,$longitude?q=$q'),
    Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    ),
  ];

  for (final uri in uris) {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {
      // try next handler
    }
  }
  return false;
}
