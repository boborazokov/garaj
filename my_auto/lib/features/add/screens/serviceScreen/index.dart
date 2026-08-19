import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/provider/add/createWorkshop.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/utils/geocoder.dart';
import 'package:my_auto/features/add/controllers/Services/index.dart';
import 'package:my_auto/features/add/screens/serviceScreen/widgets/timeInput/index.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/widgets/button/index.dart';
import 'package:my_auto/widgets/input/index.dart';
import 'package:provider/provider.dart';
import 'package:my_auto/core/map/geo_location.dart';

class Service extends StatefulWidget {
  const Service({super.key, this.id});
  final String? id;

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  late ServicesController controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    controller = ServicesController();

    /// если id передан → значит update
    if (widget.id != null) {
      _loadWorkshopData(widget.id!);
    }
  }

  Future<void> _loadWorkshopData(String id) async {
    context.read<CreateWorkshopProvider>();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!controller.validateForm()) return;

    setState(() => _loading = true);
    final provider = context.read<CreateWorkshopProvider>();

    try {
      if (widget.id == null) {
        /// CREATE
        final id = await provider.createWorkshop(
          name: controller.titleController.text.trim(),
          location: controller.selectedLocation.text.trim(),
          timeRange: controller.timeOpeningController.text.trim(),
          images: [],
        );

        if (id != null && mounted) {
          context.push(RoutesName.uploadImage, extra: id);
        }
      } else {
        /// UPDATE
        final success = await provider.updateWorkshop(
          workshopId: widget.id!,
          name: controller.titleController.text.trim(),
          location: controller.selectedLocation.text.trim(),
          timeRange: controller.timeOpeningController.text.trim(),
        );

        if (success && mounted) {
          Navigator.pop(context, true);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateWorkshopProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null
            ? S.of(context).addService
            : S.of(context).editService),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Text(S.of(context).titleOfServices,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.titleController,
                hintText: S.of(context).exampleTittleParts,
                validator: (val) =>
                    val == null || val.isEmpty ? S.of(context).required : null,
              ),
              const SizedBox(height: 16),
              Text(S.of(context).address,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              CustomInput(
                hintText: S.of(context).chooseLocation,
                controller: controller.selectedLocation,
                readOnly: true,
                onTap: () async {
                  final result = await context.push(
                    RoutesName.map,
                    extra: controller.selectedPoint,
                  );

                  if (result != null && result is GeoLocation) {
                    controller.selectedPoint = result;
                    final address =
                        await GeocodeService.getAddressFromGeo(result);
                    controller.selectedLocation.text = address ??
                        '${result.latitude}, ${result.longitude}';
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(S.of(context).description,
                  style: Theme.of(context).textTheme.titleSmall),
              CustomInput(
                isTextarea: true,
                controller: controller.descriptionController,
                validator: (val) =>
                    val == null || val.isEmpty ? S.of(context).required : null,
              ),
              const SizedBox(height: 16),
              Text(S.of(context).workingTime,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TimeInput(
                labelText: S.of(context).timeExample,
                controller: controller.timeOpeningController,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomSafeButton(
        child: Button(
          isLoading: provider.isLoading || _loading,
          title: widget.id == null ? S.of(context).add : S.of(context).save,
          onTap: _handleSubmit,
        ),
      ),
    );
  }
}
