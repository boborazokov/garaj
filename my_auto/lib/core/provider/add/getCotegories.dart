import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/features/add/api/index.dart';

enum type { PART, SERVICE, ANNOUNCMENT, TUNING }

class GetCategories extends ChangeNotifier {
  List<CategoryCar> categories = [];
  bool isLoading = false;

  void addCategory(CategoryCar category) {
    categories.add(category);
    notifyListeners();
  }

  Future loadCategories(String type) async {
    isLoading = true;
    notifyListeners();

    final QueryOptions options = QueryOptions(
      document: gql(GET_CATEGORIES),
      variables: {
        "filter": {"type": type}
      },
    );
    try {
      final result = await GraphQLConfig.client().query(options);
      if (result.data != null && result.data!['getCategories'] != null) {
        final data = result.data!['getCategories'] as List<dynamic>;
        categories = data
            .map((e) => CategoryCar.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
