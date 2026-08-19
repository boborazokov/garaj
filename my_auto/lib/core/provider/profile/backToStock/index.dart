import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/profile/screens/my_products/api/index.dart';

class RestorePart extends ChangeNotifier {
  bool _backToStock = false;
  bool isLoading = false;
  bool get backToStock => _backToStock;
  set backToStock(bool value) {
    _backToStock = value;
    notifyListeners();
  }

  Future<void> restorePartById(String id, BuildContext context,
      {VoidCallback? onDeleted}) async {
    try {
      isLoading = true;
      notifyListeners();

      final MutationOptions options = MutationOptions(
        document: gql(RESTORE_PART_BY_ID),
        variables: {"partId": id},
      );

      final result = await GraphQLConfig.client().mutate(options);

      if (result.data != null && result.data!['restorePartById'] != null) {
        if (onDeleted != null) onDeleted();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
