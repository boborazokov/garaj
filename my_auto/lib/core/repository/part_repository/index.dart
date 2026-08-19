// lib/core/repository/part_repository.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/add/api/index.dart';
import 'package:my_auto/features/profile/screens/my_products/api/index.dart';
import 'package:my_auto/features/services/data/models/service_listing.dart';

class PartRepository {
  final _client = GraphQLConfig.client();

  Future<String> createPart(Map<String, dynamic> data) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(CREATE_PARTS),
        variables: {"data": data, "images": []},
      ),
    );
    final id = result.data?['createPart']?['_id'];
    if (id == null) throw Exception("Failed to create part");
    return id;
  }

  Future<bool> updatePart(
      String id, Map<String, dynamic> data, List<String> images) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updatePartById),
        variables: {"partId": id, "data": data, "images": images},
      ),
    );
    if (result.hasException) throw Exception(result.exception.toString());
    return result.data?['updatePartById'] != null;
  }

  Future<bool> promotePart({
    required String partId,
    required ServicePromotionPlan plan,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(promotePartByIdMutation),
        variables: {
          'partId': partId,
          'plan': plan.api,
        },
      ),
    );
    return !result.hasException;
  }
}

final partRepository = PartRepository();
