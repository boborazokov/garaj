import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/model/workshop/index.dart';
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
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _currentSearch;
  MyListingsStatusFilter _status = MyListingsStatusFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _load(reset: true));
    _scrollController.addListener(_onScroll);
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

  void _onScroll() {
    final provider = context.read<GetWorkshop>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
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
    _scrollController.dispose();
    super.dispose();
  }

  bool _isActive(Workshop w) => w.status == 'ACTIVE';

  bool _isInactive(Workshop w) =>
      w.status == 'ARCHIVED' || w.status == 'INACTIVE';

  List<Workshop> _applyStatus(List<Workshop> workshops) {
    switch (_status) {
      case MyListingsStatusFilter.all:
        return workshops;
      case MyListingsStatusFilter.active:
        return workshops.where(_isActive).toList();
      case MyListingsStatusFilter.inactive:
        return workshops.where(_isInactive).toList();
    }
  }

  String _emptyMessage(S s, String? query) {
    if (query != null && query.isNotEmpty) return s.searchHubNoGroupedHits;
    switch (_status) {
      case MyListingsStatusFilter.all:
      case MyListingsStatusFilter.active:
        return s.noServices;
      case MyListingsStatusFilter.inactive:
        return s.myListingsEmptyInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetWorkshop>();
    final s = S.of(context);
    final workshops = provider.getWorkshops(_filters, _currentSearch);
    final isLoading =
        provider.isLoadingFor(_filters, _currentSearch) && workshops.isEmpty;
    final isMoreLoading = provider.hasMoreFor(_filters, _currentSearch);

    final activeCount = workshops.where(_isActive).length;
    final inactiveCount = workshops.where(_isInactive).length;
    final visible = _applyStatus(workshops);
    final query = _currentSearch;

    return MyListingsScaffold(
      title: s.myServices,
      activeCount: activeCount,
      inactiveCount: inactiveCount,
      searchController: _searchController,
      searchHint: s.search,
      onSearch: (val) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 280), () {
          if (!mounted) return;
          setState(
            () => _currentSearch = val.trim().isEmpty ? null : val.trim(),
          );
          _load(reset: true);
        });
      },
      showSummary: false,
      isLoading: isLoading,
      onRefresh: () async => _load(reset: true),
      belowSearch: MyListingsStatusFilters(
        selected: _status,
        allCount: workshops.length,
        activeCount: activeCount,
        inactiveCount: inactiveCount,
        onSelected: (value) => setState(() => _status = value),
      ),
      body: visible.isEmpty
          ? MyListingsEmptyState(
              message: _emptyMessage(s, query),
              icon: query != null && query.isNotEmpty
                  ? LucideIcons.searchX
                  : LucideIcons.wrench,
            )
          : ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: visible.length + (isMoreLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= visible.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                final workshop = visible[index];
                return MyWorkshopCard(
                  workshop: workshop,
                  isMine: true,
                  isDepleted: _isInactive(workshop),
                  ownerFilters: _filters,
                  search: _currentSearch,
                );
              },
            ),
    );
  }
}
