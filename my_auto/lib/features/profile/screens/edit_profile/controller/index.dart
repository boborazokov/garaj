import 'package:flutter/material.dart';
import 'package:my_auto/core/constants/uzbekistan_regions.dart';
import 'package:my_auto/core/map/geo_location.dart';

class EditProfileController {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final descriptionController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();

  UzbekistanRegion? selectedRegion;
  GeoLocation? mapPoint;
  final telegramController = TextEditingController();
  final instagramController = TextEditingController();
  final websiteController = TextEditingController();
  final youtubeController = TextEditingController();
  final facebookController = TextEditingController();

  bool showPhone = false;
  bool showEmail = false;
  bool showLocation = true;
  bool showFollowers = true;
  bool allowMessages = true;

  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    locationController.dispose();
    telegramController.dispose();
    instagramController.dispose();
    websiteController.dispose();
    youtubeController.dispose();
    facebookController.dispose();
  }
}
