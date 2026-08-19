import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Placeholder for the enriched order / announcement editor (budget, urgency,
/// voice note, statuses). Prefer extending [CreateOrderWizardScreen] with these
/// fields once GraphQL supports them.
class EditOrderAnnouncementPlaceholderScreen extends StatelessWidget {
  const EditOrderAnnouncementPlaceholderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Edit request')),
      body: AppSafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order / announcement id: $orderId', style: TextStyle(color: colors.textMuted)),
              const SizedBox(height: 12),
              const Text(
                'Phase 2: urgency, budget range, deadlines, attachments, workshop recommendations.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
