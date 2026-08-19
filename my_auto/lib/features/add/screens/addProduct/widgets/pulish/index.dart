import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/utils/app_network_image.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/core/layout/layout.dart';
import 'package:my_auto/widgets/button/index.dart';
import 'package:my_auto/widgets/toaster/index.dart';
import 'package:provider/provider.dart';
import 'package:my_auto/core/provider/add/addPartProvider.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({
    super.key,
  });

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddPartProvider>();
    final isEdit = provider.id != null;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.colorScheme.surface,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 280,
            child: PageView.builder(
              itemCount:
                  provider.allImages.isNotEmpty ? provider.allImages.length : 1,
              itemBuilder: (_, i) {
                if (provider.allImages.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 80, color: Colors.grey),
                    ),
                  );
                }

                final imageItem = provider.allImages[i];
                final imagePath = imageItem is String
                    ? imageItem
                    : (imageItem is File ? imageItem.path : null);

                if (imagePath == null || imagePath.isEmpty) {
                  return const Center(
                    child: Icon(Icons.broken_image_outlined,
                        size: 60, color: Colors.grey),
                  );
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(path: imagePath, fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${i + 1}/${provider.allImages.length}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.title ?? "Untitled Product",
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.categoriesName ?? "No category selected",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${provider.price} ${provider.currency}",
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      provider.negotiable
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                S.of(context).negotiable,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade300),
                  _buildInfoRow(
                      Icons.inventory_2_outlined,
                      S.of(context).condition,
                      provider.condition == "true"
                          ? S.of(context).newPart
                          : S.of(context).used,
                      theme),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                      Icons.local_shipping_outlined,
                      S.of(context).delivery,
                      getDeliveryStatus(
                          getDeliveryType(provider.delivery) ?? "ds"),
                      theme),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300),
                  Text(
                    S.of(context).description,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      provider.description?.isNotEmpty == true
                          ? provider.description!
                          : "No description provided.",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomSafeButton(
        child: Button(
          title: isEdit ? S.of(context).save : S.of(context).publishProduct,
          onTap: () async {
            final success = await provider.savePart();
            if (!context.mounted) return;
            if (success) {
              provider.reset();
              Toaster.success(isEdit
                  ? S.of(context).productUpdatedSuccessfully
                  : S.of(context).productSuccessfullyPublished);
              context.pop(true);
            } else {
              Toaster.error(S.of(context).errorOccurred);
            }
          },
          isLoading: provider.isLoading,
          icon: isEdit ? Icons.save_outlined : Icons.cloud_upload_outlined,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ],
    );
  }
}
