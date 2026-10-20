import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_auto/core/model/categoryCar/index.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/routes/router_guard.dart';
import 'package:my_auto/features/create_product/screens/create_product_flow_screen.dart';
import 'package:my_auto/features/edit_product/presentation/screens/edit_product_shell_screen.dart';
import 'package:my_auto/features/add/screens/serviceScreen/index.dart';
import 'package:my_auto/features/add/screens/uploudImage/index.dart';
import 'package:my_auto/features/add/widgets/Map/index.dart';
import 'package:my_auto/features/auth/auth.dart';
import 'package:my_auto/features/chat/presentation/screens/chat_shell_screen.dart';
import 'package:my_auto/features/home/screens/cotegories/index.dart';
import 'package:my_auto/features/home/screens/favorites_screen.dart';
import 'package:my_auto/features/home/screens/listOfItems/index.dart';
import 'package:my_auto/features/orders/presentation/screens/create_order_wizard_screen.dart';
import 'package:my_auto/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:my_auto/features/orders/presentation/screens/orders_screen.dart';
import 'package:my_auto/features/profile/screens/contactUs/index.dart';
import 'package:my_auto/features/profile/screens/edit_profile/index.dart';
import 'package:my_auto/features/profile/screens/myOrders/index.dart';
import 'package:my_auto/features/profile/screens/seller_matching_orders/index.dart';
import 'package:my_auto/features/profile/screens/my_products/index.dart';
import 'package:my_auto/features/profile/screens/my_services/my_services.dart';
import 'package:my_auto/features/profile/screens/privacy_policy/index.dart';
import 'package:my_auto/features/pructsDetail/index.dart';
import 'package:my_auto/features/pructsDetail/widgets/fullscreen/index.dart';
import 'package:my_auto/features/chat/presentation/screens/chats_screen.dart';
import 'package:my_auto/features/notifications/presentation/notifications_center_screen.dart';
import 'package:my_auto/features/search/index.dart';
import 'package:my_auto/features/search/presentation/global_search_hub_screen.dart';
import 'package:my_auto/features/sellerProfile/index.dart';
import 'package:my_auto/features/sellerProfile/models/seller_store_profile.dart';
import 'package:my_auto/features/sellerProfile/screens/store_analytics_screen.dart';
import 'package:my_auto/features/splash/index.dart';
import 'package:my_auto/features/workshop/presentation/create_workshop/create_workshop_flow_screen.dart';
import 'package:my_auto/features/workshop/presentation/edit_workshop_screen.dart';
import 'package:my_auto/features/workshop/presentation/workshop_detail_screen.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:my_auto/main.dart';
import 'package:my_auto/widgets/buttom_navigation_bar/index.dart';
import 'package:my_auto/core/map/geo_location.dart';
import 'package:my_auto/features/map/presentation/nearby_map_screen.dart';
import 'package:my_auto/features/services/presentation/service_details_screen.dart';
import 'package:my_auto/features/services/presentation/services_screen.dart';

late GoRouter appRouter;

GoRouter createAppRouter(AuthProvider auth) {
  final guard = RouterGuard(auth);
  return GoRouter(
    initialLocation: RoutesName.splash,
    navigatorKey: navigatorKey,
    refreshListenable: auth,
    redirect: guard.redirect,
    routes: [
      GoRoute(
        path: RoutesName.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutesName.signin,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RoutesName.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RoutesName.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: RoutesName.buttonNavigationBar,
        builder: (context, state) => const MyBottomNavigationBar(),
      ),
      GoRoute(
        path: RoutesName.editProfile,
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: RoutesName.myProducts,
        builder: (context, state) => const MyProducts(),
      ),
      GoRoute(
        path: RoutesName.myOrders,
        builder: (context, state) => const MyOrders(),
      ),
      GoRoute(
        path: RoutesName.sellerMatchingOrders,
        builder: (context, state) => const SellerMatchingOrdersScreen(),
      ),
      GoRoute(
        path: RoutesName.sellerMatchingOrdersList,
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic>? map;
          if (extra is Map<String, dynamic>) {
            map = extra;
          } else if (extra is Map) {
            map = extra.map((k, v) => MapEntry(k.toString(), v));
          }
          return SellerMatchingOrdersListScreen(
            partCategoryId: map?['partCategoryId'] as String?,
            title: map?['title'] as String?,
            matchSellerCategories:
                map?['matchSellerCategories'] as bool? ?? true,
          );
        },
      ),
      GoRoute(
        path: RoutesName.myServices,
        builder: (context, state) => const MyServices(),
      ),
      GoRoute(
        path: RoutesName.productDetailScreen,
        builder: (context, state) {
          String? id;
          final extra = state.extra;
          if (extra is String && extra.trim().isNotEmpty) {
            id = extra.trim();
          } else {
            id = state.uri.queryParameters['id'] ??
                state.uri.queryParameters['partId'];
          }
          if (id == null || id.isEmpty) {
            return _MissingRouteArgumentScreen(
              message: S.of(context).errorOccurred,
            );
          }
          return ProductDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: RoutesName.contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: RoutesName.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RoutesName.confirmation,
        builder: (context, state) {
          String token = '';
          int correctCode = 0;
          final extra = state.extra;
          if (extra is Map) {
            final t = extra['token'];
            if (t is String) token = t.trim();
            final c = extra['correctCode'];
            if (c is int) correctCode = c;
            if (c is String) correctCode = int.tryParse(c) ?? 0;
          }
          return ConfirmationScreen(token: token, correctCode: correctCode);
        },
      ),
      GoRoute(
        path: RoutesName.addProduct,
        builder: (context, state) {
          final part = state.extra is Part ? state.extra as Part : null;
          if (part != null) {
            return EditProductShellScreen(existingPart: part);
          }
          return const CreateProductFlowScreen();
        },
      ),
      GoRoute(
        path: RoutesName.categoriesScreen,
        builder: (context, state) {
          final extra = state.extra;
          final title = extra is String && extra.isNotEmpty
              ? extra
              : state.uri.queryParameters['title'];
          if (title == null || title.isEmpty) {
            return _MissingRouteArgumentScreen(
              message: S.of(context).errorOccurred,
            );
          }
          return CategoriesScreen(title: title);
        },
      ),
      GoRoute(
        path: RoutesName.listOfItems,
        builder: (context, state) {
          final c = state.extra as CategoryCar;
          return ListOfItems(category: c);
        },
      ),
      GoRoute(
        path: RoutesName.sellerProfile,
        builder: (context, state) {
          String? sellerId;
          final extra = state.extra;
          if (extra is String && extra.trim().isNotEmpty) {
            sellerId = extra.trim();
          } else {
            sellerId = state.uri.queryParameters['sellerId'] ??
                state.uri.queryParameters['id'];
          }
          if (sellerId == null || sellerId.isEmpty) {
            return _MissingRouteArgumentScreen(
              message: S.of(context).errorOccurred,
            );
          }
          return SellerProfile(sellerId: sellerId);
        },
      ),
      GoRoute(
        path: RoutesName.storeAnalytics,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is SellerStoreProfile) {
            return StoreAnalyticsScreen(profile: extra);
          }
          if (extra is String && extra.isNotEmpty) {
            return StoreAnalyticsScreen(sellerId: extra);
          }
          return const StoreAnalyticsScreen();
        },
      ),
      GoRoute(
        path: RoutesName.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: RoutesName.search,
        builder: (context, state) {
          final raw = state.extra;
          Map<String, dynamic>? extras;
          if (raw is Map<String, dynamic>) {
            extras = raw;
          } else if (raw is Map) {
            extras =
                raw.map((k, v) => MapEntry(k.toString(), v));
          }
          if (extras != null &&
              extras['unifiedSearch'] == true) {
            return GlobalSearchHubScreen(
              initialQuery: extras['unifiedInitialQuery'] as String?,
            );
          }
          final isAll = extras?['isAllProduct'] as bool? ?? false;
          return SearchScreen(isAll: isAll);
        },
      ),
      GoRoute(
        path: RoutesName.service,
        builder: (context, state) => Service(),
      ),
      GoRoute(
        path: RoutesName.map,
        builder: (context, state) {
          final initial = state.extra as GeoLocation?;
          return PickLocationScreen(initialPoint: initial);
        },
      ),
      GoRoute(
        path: RoutesName.nearbyMap,
        builder: (context, state) => const NearbyMapScreen(),
      ),
      GoRoute(
        path: RoutesName.servicesHub,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: '${RoutesName.serviceDetail}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ServiceDetailsScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: RoutesName.uploadImage,
        builder: (context, state) => const UploadImage(),
      ),
      GoRoute(
        path: '${RoutesName.workshopDetailScreen}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkshopDetailScreen(workshopId: id);
        },
      ),
      GoRoute(
        path: RoutesName.createWorkshop,
        builder: (context, state) => const CreateWorkshopFlowScreen(),
      ),
      GoRoute(
        path: '${RoutesName.editWorkshop}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditWorkshopScreen(workshopId: id);
        },
      ),
      GoRoute(
        path: RoutesName.fullScreenGallery,
        builder: (context, state) {
          final extras = state.extra;
          if (extras is! Map) {
            return _MissingRouteArgumentScreen(
              message: S.of(context).errorOccurred,
            );
          }
          final rawImages = extras['images'];
          final images = rawImages is List
              ? rawImages.map((e) => e.toString()).toList()
              : null;
          final initialIndex = extras['initialIndex'];
          if (images == null ||
              images.isEmpty ||
              initialIndex is! int) {
            return _MissingRouteArgumentScreen(
              message: S.of(context).errorOccurred,
            );
          }
          return FullScreenGallery(
            images: images,
            initialIndex: initialIndex,
          );
        },
      ),
      GoRoute(
        path: RoutesName.createOrder,
        builder: (context, state) {
          final initial = state.extra as String?;
          return CreateOrderWizardScreen(initialTitle: initial);
        },
      ),
      GoRoute(
        path: RoutesName.ordersList,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final authorId = extras?['authorId'] as String?;
          return OrdersScreen(authorId: authorId);
        },
      ),
      GoRoute(
        path: '${RoutesName.orderDetail}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: RoutesName.chats,
        builder: (context, state) => const ChatShellScreen(),
      ),
      GoRoute(
        path: '${RoutesName.chatDetail}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          String? title;
          String? prefill;
          if (extra is String) {
            title = extra;
          } else if (extra is Map) {
            final t = extra['peerTitle'];
            if (t is String) title = t;
            final p = extra['prefillText'];
            if (p is String) prefill = p;
          }
          return ChatShellScreen(
            conversationId: id,
            peerTitle: title,
            prefillText: prefill,
          );
        },
      ),
      GoRoute(
        path: RoutesName.inbox,
        builder: (context, state) {
          final extra = state.extra;
          var tab = 0;
          if (extra is Map && extra['tab'] is int) {
            tab = extra['tab'] as int;
          }
          if (tab == 1) return const NotificationsCenterScreen();
          return const ChatsScreen();
        },
      ),
      GoRoute(
        path: RoutesName.notifications,
        builder: (context, state) => const NotificationsCenterScreen(),
      ),
    ],
  );
}

class _MissingRouteArgumentScreen extends StatelessWidget {
  const _MissingRouteArgumentScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
