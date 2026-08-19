import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:my_auto/features/add/api/index.dart';

class GetWorkshopById extends ChangeNotifier {
  bool isLoading = false;
  Workshop? workshop;

  Future<void> loadWorkshopById(String id) async {
    isLoading = true;
    notifyListeners();

    final QueryOptions options = QueryOptions(
      document: gql(GET_WORKSHOP_BY_ID),
      variables: {"workshopId": id},
    );

    try {
      final result = await GraphQLConfig.client().query(options);

      if (result.data != null && result.data!['getWorkshopById'] != null) {
        workshop = Workshop.fromJson(
          result.data!['getWorkshopById'] as Map<String, dynamic>,
        );
        notifyListeners();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
