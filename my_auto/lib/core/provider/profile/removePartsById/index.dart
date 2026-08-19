import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/profile/screens/my_products/api/index.dart';

class RemovePartsByIdProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<void> removePartsById(String id, BuildContext context,
      {VoidCallback? onDeleted}) async {
    try {
      isLoading = true;
      notifyListeners();

      final MutationOptions options = MutationOptions(
        document: gql(deletePartById),
        variables: {"partId": id},
      );

      final result = await GraphQLConfig.client().mutate(options);

      if (result.data != null && result.data!['deletePartById'] != null) {
        if (onDeleted != null) onDeleted();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
