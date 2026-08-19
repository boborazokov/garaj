import 'package:flutter/material.dart';
import 'package:my_auto/core/map/geo_location.dart';

class ServicesController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedLocation = TextEditingController();
  final timeOpeningController = TextEditingController();
  final closeTimeController = TextEditingController();
  GeoLocation? selectedPoint;

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    selectedLocation.dispose();
    timeOpeningController.dispose();
    closeTimeController.dispose();
    selectedPoint = null;
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;
  void clearForm() {
    formKey.currentState?.reset();
    titleController.clear();
    descriptionController.clear();
    selectedLocation.clear();
    timeOpeningController.clear();
    closeTimeController.clear();
    selectedPoint = null;
  }
}
