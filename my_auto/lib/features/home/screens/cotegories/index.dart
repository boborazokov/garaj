import 'package:flutter/material.dart';
import 'package:my_auto/core/provider/add/getCotegories.dart';
import 'package:my_auto/features/home/widgets/gridCotegory/index.dart';
import 'package:my_auto/features/home/widgets/slider/index.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.title});
  final String title;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<GetCategories>().loadCategories(type.PART.name));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetCategories>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const SliderHome(),
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading && provider.categories.isEmpty
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : GridCategories(
                        listCategory: provider.categories,
                        showAll: true,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
