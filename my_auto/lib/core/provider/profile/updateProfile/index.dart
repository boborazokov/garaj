import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/constants/uzbekistan_regions.dart';
import 'package:my_auto/core/model/user/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/services/graphql/graphql_multipart.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/profile/screens/edit_profile/api/index.dart';
import 'package:my_auto/features/profile/screens/edit_profile/controller/index.dart';
import 'package:my_auto/features/sellerProfile/api/seller_profile_api.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class UpdateProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isFetching = false;
  final controller = EditProfileController();

  Future<void> loadProfile(BuildContext context) async {
    isFetching = true;
    notifyListeners();
    try {
      final result = await GraphQLConfig.client().query(
        QueryOptions(
          document: gql(GET_PROFILE),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException || result.data?['getProfile'] == null) return;
      final user = User.fromJson(
        Map<String, dynamic>.from(result.data!['getProfile'] as Map),
      );
      _applyUser(user);
      if (context.mounted) {
        context.read<AuthProvider>().setUser(user);
      }
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  void _applyUser(User user) {
    controller.nameController.text = user.name;
    controller.usernameController.text = user.username ?? '';
    controller.bioController.text = user.bio ?? '';
    controller.descriptionController.text = user.description ?? '';
    controller.emailController.text = user.email ?? '';
    controller.selectedRegion = uzbekistanRegionFromStored(user.region);
    controller.locationController.text =
        user.address ?? user.city ?? user.region ?? '';
    controller.mapPoint = null;
    final links = user.socialLinks ?? {};
    controller.telegramController.text = links['telegram'] ?? '';
    controller.instagramController.text = links['instagram'] ?? '';
    controller.websiteController.text = links['website'] ?? '';
    controller.youtubeController.text = links['youtube'] ?? '';
    controller.facebookController.text = links['facebook'] ?? '';
    final privacy = user.privacy ?? {};
    controller.showPhone = privacy['showPhone'] == true;
    controller.showEmail = privacy['showEmail'] == true;
    controller.showLocation = privacy['showLocation'] != false;
    controller.showFollowers = privacy['showFollowers'] != false;
    controller.allowMessages = privacy['allowMessages'] != false;
  }

  Future<User?> updateProfile(
    BuildContext context, {
    XFile? imageFile,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final c = controller;
    final s = S.of(context);
    final regionLabel = c.selectedRegion == null
        ? ''
        : uzbekistanRegionLabel(s, c.selectedRegion!);
    final address = c.locationController.text.trim();

    final data = <String, dynamic>{
      'name': c.nameController.text.trim(),
      'username': c.usernameController.text.trim(),
      'bio': c.bioController.text.trim(),
      'description': c.descriptionController.text.trim(),
      'email': c.emailController.text.trim(),
      'country': 'Uzbekistan',
      'region': regionLabel,
      'city': regionLabel,
      'address': address,
      'socialLinks': {
        'telegram': c.telegramController.text.trim(),
        'instagram': c.instagramController.text.trim(),
        'website': c.websiteController.text.trim(),
        'youtube': c.youtubeController.text.trim(),
        'facebook': c.facebookController.text.trim(),
      },
      'privacy': {
        'showPhone': c.showPhone,
        'showEmail': c.showEmail,
        'showLocation': c.showLocation,
        'showFollowers': c.showFollowers,
        'allowMessages': c.allowMessages,
      },
    };

    try {
      isLoading = true;
      notifyListeners();

      Map<String, dynamic>? payload;

      if (imageFile != null) {
        if (kDebugMode) {
          final originalBytes = await imageFile.length();
          debugPrint(
            '[ProfileUpload] start original='
            '${(originalBytes / 1024).toStringAsFixed(1)} KB',
          );
        }
        payload = await GraphQLMultipart.mutate(
          operationName: 'Mutation',
          query: UPDATE_PROFILE,
          variables: {'data': data},
          files: {'image': imageFile},
        );
      } else {
        final result = await GraphQLConfig.client().mutate(
          MutationOptions(
            document: gql(UPDATE_PROFILE),
            variables: {'data': data},
          ),
        );
        if (result.hasException) return null;
        payload = result.data;
      }

      if (payload?['updateProfile'] != null) {
        final updatedUser = User.fromJson(
          Map<String, dynamic>.from(payload!['updateProfile'] as Map),
        );
        if (kDebugMode) {
          debugPrint(
            '[ProfileUpload] profile saved image=${updatedUser.image}',
          );
        }
        authProvider.setUser(updatedUser);
        return updatedUser;
      }
      if (kDebugMode && imageFile != null) {
        debugPrint('[ProfileUpload] failed: empty updateProfile payload');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ProfileUpload] exception: $e');
        debugPrint('$st');
      }
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
