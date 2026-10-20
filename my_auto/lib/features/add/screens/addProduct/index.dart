import 'package:flutter/material.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/add/addPartProvider.dart';
import 'package:my_auto/features/add/screens/addProduct/widgets/form/index.dart';
import 'package:my_auto/features/add/screens/addProduct/widgets/pulish/index.dart';
import 'package:my_auto/features/add/screens/addProduct/widgets/stepProgress/index.dart';
import 'package:my_auto/features/add/screens/uploudImage/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class AddProductWizard extends StatefulWidget {
  final Part? existingPart;

  const AddProductWizard({super.key, this.existingPart});

  @override
  State<AddProductWizard> createState() => _AddProductWizardState();
}

class _AddProductWizardState extends State<AddProductWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AddPartProvider>();

      if (widget.existingPart != null) {
        provider.fillFromPart(widget.existingPart!);
        if (widget.existingPart!.images?.isNotEmpty ?? false) {
          provider.addNetworkImages(widget.existingPart!.images!);
        }
      } else {
        // Do not wipe draft on hot-reload / rebuild mid-wizard — that sent
        // null `name` to createPart and crashed dispose(context.read(...)).
        final hasDraft = provider.title != null ||
            provider.categoryId != null ||
            (provider.description != null &&
                provider.description!.trim().isNotEmpty) ||
            provider.images.isNotEmpty ||
            provider.networkImages.isNotEmpty ||
            provider.id != null;
        if (!hasDraft) {
          provider.reset();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddPartProvider>();
    final isEdit = provider.id != null;

    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 1) {
          setState(() => _currentStep--);
          _pageController.animateToPage(
            _currentStep - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? S.of(context).edit : S.of(context).addProduct),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 1) {
                setState(() => _currentStep--);
                _pageController.animateToPage(
                  _currentStep - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                provider.reset();
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: AppSafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              StepProgressBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepLabels: [
                  S.of(context).details,
                  S.of(context).photos,
                  isEdit ? S.of(context).update : S.of(context).publish,
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    FormPart(onNext: _nextStep),
                    UploadImage(onNext: _nextStep),
                    PublishScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
