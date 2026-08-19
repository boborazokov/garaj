import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/sellerProfile/api/seller_profile_api.dart';
import 'package:my_auto/features/sellerProfile/models/seller_follower.dart';
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

  Future<bool> follow(String sellerId) async {
    final result = await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(FOLLOW_SELLER),
        variables: {'sellerId': sellerId},
      ),
    );
    if (result.hasException) throw result.exception!;
    return result.data?['followSeller'] == true;
  }

  Future<PaginatedSellerFollowers> fetchFollowers(
    String sellerId, {
    int page = 1,
    int limit = 20,
  }) async {
    final result = await GraphQLConfig.client().query(
      QueryOptions(
        document: gql(GET_SELLER_FOLLOWERS),
        variables: {
          'sellerId': sellerId,
          'pagination': {'page': page, 'limit': limit},
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) throw result.exception!;
    final data = result.data?['getSellerFollowers'];
    if (data == null) {
      throw Exception('Followers not found');
    }

    return PaginatedSellerFollowers.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<bool> unfollow(String sellerId) async {
    final result = await GraphQLConfig.client().mutate(
      MutationOptions(
        document: gql(UNFOLLOW_SELLER),
        variables: {'sellerId': sellerId},
      ),
    );
    if (result.hasException) throw result.exception!;
    return result.data?['unfollowSeller'] == true;
  }
}

final sellerProfileRepository = SellerProfileRepository();
