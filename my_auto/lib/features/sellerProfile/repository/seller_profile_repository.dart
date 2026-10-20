import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/sellerProfile/api/seller_profile_api.dart';
import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';

class SellerProfileRepository {
  Future<SellerStoreProfile> fetchProfile(String sellerId) async {
    final result = await GraphQLConfig.client().query(
      QueryOptions(
        document: gql(GET_SELLER_PROFILE),
        variables: {'sellerId': sellerId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['getSellerProfile'];
    if (data == null) {
      throw Exception('Seller profile not found');
    }

    return SellerStoreProfile.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

final sellerProfileRepository = SellerProfileRepository();
