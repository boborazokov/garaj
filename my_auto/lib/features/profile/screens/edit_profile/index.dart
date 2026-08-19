import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/constants/uzbekistan_regions.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/utils/geocoder.dart';
import 'package:my_auto/core/provider/profile/updateProfile/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/local_image.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
import 'package:my_auto/features/add/widgets/customDropdown/index.dart';
import 'package:my_auto/features/profile/screens/edit_profile/controller/index.dart';
import 'package:my_auto/features/profile/widgets/delete_account/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/button/index.dart';
import 'package:my_auto/widgets/image_cache/index.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  XFile? _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<UpdateProfileProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      provider.controller.nameController.text = auth.auth?.user.name ?? '';
      provider.loadProfile(context);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      if (kDebugMode) {
        final kb = (await pickedFile.length()) / 1024;
        debugPrint(
          '[ProfileUpload] picked image ${pickedFile.path} '
          '(${kb.toStringAsFixed(1)} KB)',
        );
      }
      setState(() => _imageFile = pickedFile);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickLocationOnMap() async {
    final c = context.read<UpdateProfileProvider>().controller;
    final result = await context.push<GeoLocation?>(
      RoutesName.map,
      extra: c.mapPoint,
    );
    if (result == null || !mounted) return;

    final address = await GeocodeService.getAddressFromGeo(result);
    setState(() {
      c.mapPoint = result;
      c.locationController.text = address ??
          '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context).gallery),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(S.of(context).camera),
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpdateProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final colors = context.appColors;
    final s = S.of(context);
    final c = provider.controller;
    final avatarUrl = _imageFile != null
        ? null
        : resolveMediaUrl(auth.auth?.user.image, mediaBase: fileUrl);

    final saving = provider.isLoading;

    return Stack(
      children: [
        Scaffold(
      appBar: AppBar(title: Text(s.editProfile)),
      body: provider.isFetching
          ? const Center(child: CircularProgressIndicator.adaptive())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewCard(controller: c, avatarFile: _imageFile, avatarUrl: avatarUrl),
                  const SizedBox(height: 20),
                  Text(s.sellerDashboardPreview,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipOval(
                          child: _imageFile != null
                              ? localImage(
                                  _imageFile!.path,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : avatarUrl != null
                                  ? ImageCacheNetwork(
                                      url: auth.auth!.user.image!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: colors.surface,
                                      child: Icon(
                                        LucideIcons.user,
                                        color: colors.textMuted,
                                        size: 40,
                                      ),
                                    ),
                        ),
                        InkWell(
                          onTap: _showImagePickerOptions,
                          child: CircleAvatar(
                            backgroundColor: colors.primary,
                            radius: 18,
                            child: Icon(Icons.camera_alt,
                                size: 18, color: colors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(s.aboutSection,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  CustomInput(
                    controller: c.nameController,
                    hintText: s.name,
                    type: TextInputType.text,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.usernameController,
                    hintText: s.username,
                    type: TextInputType.text,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.bioController,
                    hintText: s.bio,
                    isTextarea: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.descriptionController,
                    hintText: s.description,
                    isTextarea: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Text(s.contactInformation,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  CustomInput(
                    controller: c.emailController,
                    hintText: s.emailAddress,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Text(s.location,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  CustomDropdownField<UzbekistanRegion>(
                    items: uzbekistanRegions,
                    hint: s.region,
                    value: c.selectedRegion,
                    onChanged: (val) => setState(() => c.selectedRegion = val),
                    getLabel: (val) => uzbekistanRegionLabel(s, val),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.locationController,
                    hintText: s.chooseLocationOnMap,
                    readOnly: true,
                    required: false,
                    onTap: _pickLocationOnMap,
                    suffix: Icon(
                      LucideIcons.mapPin,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.showLocationPublicly),
                    value: c.showLocation,
                    onChanged: (v) => setState(() => c.showLocation = v),
                  ),
                  const SizedBox(height: 12),
                  Text(s.sellerSocialLinks,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  CustomInput(
                    controller: c.telegramController,
                    hintText: 'Telegram URL',
                    type: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.instagramController,
                    hintText: 'Instagram URL',
                    type: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.websiteController,
                    hintText: 'Website URL',
                    type: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.youtubeController,
                    hintText: 'YouTube URL',
                    type: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: c.facebookController,
                    hintText: 'Facebook URL',
                    type: TextInputType.url,
                  ),
                  const SizedBox(height: 20),
                  Text(s.privacySettings,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.showPhoneNumber),
                    value: c.showPhone,
                    onChanged: (v) => setState(() => c.showPhone = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.showEmail),
                    value: c.showEmail,
                    onChanged: (v) => setState(() => c.showEmail = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.showFollowersCount),
                    value: c.showFollowers,
                    onChanged: (v) => setState(() => c.showFollowers = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.allowMessages),
                    value: c.allowMessages,
                    onChanged: (v) => setState(() => c.allowMessages = v),
                  ),
                  const SizedBox(height: 28),
                  _DangerZoneCard(
                    onDeleteAccount: () => deleteAccount(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: BottomSafeButton(
        child: Button(
          title: s.saveChanges,
          isLoading: saving,
          onTap: saving
              ? null
              : () async {
                  try {
                    if (kDebugMode) {
                      debugPrint(
                        '[ProfileUpload] save tapped hasImage=${_imageFile != null}',
                      );
                    }
                    final updated = await provider.updateProfile(
                      context,
                      imageFile: _imageFile,
                    );
                    if (!context.mounted) return;
                    if (updated != null) {
                      setState(() => _imageFile = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.productUpdatedSuccessfully)),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.errorOccurred)),
                      );
                    }
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.errorOccurred)),
                    );
                  }
                },
        ),
      ),
        ),
        if (saving)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadius.rL,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator.adaptive(),
                      const SizedBox(height: 16),
                      Text(
                        _imageFile != null ? s.upload : s.saveChanges,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final EditProfileController controller;
  final XFile? avatarFile;
  final String? avatarUrl;

  const _PreviewCard({
    required this.controller,
    this.avatarFile,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final name = controller.nameController.text.trim().isEmpty
        ? '—'
        : controller.nameController.text.trim();
    final username = controller.usernameController.text.trim();
    final bio = controller.bioController.text.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: avatarFile != null
                ? localImage(
                    avatarFile!.path,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : avatarUrl != null
                    ? ImageCacheNetwork(url: avatarUrl!, width: 56, height: 56)
                    : Container(
                        width: 56,
                        height: 56,
                        color: colors.primary.withValues(alpha: 0.15),
                        child: Icon(LucideIcons.user, color: colors.primary),
                      ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                if (username.isNotEmpty)
                  Text(s.sellerAtUsername(username),
                      style: TextStyle(color: colors.textMuted, fontSize: 13)),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(bio,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Destructive section that lives at the bottom of the edit-profile form.
/// Keeps the irreversible "Delete account" action close to the user's data so
/// it is discoverable when they are editing it, yet visually fenced off so it
/// can never be tapped by accident.
class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({required this.onDeleteAccount});

  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.06),
        borderRadius: AppRadius.rL,
        border: Border.all(color: colors.danger.withValues(alpha: 0.32)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.alertTriangle,
                  size: 18, color: colors.danger),
              const SizedBox(width: 8),
              Text(
                s.profileSectionAccount,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.deleteAccountSubtitle,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDeleteAccount,
              icon: const Icon(LucideIcons.userX, size: 18),
              label: Text(s.deleteAccount),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.danger,
                side: BorderSide(color: colors.danger),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
