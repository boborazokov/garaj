import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/home/api/index.dart';

class GetProductById extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  Part? product;

  void clearProduct() {
    product = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadProductById(String id) async {
    if (id.trim().isEmpty) {
      errorMessage = 'Invalid product id';
      product = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final options = QueryOptions(
      document: gql(GET_PRODUCT_BY_ID),
      variables: {'partId': id.trim()},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final result = await GraphQLConfig.client().query(options);

      if (result.hasException) {
        final gqlErr = result.exception?.graphqlErrors.firstOrNull;
        errorMessage = gqlErr?.extensions?['code']?.toString() ??
            gqlErr?.message ??
            result.exception.toString();
        product = null;
        if (kDebugMode) {
          debugPrint('[GetProductById] $id: ${result.exception}');
        }
        return;
      }

      final raw = result.data?['getPartById'];
      if (raw is! Map) {
        errorMessage = 'Product not found';
        product = null;
        return;
      }

      product = Part.fromJson(Map<String, dynamic>.from(raw));
      errorMessage = null;
    } catch (e, st) {
      errorMessage = e.toString();
      product = null;
      if (kDebugMode) debugPrint('[GetProductById] parse $id: $e\n$st');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
