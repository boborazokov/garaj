import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/model/workshop/index.dart';

const String GET_WORKSHOPS = r'''
  query GetWorkshops($pagination: PaginationInput!, $search: String, $filter: WorkshopFilterInput) {
    getWorkshops(pagination: $pagination, search: $search, filter: $filter) {
      payload {
        _id
        activeUntil
        address
        createdAt
        images
        location
        openFrom
        openUntil
        status
        name
      }
      page
      nextPage
      limit
      hasNextPage
      hasPrevPage
      prevPage
      totalDocs
      totalPages
    }
  }
''';

Map<String, dynamic> buildFilter({
  String? owner,
  bool? isOpen,
}) {
  final filter = <String, dynamic>{};
  if (owner != null && owner.isNotEmpty) filter['owner'] = owner;
  if (isOpen != null) filter['isOpen'] = isOpen;
  return filter;
}

Map<String, dynamic> buildPagination({
  int? page,
  int? limit,
}) {
  return {
    'page': page ?? 1,
    'limit': limit ?? 10,
  };
}

class GetWorkshop extends ChangeNotifier {
  final int limit;
  GetWorkshop({this.limit = 10});

  final Map<String, List<Workshop>> _workshopsMap = {};
  final Map<String, int> _currentPageMap = {};
  final Map<String, bool> _hasMoreMap = {};
  final Map<String, bool> _isLoadingMap = {};

  String _key(Map<String, dynamic>? filters, String? search) {
    final parts = <String>[];
    if (filters != null && filters.isNotEmpty) {
      parts.addAll(filters.entries.map((e) => '${e.key}:${e.value}'));
    }
    if (search != null && search.isNotEmpty) {
      parts.add('search:$search');
    }
    return parts.isEmpty ? 'all' : parts.join('|');
  }

  List<Workshop> getWorkshops(Map<String, dynamic>? filters, String? search) {
    return _workshopsMap[_key(filters, search)] ?? [];
  }

  bool isLoadingFor(Map<String, dynamic>? filters, String? search) {
    return _isLoadingMap[_key(filters, search)] ?? false;
  }

  bool hasMoreFor(Map<String, dynamic>? filters, String? search) {
    return _hasMoreMap[_key(filters, search)] ?? true;
  }

  Future<void> loadList({
    Map<String, dynamic>? filters,
    bool reset = true,
    String? search,
  }) async {
    final key = _key(filters, search);

    if (_isLoadingMap[key] == true) return;

    if (reset) {
      _currentPageMap[key] = 1;
      _hasMoreMap[key] = true;
      _workshopsMap[key] = [];
    }

    if (_hasMoreMap[key] == false) return;

    _isLoadingMap[key] = true;
    notifyListeners();

    try {
      final page = _currentPageMap[key] ?? 1;

      final QueryOptions options = QueryOptions(
        document: gql(GET_WORKSHOPS),
        variables: {
          "pagination": buildPagination(page: page, limit: limit),
          "filter": buildFilter(
            owner: filters?['owner'],
            isOpen: filters?['isOpen'],
          ),
          "search": search,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await GraphQLConfig.client().query(options);

      final workshopsData = result.data?['getWorkshops']?['payload'];
      final totalPages = result.data?['getWorkshops']?['totalPages'];

      if (workshopsData is List && workshopsData.isNotEmpty) {
        final newWorkshops = workshopsData
            .map((e) => Workshop.fromJson(e as Map<String, dynamic>))
            .where((w) =>
                !(_workshopsMap[key]?.any((existing) => existing.id == w.id) ??
                    false))
            .toList();

        _workshopsMap[key] = [...?_workshopsMap[key], ...newWorkshops];

        _currentPageMap[key] = page + 1;
        if (_currentPageMap[key]! > (totalPages ?? 1)) {
          _hasMoreMap[key] = false;
        }
      } else {
        _hasMoreMap[key] = false;
      }
    } finally {
      _isLoadingMap[key] = false;
      notifyListeners();
    }
  }

  void removeWorkshopLocally(
    String workshopId, {
    Map<String, dynamic>? filters,
    String? search,
  }) {
    final key = _key(filters, search);
    final list = _workshopsMap[key];
    if (list == null) return;
    _workshopsMap[key] =
        list.where((w) => w.id != workshopId).toList(growable: false);
    notifyListeners();
  }
}
