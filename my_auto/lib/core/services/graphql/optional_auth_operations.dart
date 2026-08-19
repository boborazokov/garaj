import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Operation names aligned with backend `@UseOptionalAuth()` (see autorin-backend AUTH_AUDIT).
const Set<String> optionalAuthOperationNames = {
  'GetParts',
  'GetPartById',
  'GetFavoriteParts',
  'SearchProducts',
  'RecommendedProducts',
  'TrendingProducts',
  'NearbyProducts',
  'RecentlyViewedProducts',
  'SimilarProducts',
  'NewArrivals',
  'RecommendedOrders',
  'GetOrders',
  'GetOrderById',
  'GetWorkshops',
  'NearbyWorkshops',
  'RecommendedWorkshops',
  'PopularNearbyWorkshops',
  'OpenNowWorkshops',
  'FastResponseWorkshops',
  'SearchWorkshops',
  'WorkshopsMapDiscovery',
  'SearchMapEntities',
  'NearbyMapParts',
  'WorkshopDetails',
  'GetWorkshopById',
  'WorkshopReviewsPaginated',
  'NearbyServices',
  'NearbyEmergencyServices',
  'ServiceDetails',
  'GetServices',
  'TopRatedServices',
  'NearbyOrders',
  'ServiceReviews',
  'TrackActivity',
  'GetSellerProfile',
};

/// Root GraphQL fields for `@UseOptionalAuth()` when operationName is missing/generic.
const Set<String> _optionalAuthRootFields = {
  'searchproducts',
  'recommendedproducts',
  'similarproducts',
  'trendingproducts',
  'nearbyproducts',
  'recentlyviewedproducts',
  'newarrivals',
  'recommendedorders',
  'getpartbyid',
  'getparts',
  'getworkshopbyid',
  'workshopdetails',
  'getworkshops',
  'nearbyworkshops',
  'recommendedworkshops',
  'popularnearbyworkshops',
  'opennowworkshops',
  'fastresponseworkshops',
  'searchworkshops',
  'workshopsmapdiscovery',
  'searchmapentities',
  'nearbymapparts',
  'workshopreviews',
  'workshopreviewspaginated',
  'nearbyservices',
  'nearbyemergencyservices',
  'servicedetails',
  'getservices',
  'topratedservices',
  'nearbyorders',
  'servicereviews',
  'getorders',
  'getorderbyid',
  'trackactivity',
  'getsellerprofile',
};

bool isOptionalAuthOperation(Request request) {
  final name = request.operation.operationName?.trim() ?? '';
  if (name.isNotEmpty) {
    return optionalAuthOperationNames
        .any((n) => name.toLowerCase() == n.toLowerCase());
  }
  return _documentHasOptionalAuthRootField(request.operation.document);
}

bool _documentHasOptionalAuthRootField(DocumentNode document) {
  for (final def in document.definitions) {
    if (def is! OperationDefinitionNode) continue;
    for (final selection in def.selectionSet.selections) {
      if (selection is FieldNode) {
        if (_optionalAuthRootFields
            .contains(selection.name.value.toLowerCase())) {
          return true;
        }
      }
    }
  }
  return false;
}
