import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/profile/updateProfile/index.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/utils/local_image.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => AppSafeArea(
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
