import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Placeholder for the redesigned workshop profile editor (services, hours,
/// gallery reorder, badges). Wire from [RoutesName.workshopDetailScreen]
/// edit action once design + API parity are approved.
class EditWorkshopPlaceholderScreen extends StatelessWidget {
  const EditWorkshopPlaceholderScreen({super.key, required this.workshopId});

  final String workshopId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Edit workshop')),
      body: const AppSafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workshop editor (phase 2)\n• Business profile sections\n• Service catalog & toggles\n• Gallery reorder & hours',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
