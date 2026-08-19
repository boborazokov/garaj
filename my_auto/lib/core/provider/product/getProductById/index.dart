import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/home/api/index.dart';

class GetProductById extends ChangeNotifier {
  bool isLoading = false;
  Part? product;

  void clearProduct() {
    product = null;
    notifyListeners();
  }

  Future loadProductById(String id) async {
    isLoading = true;
    notifyListeners();

    final QueryOptions options = QueryOptions(
      document: gql(GET_PRODUCT_BY_ID),
      variables: {"partId": id},
    );

    try {
      final result = await GraphQLConfig.client().query(options);

      if (result.data != null && result.data!['getPartById'] != null) {
        product =
            Part.fromJson(result.data!['getPartById'] as Map<String, dynamic>);
        notifyListeners();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
