class RoutesName {
  static const splash = "/";
  static const signin = "/signin";
  static const signup = "/signup";
  static const resetPassword = "/reset-password";
  static const buttonNavigationBar = "/buttonNavigationBar";
  static const editProfile = "/edit_profile";
  static const language = "/language";
  static const myProducts = "/my_products";
  static const myOrders = "/my_orders";
  static const sellerMatchingOrders = "/seller_matching_orders";
  static const sellerMatchingOrdersList = "/seller_matching_orders_list";
  static const myServices = "/my_services";
  static const moreBrands = "/moreBrands";
  static const productDetailScreen = "/productDetailScreen";
  static const contactUs = "/contactUs";
  static const privacyPolicy = "/privacyPolicy";
  static const addProduct = "/addProduct";
  static const confirmation = "/confirmation";
  static const categoriesScreen = "/categoriesScreen";
  static const listOfItems = "/listOfItems";
  static const sellerProfile = '/sellerProfile';
  static const storeAnalytics = '/storeAnalytics';
  static const search = "/search";
  static const favorites = "/favorites";
  static const service = "/service";
  static const createWorkshop = "/createWorkshop";
  static const editWorkshop = "/editWorkshop";
  static const map = "/map";
  static const nearbyMap = "/nearbyMap";
  static const servicesHub = "/servicesHub";
  static const serviceDetail = "/serviceDetail";
  static const uploadImage = "/uploadImage";
  static const workshopDetailScreen = "/workshopDetailScreen";
  static const fullScreenGallery = "/fullScreenGallery";
  static const createOrder = "/createOrder";
  static const ordersList = "/ordersList";
  static const orderDetail = "/orders";

  // Chat / notifications routes — registered in `lib/core/routes/index.dart`
  // when the chat feature ships. Kept here so deep-link routing in
  // `PushRouter` can reference them by symbol, not by literal string.
  static const chats = "/chats";
  static const chatDetail = "/chat"; // pushed as `/chat/$id`
  static const inbox = "/inbox";
  static const notifications = "/notifications";
}