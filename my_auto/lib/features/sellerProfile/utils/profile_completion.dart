import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';
import 'package:my_auto/generated/l10n.dart';

class ProfileCompletionResult {
  final int percent;
  final List<String> missingLabels;

  const ProfileCompletionResult({
    required this.percent,
    required this.missingLabels,
  });
}

ProfileCompletionResult computeProfileCompletion(
  SellerStoreProfile profile,
  S s,
) {
  final checks = <(bool, String)>[
    (profile.image?.trim().isNotEmpty == true, s.missingAvatar),
    (profile.banner?.trim().isNotEmpty == true, s.missingStoreBanner),
    (profile.socialLinks?.hasAny == true, s.missingSocialLinks),
    (profile.locationLabel != null, s.missingLocation),
  ];

  final done = checks.where((c) => c.$1).length;
  final missing = checks.where((c) => !c.$1).map((c) => c.$2).toList();
  final percent = checks.isEmpty ? 0 : ((done / checks.length) * 100).round();

  return ProfileCompletionResult(percent: percent, missingLabels: missing);
}
