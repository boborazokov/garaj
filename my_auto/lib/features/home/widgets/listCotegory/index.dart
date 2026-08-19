import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/routes/name.dart';

class CustomCategoryLayout extends StatelessWidget {
  const CustomCategoryLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"name": "Service", "image": "assets/images/serviceHome.png"},
      {"name": "Parts", "image": "assets/images/partsHome.png"},
      {"name": "Announcements", "image": "assets/images/announcementsHome.png"},
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CategoryItem(
                      name: categories[0]["name"]!,
                      imagePath: categories[0]["image"]!,
                    ),
                    const SizedBox(height: 10),
                    CategoryItem(
                      name: categories[2]["name"]!,
                      imagePath: categories[2]["image"]!,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CategoryItem(
                  fullWidth: true,
                  name: categories[1]["name"]!,
                  imagePath: categories[1]["image"]!,
                  height: 240,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String name;
  final String imagePath;
  final double height;
  final bool fullWidth;

  const CategoryItem({
    super.key,
    required this.name,
    required this.imagePath,
    this.height = 100,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => {context.push(RoutesName.categoriesScreen, extra: name)},
          child: Container(
            height: height,
            width: fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).secondaryHeaderColor,
            ),
            clipBehavior: Clip.none,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(fullWidth ? 10 : 0, -10),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: height + 40,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
