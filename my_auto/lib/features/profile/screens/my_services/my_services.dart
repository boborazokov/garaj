import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/workshop/getWorkshop/index.dart';
import 'package:my_auto/features/profile/widgets/my_listings_scaffold.dart';
import 'package:my_auto/features/profile/widgets/my_workshop_card/index.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';

class MyServices extends StatefulWidget {
  const MyServices({super.key});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  final _scrollControllerActive = ScrollController();
  final _scrollControllerInactive = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _currentSearch;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _load(reset: true));

    _scrollControllerActive.addListener(_onScrollActive);
    _scrollControllerInactive.addListener(_onScrollInactive);
  }

  Map<String, dynamic> get _filters => {
        'owner': context.read<AuthProvider>().auth!.user.id,
      };

  void _load({required bool reset}) {
    context.read<GetWorkshop>().loadList(
          reset: reset,
          filters: _filters,
          search: _currentSearch,
        );
  }

  void _onScrollActive() => _maybeLoadMore(_scrollControllerActive);
  void _onScrollInactive() => _maybeLoadMore(_scrollControllerInactive);

  void _maybeLoadMore(ScrollController controller) {
    final provider = context.read<GetWorkshop>();
    if (controller.position.pixels >=
            controller.position.maxScrollExtent - 200 &&
        !provider.isLoadingFor(_filters, _currentSearch) &&
        provider.hasMoreFor(_filters, _currentSearch)) {
      provider.loadList(
        reset: false,
        filters: _filters,
        search: _currentSearch,
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollControllerActive.dispose();
    _scrollControllerInactive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetWorkshop>();
    final s = S.of(context);
    final workshops = provider.getWorkshops(_filters, _currentSearch);
    final isLoading =
        provider.isLoadingFor(_filters, _currentSearch) && workshops.isEmpty;
    final isMoreLoading = provider.hasMoreFor(_filters, _currentSearch);

    final active = workshops.where((w) => w.status == 'ACTIVE').toList();
    final inactive = workshops.where((w) => w.status == 'ARCHIVED').toList();

    return MyListingsScaffold(
      title: s.myServices,
      activeCount: active.length,
      inactiveCount: inactive.length,
      searchController: _searchController,
      onSearch: (val) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 350), () {
          setState(() => _currentSearch = val.trim().isEmpty ? null : val.trim());
          _load(reset: true);
        });
      },
      isLoading: isLoading,
      onRefresh: () async => _load(reset: true),
      activeBody: active.isEmpty
          ? MyListingsEmptyState(
              message: s.noServices,
              icon: LucideIcons.wrench,
            )
          : _workshopList(
              active,
              _scrollControllerActive,
              isMoreLoading,
              isDepleted: false,
            ),
      inactiveBody: inactive.isEmpty
          ? MyListingsEmptyState(
              message: s.myListingsEmptyInactive,
              icon: LucideIcons.archive,
            )
          : _workshopList(
              inactive,
              _scrollControllerInactive,
              isMoreLoading,
              isDepleted: true,
            ),
    );
  }

  Widget _workshopList(
    List workshops,
    ScrollController controller,
    bool isMoreLoading, {
    required bool isDepleted,
  }) {
    return ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: workshops.length + (isMoreLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= workshops.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        final workshop = workshops[index];
        return MyWorkshopCard(
          workshop: workshop,
          isMine: true,
          isDepleted: isDepleted,
          ownerFilters: _filters,
          search: _currentSearch,
        );
      },
    );
  }
}
