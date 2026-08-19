// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(date) => "On the site until ${date}";

  static String m1(n) => "${n} d ago";

  static String m2(n) => "${n} h ago";

  static String m3(n) => "${n} min ago";

  static String m4(time) => "Last reply in chat · ${time}";

  static String m5(name) => "Reply to ${name}";

  static String m6(price, currency) => "Suggested around ${price} ${currency}";

  static String m7(percent) => "Publishing… ${percent}%";

  static String m8(current, total) => "Step ${current} of ${total}";

  static String m9(count) =>
      "Service types (${count}). Pick all that apply to your business.";

  static String m10(date) => "Followed on ${date}";

  static String m11(name) => "Hi, ${name}";

  static String m12(n) => "${n} listings";

  static String m13(activeLabel, activeCount, inactiveLabel, inactiveCount) =>
      "${activeLabel} · ${activeCount} · ${inactiveLabel} · ${inactiveCount}";

  static String m14(days) => "Delivery ~${days} days";

  static String m15(part) => "Need: ${part}";

  static String m16(amount) => "Offer: ${amount}";

  static String m17(count) => "${count} offers";

  static String m18(date) => "Posted on ${date}";

  static String m19(days, priority) => "${days} days · priority ${priority}";

  static String m20(username) => "@${username}";

  static String m21(followers, products, date) =>
      "${followers} followers • ${products} products • Joined ${date}";

  static String m22(date) => "Seller on Garage since ${date}";

  static String m23(text) => "Owner: ${text}";

  static String m24(amount, currency) => "from ${amount} ${currency}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutSection": MessageLookupByLibrary.simpleMessage("About"),
    "accountDetails": MessageLookupByLibrary.simpleMessage("Account Details"),
    "activatePromotion": MessageLookupByLibrary.simpleMessage(
      "Activate promotion",
    ),
    "active": MessageLookupByLibrary.simpleMessage("Active"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addFirstProduct": MessageLookupByLibrary.simpleMessage(
      "Add first product",
    ),
    "addPhoto": MessageLookupByLibrary.simpleMessage("Add photo"),
    "addProduct": MessageLookupByLibrary.simpleMessage("Add product"),
    "addService": MessageLookupByLibrary.simpleMessage("Add service"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "afternoon": MessageLookupByLibrary.simpleMessage("Good Afternoon"),
    "allProducts": MessageLookupByLibrary.simpleMessage("All products"),
    "allSellerProducts": MessageLookupByLibrary.simpleMessage(
      "All seller’s listings >",
    ),
    "allowMessages": MessageLookupByLibrary.simpleMessage("Allow messages"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "announcements": MessageLookupByLibrary.simpleMessage("Announcements"),
    "anyRegion": MessageLookupByLibrary.simpleMessage("Any region"),
    "appMarketplaceTagline": MessageLookupByLibrary.simpleMessage(
      "Garage marketplace",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Garage"),
    "applyFilters": MessageLookupByLibrary.simpleMessage("Apply"),
    "archivedProducts": MessageLookupByLibrary.simpleMessage("Archived"),
    "areYouSureToDelete": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete?",
    ),
    "areYouSureToDeleteProduct": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this product?",
    ),
    "areYouSureToDeleteWorkshop": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this workshop?",
    ),
    "available": MessageLookupByLibrary.simpleMessage("Available"),
    "availableUntil": m0,
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "badgeFast": MessageLookupByLibrary.simpleMessage("FAST"),
    "badgePremium": MessageLookupByLibrary.simpleMessage("PREMIUM"),
    "badgeTopRated": MessageLookupByLibrary.simpleMessage("TOP RATED"),
    "badgeVerified": MessageLookupByLibrary.simpleMessage("VERIFIED"),
    "bio": MessageLookupByLibrary.simpleMessage("Bio"),
    "bookConfirmBooking": MessageLookupByLibrary.simpleMessage(
      "Confirm booking",
    ),
    "bookDate": MessageLookupByLibrary.simpleMessage("Date"),
    "bookDateTime": MessageLookupByLibrary.simpleMessage("Date & time"),
    "bookNotes": MessageLookupByLibrary.simpleMessage("Notes"),
    "bookNotesOptional": MessageLookupByLibrary.simpleMessage(
      "Notes for the workshop (optional)",
    ),
    "bookNow": MessageLookupByLibrary.simpleMessage("Book now"),
    "bookRequestBooking": MessageLookupByLibrary.simpleMessage(
      "Request booking",
    ),
    "bookServiceHint": MessageLookupByLibrary.simpleMessage(
      "Oil change, diagnostics…",
    ),
    "bookServiceOptional": MessageLookupByLibrary.simpleMessage(
      "Service (optional)",
    ),
    "bookServiceTitle": MessageLookupByLibrary.simpleMessage("Book service"),
    "bookTime": MessageLookupByLibrary.simpleMessage("Time"),
    "bookWorkshopCouldNotBook": MessageLookupByLibrary.simpleMessage(
      "Could not book. Try again.",
    ),
    "bookWorkshopRequestSent": MessageLookupByLibrary.simpleMessage(
      "Booking request sent",
    ),
    "brand": MessageLookupByLibrary.simpleMessage("Brand"),
    "browseAsGuest": MessageLookupByLibrary.simpleMessage("Browse as guest"),
    "budgetOptional": MessageLookupByLibrary.simpleMessage("Budget (optional)"),
    "byAgreement": MessageLookupByLibrary.simpleMessage("By agreement"),
    "callAuthor": MessageLookupByLibrary.simpleMessage("Call author"),
    "callSeller": MessageLookupByLibrary.simpleMessage("Call the seller"),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "carModel": MessageLookupByLibrary.simpleMessage("Car model"),
    "category": MessageLookupByLibrary.simpleMessage("Category"),
    "changeBanner": MessageLookupByLibrary.simpleMessage("Change banner"),
    "chatAttach": MessageLookupByLibrary.simpleMessage("Attach"),
    "chatAttachPhotos": MessageLookupByLibrary.simpleMessage(
      "Photo from gallery",
    ),
    "chatConversationTitle": MessageLookupByLibrary.simpleMessage("Chat"),
    "chatCopied": MessageLookupByLibrary.simpleMessage("Copied"),
    "chatCopy": MessageLookupByLibrary.simpleMessage("Copy"),
    "chatDaysAgo": m1,
    "chatHeaderInChatOnlyHint": MessageLookupByLibrary.simpleMessage(
      "(status is for this chat only)",
    ),
    "chatHeaderTyping": MessageLookupByLibrary.simpleMessage("Typing…"),
    "chatHoursAgo": m2,
    "chatJustNow": MessageLookupByLibrary.simpleMessage("just now"),
    "chatLastPhoto": MessageLookupByLibrary.simpleMessage("Photo"),
    "chatLastVoice": MessageLookupByLibrary.simpleMessage("Voice message"),
    "chatMessageHint": MessageLookupByLibrary.simpleMessage("Message…"),
    "chatMessageHintDesktop": MessageLookupByLibrary.simpleMessage(
      "Write a message… (Enter to send, Shift+Enter for new line)",
    ),
    "chatMicPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Microphone permission is required to record voice messages.",
    ),
    "chatMinutesAgo": m3,
    "chatNoConversationsYet": MessageLookupByLibrary.simpleMessage(
      "No conversations yet",
    ),
    "chatOriginalMessageNotLoaded": MessageLookupByLibrary.simpleMessage(
      "Original message isn\'t loaded yet. Scroll up to load more.",
    ),
    "chatPeerLastSeenInChat": m4,
    "chatPeerNoMessagesYet": MessageLookupByLibrary.simpleMessage(
      "No replies from them yet",
    ),
    "chatPeerRecentlyActive": MessageLookupByLibrary.simpleMessage(
      "Recently active in this chat",
    ),
    "chatReconnecting": MessageLookupByLibrary.simpleMessage("Reconnecting…"),
    "chatReply": MessageLookupByLibrary.simpleMessage("Reply"),
    "chatReplyingTo": m5,
    "chatSayHello": MessageLookupByLibrary.simpleMessage("Say hello"),
    "chatSelectConversation": MessageLookupByLibrary.simpleMessage(
      "Select a conversation",
    ),
    "chatSelectConversationHint": MessageLookupByLibrary.simpleMessage(
      "Choose a chat from the list to start messaging.",
    ),
    "chatTakePhoto": MessageLookupByLibrary.simpleMessage("Take a photo"),
    "chatVoiceHoldHint": MessageLookupByLibrary.simpleMessage("Hold to record"),
    "chatVoiceReleaseToCancel": MessageLookupByLibrary.simpleMessage(
      "Release to cancel",
    ),
    "chatVoiceSlideToCancel": MessageLookupByLibrary.simpleMessage(
      "← Slide to cancel",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Messages"),
    "chooseCategory": MessageLookupByLibrary.simpleMessage("Choose category"),
    "chooseCondition": MessageLookupByLibrary.simpleMessage(
      "Please select the condition",
    ),
    "chooseDeliveryMethod": MessageLookupByLibrary.simpleMessage(
      "Please select the delivery method",
    ),
    "chooseLocation": MessageLookupByLibrary.simpleMessage("Choose location"),
    "chooseLocationOnMap": MessageLookupByLibrary.simpleMessage(
      "Choose location on map",
    ),
    "city": MessageLookupByLibrary.simpleMessage("City"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeOrder": MessageLookupByLibrary.simpleMessage("Close request"),
    "closeOrderConfirm": MessageLookupByLibrary.simpleMessage(
      "Mark this request as closed?",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "completeProfile": MessageLookupByLibrary.simpleMessage("Complete profile"),
    "condition": MessageLookupByLibrary.simpleMessage("Condition"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmReturnToSale": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to make this product available for sale again?",
    ),
    "confirmationCodeNeedsToBe5Symbols": MessageLookupByLibrary.simpleMessage(
      "Confirmation code needs to be 5 symbols",
    ),
    "contactInformation": MessageLookupByLibrary.simpleMessage(
      "Contact information",
    ),
    "contactInformationText": MessageLookupByLibrary.simpleMessage(
      "Questions about privacy or your data: support@myauto.uz or +998 95 384 10 00.",
    ),
    "contactPreferences": MessageLookupByLibrary.simpleMessage("Contact"),
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact Us"),
    "contactUsEmailSubtitle": MessageLookupByLibrary.simpleMessage(
      "We usually reply within 1 business day",
    ),
    "contactUsIntro": MessageLookupByLibrary.simpleMessage(
      "We\'re here to help with listings, orders, and your account.",
    ),
    "contactUsPhoneSubtitle": MessageLookupByLibrary.simpleMessage(
      "Mon–Sat, 9:00–18:00 (Tashkent time)",
    ),
    "continueBrowsing": MessageLookupByLibrary.simpleMessage(
      "Continue browsing",
    ),
    "continueWithoutPhotos": MessageLookupByLibrary.simpleMessage(
      "Continue without photos",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
    "createOrder": MessageLookupByLibrary.simpleMessage("Create request"),
    "createProductAddMorePhotos": MessageLookupByLibrary.simpleMessage(
      "Add more photos",
    ),
    "createProductBrand": MessageLookupByLibrary.simpleMessage("Brand"),
    "createProductCamera": MessageLookupByLibrary.simpleMessage("Camera"),
    "createProductConditionNewHint": MessageLookupByLibrary.simpleMessage(
      "Factory-new, unused",
    ),
    "createProductConditionUsedHint": MessageLookupByLibrary.simpleMessage(
      "Pre-owned, in working order",
    ),
    "createProductContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "createProductContinueDraft": MessageLookupByLibrary.simpleMessage(
      "Continue",
    ),
    "createProductCover": MessageLookupByLibrary.simpleMessage("Cover"),
    "createProductDiscardDraft": MessageLookupByLibrary.simpleMessage(
      "Discard draft",
    ),
    "createProductDraftSaved": MessageLookupByLibrary.simpleMessage(
      "Draft saved",
    ),
    "createProductDragReorder": MessageLookupByLibrary.simpleMessage(
      "Drag to reorder",
    ),
    "createProductDuplicateTitle": MessageLookupByLibrary.simpleMessage(
      "You recently posted a listing with the same title",
    ),
    "createProductErrorCategory": MessageLookupByLibrary.simpleMessage(
      "Please select a category (Vehicle step).",
    ),
    "createProductErrorServer": MessageLookupByLibrary.simpleMessage(
      "Cannot reach server. Check your connection and that the backend is running.",
    ),
    "createProductErrorSignIn": MessageLookupByLibrary.simpleMessage(
      "Please sign in to publish listings.",
    ),
    "createProductExitHint": MessageLookupByLibrary.simpleMessage(
      "You can save a draft and continue later.",
    ),
    "createProductExitTitle": MessageLookupByLibrary.simpleMessage(
      "Leave without publishing?",
    ),
    "createProductGallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "createProductInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Describe your part",
    ),
    "createProductKeepEditing": MessageLookupByLibrary.simpleMessage(
      "Keep editing",
    ),
    "createProductLocationHint": MessageLookupByLibrary.simpleMessage(
      "Pick a point on the map so nearby buyers can find you faster.",
    ),
    "createProductLocationTitle": MessageLookupByLibrary.simpleMessage(
      "Where is the part?",
    ),
    "createProductNegotiableSubtitle": MessageLookupByLibrary.simpleMessage(
      "Buyers can make offers",
    ),
    "createProductNegotiableTitle": MessageLookupByLibrary.simpleMessage(
      "Price is negotiable",
    ),
    "createProductNoModels": MessageLookupByLibrary.simpleMessage(
      "No models for this brand. Pick another brand or add models in admin.",
    ),
    "createProductOfflineBanner": MessageLookupByLibrary.simpleMessage(
      "No internet — you can fill the form and publish when online.",
    ),
    "createProductOfflinePublish": MessageLookupByLibrary.simpleMessage(
      "No internet. Draft saved — try again when online.",
    ),
    "createProductOk": MessageLookupByLibrary.simpleMessage("OK"),
    "createProductPartCategory": MessageLookupByLibrary.simpleMessage(
      "Part category",
    ),
    "createProductPhotosHint": MessageLookupByLibrary.simpleMessage(
      "First photo is the cover. Add up to 8 images.",
    ),
    "createProductPhotosTitle": MessageLookupByLibrary.simpleMessage(
      "Photos sell your part",
    ),
    "createProductPreviewSubtitle": MessageLookupByLibrary.simpleMessage(
      "This is how buyers will see your listing.",
    ),
    "createProductPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Preview",
    ),
    "createProductPriceSuggested": m6,
    "createProductPriceTitle": MessageLookupByLibrary.simpleMessage(
      "Set your price",
    ),
    "createProductPublishNow": MessageLookupByLibrary.simpleMessage(
      "Publish now",
    ),
    "createProductPublishedSuccess": MessageLookupByLibrary.simpleMessage(
      "Listing published successfully",
    ),
    "createProductPublishing": m7,
    "createProductQuickErrorPhoto": MessageLookupByLibrary.simpleMessage(
      "Add a photo",
    ),
    "createProductQuickErrorPrice": MessageLookupByLibrary.simpleMessage(
      "Set a price",
    ),
    "createProductQuickErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Title (3+ characters)",
    ),
    "createProductRecentlyUsed": MessageLookupByLibrary.simpleMessage(
      "Recently used",
    ),
    "createProductRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "createProductSaveAndExit": MessageLookupByLibrary.simpleMessage(
      "Save and exit",
    ),
    "createProductSelect": MessageLookupByLibrary.simpleMessage("Select"),
    "createProductStartNew": MessageLookupByLibrary.simpleMessage(
      "New listing",
    ),
    "createProductStepInfo": MessageLookupByLibrary.simpleMessage("Details"),
    "createProductStepLocation": MessageLookupByLibrary.simpleMessage(
      "Location",
    ),
    "createProductStepPhotos": MessageLookupByLibrary.simpleMessage("Photos"),
    "createProductStepPreview": MessageLookupByLibrary.simpleMessage("Preview"),
    "createProductStepPrice": MessageLookupByLibrary.simpleMessage("Price"),
    "createProductStepProgress": m8,
    "createProductStepVehicle": MessageLookupByLibrary.simpleMessage("Vehicle"),
    "createProductTapAddPhotos": MessageLookupByLibrary.simpleMessage(
      "Tap to add photos",
    ),
    "createProductTitleHint": MessageLookupByLibrary.simpleMessage(
      "e.g. Toyota Camry brake pads — new",
    ),
    "createProductTrustBody": MessageLookupByLibrary.simpleMessage(
      "Add 3+ photos, a clear title and a fair price — buyers trust complete listings.",
    ),
    "createProductTrustTitle": MessageLookupByLibrary.simpleMessage(
      "Sell faster with great photos",
    ),
    "createProductUnfinishedHint": MessageLookupByLibrary.simpleMessage(
      "Do you want to continue or start a new one?",
    ),
    "createProductUnfinishedTitle": MessageLookupByLibrary.simpleMessage(
      "You didn\'t finish this listing",
    ),
    "createProductUntitled": MessageLookupByLibrary.simpleMessage("Untitled"),
    "createProductUpdateListing": MessageLookupByLibrary.simpleMessage(
      "Update listing",
    ),
    "createProductUseMyLocation": MessageLookupByLibrary.simpleMessage(
      "Use my location",
    ),
    "createProductVehicleHint": MessageLookupByLibrary.simpleMessage(
      "Helps buyers find your part faster.",
    ),
    "createProductVehicleTitle": MessageLookupByLibrary.simpleMessage(
      "Which vehicle?",
    ),
    "createProductWarnNoCategory": MessageLookupByLibrary.simpleMessage(
      "Select vehicle or category",
    ),
    "createProductWarnNoCurrency": MessageLookupByLibrary.simpleMessage(
      "Select currency",
    ),
    "createProductWarnNoPhotos": MessageLookupByLibrary.simpleMessage(
      "Add at least one photo",
    ),
    "createProductWarnNoPrice": MessageLookupByLibrary.simpleMessage(
      "Set a price",
    ),
    "createProductWarnTitleShort": MessageLookupByLibrary.simpleMessage(
      "Title is too short",
    ),
    "createProductYearOptional": MessageLookupByLibrary.simpleMessage(
      "Year (optional)",
    ),
    "createRequest": MessageLookupByLibrary.simpleMessage("Create Request"),
    "createRequestSubtitle": MessageLookupByLibrary.simpleMessage(
      "Post a buy request and let sellers contact you.",
    ),
    "createWorkshopAllServices": MessageLookupByLibrary.simpleMessage(
      "All services",
    ),
    "createWorkshopPopular": MessageLookupByLibrary.simpleMessage("Popular"),
    "createWorkshopServicesHint": m9,
    "createWorkshopServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Select services you offer",
    ),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Dark mode"),
    "dashboardLeads": MessageLookupByLibrary.simpleMessage("Leads"),
    "dashboardMessages": MessageLookupByLibrary.simpleMessage("Messages"),
    "dashboardNewFollowers": MessageLookupByLibrary.simpleMessage("Followers"),
    "dashboardProductViews": MessageLookupByLibrary.simpleMessage(
      "Product views",
    ),
    "dashboardProductsSold": MessageLookupByLibrary.simpleMessage(
      "Products sold",
    ),
    "dashboardToday": MessageLookupByLibrary.simpleMessage("Overview"),
    "dataCollection": MessageLookupByLibrary.simpleMessage(
      "1. Data Collection",
    ),
    "dataCollectionText": MessageLookupByLibrary.simpleMessage(
      "We collect personal information such as your name, email address, and phone number when you create an account or use our services.",
    ),
    "dataUsage": MessageLookupByLibrary.simpleMessage("2. Data Usage"),
    "dataUsageText": MessageLookupByLibrary.simpleMessage(
      "Your data is used to provide and improve our services, personalize your experience, and communicate with you.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete account"),
    "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete permanently",
    ),
    "deleteAccountDescription": MessageLookupByLibrary.simpleMessage(
      "Delete your account permanently?",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "Could not delete account. Try again or contact support.",
    ),
    "deleteAccountSubtitle": MessageLookupByLibrary.simpleMessage(
      "Your profile and personal data will be removed. Your listings will be archived. This cannot be undone.",
    ),
    "deleteAccountSuccess": MessageLookupByLibrary.simpleMessage(
      "Your account has been deleted",
    ),
    "deleteProductTitle": MessageLookupByLibrary.simpleMessage(
      "Delete product",
    ),
    "deleteReview": MessageLookupByLibrary.simpleMessage("Delete review"),
    "deleteReviewConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete your review permanently?",
    ),
    "deleteWorkshopTitle": MessageLookupByLibrary.simpleMessage(
      "Delete workshop",
    ),
    "delivery": MessageLookupByLibrary.simpleMessage("Delivery"),
    "depleted": MessageLookupByLibrary.simpleMessage("Depleted"),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "descriptionOfParts": MessageLookupByLibrary.simpleMessage(
      "Description of parts",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "didntFindWhatYouNeed": MessageLookupByLibrary.simpleMessage(
      "Didn\'t find what you need?",
    ),
    "discount": MessageLookupByLibrary.simpleMessage("Discount"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "draftProducts": MessageLookupByLibrary.simpleMessage("Drafts"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editReview": MessageLookupByLibrary.simpleMessage("Edit review"),
    "editService": MessageLookupByLibrary.simpleMessage("Edit Service"),
    "editStore": MessageLookupByLibrary.simpleMessage("Edit store"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailAddress": MessageLookupByLibrary.simpleMessage("Email address"),
    "enterCodeMessage": MessageLookupByLibrary.simpleMessage(
      "We’ve sent you a 5-digit code — enter it here to continue",
    ),
    "enterDescription": MessageLookupByLibrary.simpleMessage(
      "Enter description here...",
    ),
    "enterDescriptionPart": MessageLookupByLibrary.simpleMessage(
      "Enter a detailed description of the part",
    ),
    "enterPrice": MessageLookupByLibrary.simpleMessage("Enter price"),
    "enterTitleOfPart": MessageLookupByLibrary.simpleMessage("Enter part name"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorAuthConfirmationTokenExpired": MessageLookupByLibrary.simpleMessage(
      "Verification expired. Request a new code.",
    ),
    "errorAuthConfirmationTokenInvalid": MessageLookupByLibrary.simpleMessage(
      "Invalid sign-up session. Please register again.",
    ),
    "errorAuthConfirmationTokenMissing": MessageLookupByLibrary.simpleMessage(
      "Sign-up session expired. Please register again.",
    ),
    "errorAuthForbidden": MessageLookupByLibrary.simpleMessage(
      "You don\'t have permission for this action.",
    ),
    "errorAuthInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Incorrect phone or password.",
    ),
    "errorAuthInvalidOtp": MessageLookupByLibrary.simpleMessage(
      "Invalid verification code.",
    ),
    "errorAuthOtpExpired": MessageLookupByLibrary.simpleMessage(
      "Verification code expired. Request a new one.",
    ),
    "errorAuthSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Real-time updates require a secure connection.",
    ),
    "errorAuthUnauthorized": MessageLookupByLibrary.simpleMessage(
      "Please sign in to continue.",
    ),
    "errorAuthUserExists": MessageLookupByLibrary.simpleMessage(
      "This phone number is already registered.",
    ),
    "errorAuthUserNotFound": MessageLookupByLibrary.simpleMessage(
      "Account not found.",
    ),
    "errorAuthorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Author is unavailable",
    ),
    "errorBusinessAlreadyReviewed": MessageLookupByLibrary.simpleMessage(
      "You have already left a review.",
    ),
    "errorBusinessCannotBookOwn": MessageLookupByLibrary.simpleMessage(
      "You cannot book your own service.",
    ),
    "errorBusinessCannotRespondOwnOrder": MessageLookupByLibrary.simpleMessage(
      "You cannot respond to your own request.",
    ),
    "errorBusinessCannotReviewOwn": MessageLookupByLibrary.simpleMessage(
      "You cannot review your own listing.",
    ),
    "errorBusinessMessageTooLong": MessageLookupByLibrary.simpleMessage(
      "Message is too long.",
    ),
    "errorBusinessNotAllowed": MessageLookupByLibrary.simpleMessage(
      "This action is not allowed.",
    ),
    "errorBusinessNotParticipant": MessageLookupByLibrary.simpleMessage(
      "You are not part of this chat.",
    ),
    "errorBusinessOrderWatchDenied": MessageLookupByLibrary.simpleMessage(
      "You cannot watch this request.",
    ),
    "errorBusinessRateLimit": MessageLookupByLibrary.simpleMessage(
      "Too many requests. Please wait and try again.",
    ),
    "errorCannotMessageSelf": MessageLookupByLibrary.simpleMessage(
      "You cannot message yourself",
    ),
    "errorConversationNotFound": MessageLookupByLibrary.simpleMessage(
      "Chat not found.",
    ),
    "errorDeviceOffline": MessageLookupByLibrary.simpleMessage(
      "Device is offline. Open the app to receive updates.",
    ),
    "errorGeneric": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Please try again.",
    ),
    "errorMessageNotFound": MessageLookupByLibrary.simpleMessage(
      "Message not found.",
    ),
    "errorNoListings": MessageLookupByLibrary.simpleMessage("No listings"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred. Please try again later.",
    ),
    "errorOrderNotClosed": MessageLookupByLibrary.simpleMessage(
      "This request is not closed.",
    ),
    "errorOrderNotFound": MessageLookupByLibrary.simpleMessage(
      "Request not found.",
    ),
    "errorPartNotFound": MessageLookupByLibrary.simpleMessage(
      "Listing not found.",
    ),
    "errorResourceNotFound": MessageLookupByLibrary.simpleMessage(
      "Item not found.",
    ),
    "errorSellerUnavailable": MessageLookupByLibrary.simpleMessage(
      "Seller is unavailable",
    ),
    "errorServiceNotFound": MessageLookupByLibrary.simpleMessage(
      "Service not found.",
    ),
    "errorValidationFailed": MessageLookupByLibrary.simpleMessage(
      "Please check your input and try again.",
    ),
    "errorValidationFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "File is too large.",
    ),
    "errorValidationFileTypeInvalid": MessageLookupByLibrary.simpleMessage(
      "This file type is not supported.",
    ),
    "errorValidationRequestTooComplex": MessageLookupByLibrary.simpleMessage(
      "Request is too complex. Simplify and retry.",
    ),
    "errorValidationRequestTooLarge": MessageLookupByLibrary.simpleMessage(
      "Request is too large.",
    ),
    "errorWorkshopNotFound": MessageLookupByLibrary.simpleMessage(
      "Auto service not found.",
    ),
    "errorWsHandshakeRateLimited": MessageLookupByLibrary.simpleMessage(
      "Too many connection attempts. Try again later.",
    ),
    "errorWsOriginNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Connection blocked for security reasons.",
    ),
    "errorWsTooManyConnections": MessageLookupByLibrary.simpleMessage(
      "Too many active connections.",
    ),
    "errorWsUnauthenticated": MessageLookupByLibrary.simpleMessage(
      "Connection not authenticated.",
    ),
    "exampleTittleParts": MessageLookupByLibrary.simpleMessage(
      "Example: Piston",
    ),
    "favorites": MessageLookupByLibrary.simpleMessage("Saved"),
    "favoritesEmpty": MessageLookupByLibrary.simpleMessage(
      "No saved items yet",
    ),
    "featured": MessageLookupByLibrary.simpleMessage("Featured"),
    "featuredSubtitle": MessageLookupByLibrary.simpleMessage(
      "Promoted listings",
    ),
    "fieldRequired": MessageLookupByLibrary.simpleMessage("Field required"),
    "fillAllFields": MessageLookupByLibrary.simpleMessage("Fill all fields"),
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "follow": MessageLookupByLibrary.simpleMessage("Follow"),
    "followedOn": m10,
    "following": MessageLookupByLibrary.simpleMessage("Following"),
    "forbiddenResource": MessageLookupByLibrary.simpleMessage(
      "Forbidden resource",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "gridView": MessageLookupByLibrary.simpleMessage("Grid"),
    "guest": MessageLookupByLibrary.simpleMessage("Guest"),
    "helpAndSupport": MessageLookupByLibrary.simpleMessage("Help and Support"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "homeAlertsPreviewSection": MessageLookupByLibrary.simpleMessage("Updates"),
    "homeChatsPreviewSection": MessageLookupByLibrary.simpleMessage(
      "Your conversations",
    ),
    "homeExploreNearbySubtitle": MessageLookupByLibrary.simpleMessage(
      "Workshops • listings • live requests nearby",
    ),
    "homeExploreNearbyTitle": MessageLookupByLibrary.simpleMessage(
      "Live discovery map",
    ),
    "homeGreeting": m11,
    "homeHotOrdersPreview": MessageLookupByLibrary.simpleMessage(
      "Open requests nearby",
    ),
    "homeListingCountHint": m12,
    "homeNearbyWorkshopsPreview": MessageLookupByLibrary.simpleMessage(
      "Workshops nearby",
    ),
    "homeNoChatsYet": MessageLookupByLibrary.simpleMessage("No chats yet"),
    "homeOpenMessages": MessageLookupByLibrary.simpleMessage("Messages"),
    "homeOpenNotifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "homeQuickActionsRow": MessageLookupByLibrary.simpleMessage(
      "Quick actions",
    ),
    "homeQuickAddWorkshop": MessageLookupByLibrary.simpleMessage(
      "Auto Service",
    ),
    "homeQuickCreateOrder": MessageLookupByLibrary.simpleMessage("Order"),
    "homeQuickSellProduct": MessageLookupByLibrary.simpleMessage("Sell"),
    "homeSeeCategoryServices": MessageLookupByLibrary.simpleMessage(
      "See services",
    ),
    "homeSellerSpotlight": MessageLookupByLibrary.simpleMessage(
      "Spotlight sellers",
    ),
    "homeStickyChooseLocation": MessageLookupByLibrary.simpleMessage(
      "Location",
    ),
    "homeStickyNearYou": MessageLookupByLibrary.simpleMessage("Near you"),
    "homeTrendingServicesPreview": MessageLookupByLibrary.simpleMessage(
      "Trending services",
    ),
    "images": MessageLookupByLibrary.simpleMessage("Images"),
    "inactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "included": MessageLookupByLibrary.simpleMessage("Included"),
    "info": MessageLookupByLibrary.simpleMessage("Info"),
    "invalidOtpCode": MessageLookupByLibrary.simpleMessage("Invalid OTP code"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "latestProducts": MessageLookupByLibrary.simpleMessage("Latest"),
    "listView": MessageLookupByLibrary.simpleMessage("List"),
    "loadMoreReviews": MessageLookupByLibrary.simpleMessage("Load more"),
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "logIn": MessageLookupByLibrary.simpleMessage("Log In to your account"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutDescription": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "logoutSubtitle": MessageLookupByLibrary.simpleMessage(
      "You will be redirected to the login screen.",
    ),
    "manageProducts": MessageLookupByLibrary.simpleMessage("Manage products"),
    "mapAllWorkshops": MessageLookupByLibrary.simpleMessage("All workshops"),
    "mapFilterNearby": MessageLookupByLibrary.simpleMessage("Nearby"),
    "mapFilterOpenNow": MessageLookupByLibrary.simpleMessage("Open now"),
    "mapFilterPremium": MessageLookupByLibrary.simpleMessage("Premium"),
    "mapFilterTopRated": MessageLookupByLibrary.simpleMessage("Top rated"),
    "mapFilterVerified": MessageLookupByLibrary.simpleMessage("Verified"),
    "mapFiltersTitle": MessageLookupByLibrary.simpleMessage("Filters & map"),
    "mapHeatmapSubtitle": MessageLookupByLibrary.simpleMessage(
      "Highlight areas with more listings",
    ),
    "mapHeatmapTitle": MessageLookupByLibrary.simpleMessage("Density heatmap"),
    "mapLayerRequests": MessageLookupByLibrary.simpleMessage("Requests"),
    "mapLayerWorkshops": MessageLookupByLibrary.simpleMessage("Workshops"),
    "mapLocationDefaultArea": MessageLookupByLibrary.simpleMessage(
      "Using default map area — enable location for best results",
    ),
    "mapLocationFailed": MessageLookupByLibrary.simpleMessage(
      "Could not get your location",
    ),
    "mapLocationGpsDisabled": MessageLookupByLibrary.simpleMessage(
      "Turn on location (GPS) in device settings",
    ),
    "mapLocationPermissionForever": MessageLookupByLibrary.simpleMessage(
      "Allow location in app settings",
    ),
    "mapLocationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission is required to show your position",
    ),
    "mapOpenPin": MessageLookupByLibrary.simpleMessage("Open"),
    "mapQuickFilters": MessageLookupByLibrary.simpleMessage("Quick filters"),
    "mapRouteTooltip": MessageLookupByLibrary.simpleMessage("Route"),
    "mapSearchRadius": MessageLookupByLibrary.simpleMessage("Search radius"),
    "mapShareTooltip": MessageLookupByLibrary.simpleMessage("Share"),
    "mapShownOnMap": MessageLookupByLibrary.simpleMessage("Shown on map"),
    "maxFiveImages": MessageLookupByLibrary.simpleMessage("Max 5 images"),
    "messages": MessageLookupByLibrary.simpleMessage("Messages"),
    "messagesDisabled": MessageLookupByLibrary.simpleMessage(
      "Messages disabled",
    ),
    "missingAvatar": MessageLookupByLibrary.simpleMessage("Profile photo"),
    "missingBio": MessageLookupByLibrary.simpleMessage("Bio"),
    "missingDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "missingFields": MessageLookupByLibrary.simpleMessage("Missing:"),
    "missingLocation": MessageLookupByLibrary.simpleMessage("Location"),
    "missingSocialLinks": MessageLookupByLibrary.simpleMessage("Social links"),
    "missingStoreBanner": MessageLookupByLibrary.simpleMessage("Store banner"),
    "missingUsername": MessageLookupByLibrary.simpleMessage("Username"),
    "modelOfCar": MessageLookupByLibrary.simpleMessage("Model of car"),
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "moreFromSeller": MessageLookupByLibrary.simpleMessage(
      "More from this seller",
    ),
    "morning": MessageLookupByLibrary.simpleMessage("Good Morning"),
    "myListingsBreakdown": m13,
    "myListingsEmptyActive": MessageLookupByLibrary.simpleMessage(
      "No active listings yet",
    ),
    "myListingsEmptyInactive": MessageLookupByLibrary.simpleMessage(
      "No archived listings",
    ),
    "myListingsTotalLabel": MessageLookupByLibrary.simpleMessage(
      "Total listings",
    ),
    "myOrders": MessageLookupByLibrary.simpleMessage("My Orders"),
    "myProducts": MessageLookupByLibrary.simpleMessage("My Products"),
    "myRequests": MessageLookupByLibrary.simpleMessage("My requests"),
    "myServices": MessageLookupByLibrary.simpleMessage("My Services"),
    "myStore": MessageLookupByLibrary.simpleMessage("My store"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nearYou": MessageLookupByLibrary.simpleMessage("Near You"),
    "nearYouSubtitle": MessageLookupByLibrary.simpleMessage(
      "Listings in your area",
    ),
    "negotiable": MessageLookupByLibrary.simpleMessage("Negotiable"),
    "newArrivals": MessageLookupByLibrary.simpleMessage("New Arrivals"),
    "newArrivalsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Fresh listings today",
    ),
    "newPart": MessageLookupByLibrary.simpleMessage("New"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "night": MessageLookupByLibrary.simpleMessage("Good Night"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "noAvailable": MessageLookupByLibrary.simpleMessage("No available"),
    "noDiscount": MessageLookupByLibrary.simpleMessage("No discount"),
    "noFollowersYet": MessageLookupByLibrary.simpleMessage("No followers yet"),
    "noImages": MessageLookupByLibrary.simpleMessage("No images"),
    "noInternetConnection": MessageLookupByLibrary.simpleMessage(
      "No internet connection. Please check your network settings.",
    ),
    "noOrders": MessageLookupByLibrary.simpleMessage("No requests yet"),
    "noOrdersHint": MessageLookupByLibrary.simpleMessage(
      "When buyers post requests, they\'ll appear here.",
    ),
    "noProducts": MessageLookupByLibrary.simpleMessage("No products"),
    "noReviewsYet": MessageLookupByLibrary.simpleMessage("No reviews yet"),
    "noServices": MessageLookupByLibrary.simpleMessage("No yet Services"),
    "noWorkshops": MessageLookupByLibrary.simpleMessage("No yet Workshops"),
    "noWorkshopsFound": MessageLookupByLibrary.simpleMessage(
      "No workshops found",
    ),
    "notVerified": MessageLookupByLibrary.simpleMessage("Not verified"),
    "notification": MessageLookupByLibrary.simpleMessage("Notification"),
    "notificationAccountVerifiedBody": MessageLookupByLibrary.simpleMessage(
      "Your account is now verified by the AutoRin team.",
    ),
    "notificationAccountVerifiedTitle": MessageLookupByLibrary.simpleMessage(
      "You are verified",
    ),
    "notificationFavoriteMatchedBody": MessageLookupByLibrary.simpleMessage(
      "A saved listing matches what you were looking for.",
    ),
    "notificationFavoriteMatchedTitle": MessageLookupByLibrary.simpleMessage(
      "Price match",
    ),
    "notificationGenericAlertBody": MessageLookupByLibrary.simpleMessage(
      "You have a new alert.",
    ),
    "notificationGenericAlertTitle": MessageLookupByLibrary.simpleMessage(
      "Garage",
    ),
    "notificationNewFollowerBody": MessageLookupByLibrary.simpleMessage(
      "Someone started following your store.",
    ),
    "notificationNewFollowerTitle": MessageLookupByLibrary.simpleMessage(
      "New follower",
    ),
    "notificationNewMessageBody": MessageLookupByLibrary.simpleMessage(
      "Tap to open the conversation.",
    ),
    "notificationNewMessageTitle": MessageLookupByLibrary.simpleMessage(
      "New message",
    ),
    "notificationOpenAction": MessageLookupByLibrary.simpleMessage("Open"),
    "notificationOrderReplyBody": MessageLookupByLibrary.simpleMessage(
      "There is an update on your order.",
    ),
    "notificationOrderReplyTitle": MessageLookupByLibrary.simpleMessage(
      "Order update",
    ),
    "notificationPromotedExpiredBody": MessageLookupByLibrary.simpleMessage(
      "Your listing is no longer promoted. Renew to stay on top.",
    ),
    "notificationPromotedExpiredTitle": MessageLookupByLibrary.simpleMessage(
      "Promotion ended",
    ),
    "notificationSellerResponseTitle": MessageLookupByLibrary.simpleMessage(
      "Seller replied",
    ),
    "notificationWorkshopBookingBody": MessageLookupByLibrary.simpleMessage(
      "You have a new booking or service reply.",
    ),
    "notificationWorkshopBookingTitle": MessageLookupByLibrary.simpleMessage(
      "Workshop booking",
    ),
    "notificationsAlertsOff": MessageLookupByLibrary.simpleMessage(
      "Alerts off",
    ),
    "notificationsAlertsOn": MessageLookupByLibrary.simpleMessage("Alerts on"),
    "notificationsCenterEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Alerts about new followers, orders, workshops and deals will appear here. Your message threads stay in Messages.",
    ),
    "notificationsCenterFooterHint": MessageLookupByLibrary.simpleMessage(
      "You’ll get alerts for orders, workshops and deals on this device.",
    ),
    "notificationsCenterTitle": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "notificationsEnableButton": MessageLookupByLibrary.simpleMessage(
      "Enable notifications",
    ),
    "notificationsEnableHint": MessageLookupByLibrary.simpleMessage(
      "Turn on notifications so you don’t miss order and chat updates.",
    ),
    "notificationsIosSettingsHint": MessageLookupByLibrary.simpleMessage(
      "You can also enable alerts in Settings → Notifications → Garage.",
    ),
    "notificationsMarkAllRead": MessageLookupByLibrary.simpleMessage(
      "Mark all as read",
    ),
    "notificationsPermissionHintShort": MessageLookupByLibrary.simpleMessage(
      "Enable alerts",
    ),
    "notificationsRecent": MessageLookupByLibrary.simpleMessage(
      "Recent alerts",
    ),
    "notificationsTopicFollowers": MessageLookupByLibrary.simpleMessage(
      "New store followers",
    ),
    "notificationsTopicMessages": MessageLookupByLibrary.simpleMessage(
      "New messages and chat replies",
    ),
    "notificationsTopicOrders": MessageLookupByLibrary.simpleMessage(
      "Order status and buyer/seller updates",
    ),
    "notificationsTopicPromos": MessageLookupByLibrary.simpleMessage(
      "Deals and featured listings",
    ),
    "notificationsTopicWorkshops": MessageLookupByLibrary.simpleMessage(
      "Workshop bookings and service replies",
    ),
    "notificationsWhatYouGet": MessageLookupByLibrary.simpleMessage(
      "What you’ll receive",
    ),
    "openAnalytics": MessageLookupByLibrary.simpleMessage("Open analytics"),
    "openFrom": MessageLookupByLibrary.simpleMessage("Open from"),
    "order": MessageLookupByLibrary.simpleMessage("Order"),
    "orderCreated": MessageLookupByLibrary.simpleMessage(
      "Request created successfully",
    ),
    "orderDetailAcceptedOffer": MessageLookupByLibrary.simpleMessage(
      "Accepted",
    ),
    "orderDetailAlternativeListing": MessageLookupByLibrary.simpleMessage(
      "Alternative part (seller\'s listing)",
    ),
    "orderDetailBudgetNegotiable": MessageLookupByLibrary.simpleMessage(
      "Budget negotiable",
    ),
    "orderDetailChatSeller": MessageLookupByLibrary.simpleMessage("Chat"),
    "orderDetailDeliveryDays": m14,
    "orderDetailLookingFor": MessageLookupByLibrary.simpleMessage(
      "Looking for",
    ),
    "orderDetailMessageBuyer": MessageLookupByLibrary.simpleMessage(
      "Message buyer",
    ),
    "orderDetailNeedsPart": m15,
    "orderDetailNoOffers": MessageLookupByLibrary.simpleMessage(
      "No offers yet. Sellers will propose parts and prices for your request here.",
    ),
    "orderDetailOfferMessageHint": MessageLookupByLibrary.simpleMessage(
      "Describe the part you can supply for this request…",
    ),
    "orderDetailOfferPrice": m16,
    "orderDetailOfferPriceHint": MessageLookupByLibrary.simpleMessage(
      "Your price (optional)",
    ),
    "orderDetailOffersCount": m17,
    "orderDetailOffersTitle": MessageLookupByLibrary.simpleMessage(
      "Seller offers",
    ),
    "orderDetailPosted": MessageLookupByLibrary.simpleMessage("Posted"),
    "orderDetailSellerListing": MessageLookupByLibrary.simpleMessage(
      "Seller\'s listing",
    ),
    "orderDetailSendOffer": MessageLookupByLibrary.simpleMessage("Send offer"),
    "orderDetailSubmitOffer": MessageLookupByLibrary.simpleMessage(
      "Submit offer",
    ),
    "orderDetailViewListing": MessageLookupByLibrary.simpleMessage(
      "View listing",
    ),
    "orderDetailYourOffer": MessageLookupByLibrary.simpleMessage("Your offer"),
    "orderPartBrakes": MessageLookupByLibrary.simpleMessage("Brakes"),
    "orderPartBumper": MessageLookupByLibrary.simpleMessage("Bumper"),
    "orderPartEngine": MessageLookupByLibrary.simpleMessage("Engine"),
    "orderPartHeadlights": MessageLookupByLibrary.simpleMessage("Headlights"),
    "orderPartSuspension": MessageLookupByLibrary.simpleMessage("Suspension"),
    "orderStatusActive": MessageLookupByLibrary.simpleMessage("Active"),
    "orderStatusClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "orderUrgencyHint": MessageLookupByLibrary.simpleMessage(
      "Sellers see this on your request card.",
    ),
    "orderUrgencyLow": MessageLookupByLibrary.simpleMessage("Not urgent"),
    "orderUrgencyNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "orderUrgencyTitle": MessageLookupByLibrary.simpleMessage(
      "How urgent is it?",
    ),
    "orderUrgencyUrgent": MessageLookupByLibrary.simpleMessage("Urgent"),
    "orders": MessageLookupByLibrary.simpleMessage("Orders"),
    "otherListingsBySeller": MessageLookupByLibrary.simpleMessage(
      "Other listings by seller",
    ),
    "outOfStock": MessageLookupByLibrary.simpleMessage("Out of stock"),
    "ownerMyListings": MessageLookupByLibrary.simpleMessage("My listings"),
    "ownerStoreEmpty": MessageLookupByLibrary.simpleMessage(
      "You have no products yet",
    ),
    "partCategory": MessageLookupByLibrary.simpleMessage("Part category"),
    "partCreated": MessageLookupByLibrary.simpleMessage(
      "Part created successfully",
    ),
    "parts": MessageLookupByLibrary.simpleMessage("Parts"),
    "passengerCars": MessageLookupByLibrary.simpleMessage("Passenger Cars"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pendingModeration": MessageLookupByLibrary.simpleMessage("Pending"),
    "peopleAlsoViewed": MessageLookupByLibrary.simpleMessage(
      "People Also Viewed",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone number"),
    "photos": MessageLookupByLibrary.simpleMessage("Photos"),
    "popularProducts": MessageLookupByLibrary.simpleMessage("Popular"),
    "postedOn": m18,
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "priceDescription": MessageLookupByLibrary.simpleMessage(
      "Price description",
    ),
    "priceDescriptionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Enter price description here...",
    ),
    "priceFrom": MessageLookupByLibrary.simpleMessage("Price from"),
    "priceTo": MessageLookupByLibrary.simpleMessage("Price to"),
    "privacyAccountData": MessageLookupByLibrary.simpleMessage(
      "2. Account & listing data",
    ),
    "privacyAccountDataText": MessageLookupByLibrary.simpleMessage(
      "We store your profile (name, phone, photo), listings (parts, workshops), messages, orders, and device tokens for push notifications. Location is optional and only used if you provide it.",
    ),
    "privacyAccountDeletion": MessageLookupByLibrary.simpleMessage(
      "6. Delete your account",
    ),
    "privacyAccountDeletionText": MessageLookupByLibrary.simpleMessage(
      "You can delete your account anytime in Profile → Delete account. This permanently removes your personal information and archives your listings. This action cannot be undone.",
    ),
    "privacyChildren": MessageLookupByLibrary.simpleMessage("7. Children"),
    "privacyChildrenText": MessageLookupByLibrary.simpleMessage(
      "My Auto is not intended for users under 16. We do not knowingly collect data from children.",
    ),
    "privacyDataRetention": MessageLookupByLibrary.simpleMessage(
      "5. Data retention",
    ),
    "privacyDataRetentionText": MessageLookupByLibrary.simpleMessage(
      "We keep your data while your account is active. When you delete your account, personal data is removed and listings are archived.",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacyPolicyChanges": MessageLookupByLibrary.simpleMessage(
      "9. Policy changes",
    ),
    "privacyPolicyChangesText": MessageLookupByLibrary.simpleMessage(
      "We may update this policy. Continued use of the app after changes means you accept the updated policy.",
    ),
    "privacyPolicyIntro": MessageLookupByLibrary.simpleMessage(
      "We are committed to protecting your privacy. This policy explains how we collect, use, and protect your data.",
    ),
    "privacyPolicyLastUpdated": MessageLookupByLibrary.simpleMessage(
      "Last updated: June 2026",
    ),
    "privacySecurity": MessageLookupByLibrary.simpleMessage("4. Security"),
    "privacySecurityText": MessageLookupByLibrary.simpleMessage(
      "We use encryption in transit (HTTPS), secure authentication, and access controls. No method is 100% secure, but we work to protect your information.",
    ),
    "privacySettings": MessageLookupByLibrary.simpleMessage("Privacy settings"),
    "privateVisibility": MessageLookupByLibrary.simpleMessage("Private"),
    "productClicks": MessageLookupByLibrary.simpleMessage("Product clicks"),
    "productDeleted": MessageLookupByLibrary.simpleMessage(
      "Product deleted successfully",
    ),
    "productDetails": MessageLookupByLibrary.simpleMessage("Product Details"),
    "productManagement": MessageLookupByLibrary.simpleMessage(
      "Product management",
    ),
    "productSuccessfullyPublished": MessageLookupByLibrary.simpleMessage(
      "Product successfully published",
    ),
    "productUpdated": MessageLookupByLibrary.simpleMessage(
      "Product updated successfully",
    ),
    "productUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Product updated successfully",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileSectionAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "profileSectionMyActivity": MessageLookupByLibrary.simpleMessage(
      "My activity",
    ),
    "profileSectionPreferences": MessageLookupByLibrary.simpleMessage(
      "Preferences",
    ),
    "profileSectionSupport": MessageLookupByLibrary.simpleMessage("Support"),
    "profileSubtitleMessages": MessageLookupByLibrary.simpleMessage(
      "Chats with sellers",
    ),
    "profileSubtitleMyOrders": MessageLookupByLibrary.simpleMessage(
      "Recent orders",
    ),
    "profileSubtitleMyProducts": MessageLookupByLibrary.simpleMessage(
      "Listings & spare parts",
    ),
    "profileSubtitleMyServices": MessageLookupByLibrary.simpleMessage(
      "Workshops you manage",
    ),
    "promoteListingTitle": MessageLookupByLibrary.simpleMessage(
      "Promote listing",
    ),
    "promotePlanBasic": MessageLookupByLibrary.simpleMessage("Basic"),
    "promotePlanDuration": m19,
    "promotePlanPremium": MessageLookupByLibrary.simpleMessage("Premium"),
    "promotePlanStandard": MessageLookupByLibrary.simpleMessage("Standard"),
    "promotePlanVip": MessageLookupByLibrary.simpleMessage("VIP"),
    "promoteProductTitle": MessageLookupByLibrary.simpleMessage(
      "Promote product",
    ),
    "promoteServiceTitle": MessageLookupByLibrary.simpleMessage(
      "Promote service",
    ),
    "promoteWorkshopTitle": MessageLookupByLibrary.simpleMessage(
      "Promote workshop",
    ),
    "promotedBadge": MessageLookupByLibrary.simpleMessage("TOP"),
    "promotedTop": MessageLookupByLibrary.simpleMessage("Top"),
    "promotionActivatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Promotion activated successfully",
    ),
    "publicVisibility": MessageLookupByLibrary.simpleMessage("Public"),
    "publish": MessageLookupByLibrary.simpleMessage("Publish"),
    "publishProduct": MessageLookupByLibrary.simpleMessage("Publish product"),
    "pushChannelDescription": MessageLookupByLibrary.simpleMessage(
      "Chat messages, orders, workshops and deals.",
    ),
    "pushChannelName": MessageLookupByLibrary.simpleMessage("Garage alerts"),
    "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick actions"),
    "quickSellerDashboard": MessageLookupByLibrary.simpleMessage(
      "Quick dashboard",
    ),
    "range30Days": MessageLookupByLibrary.simpleMessage("30 days"),
    "range7Days": MessageLookupByLibrary.simpleMessage("7 days"),
    "range90Days": MessageLookupByLibrary.simpleMessage("90 days"),
    "recentlyViewed": MessageLookupByLibrary.simpleMessage("Recently Viewed"),
    "recentlyViewedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Pick up where you left off",
    ),
    "recommendedForYou": MessageLookupByLibrary.simpleMessage(
      "Recommended For You",
    ),
    "recommendedForYouSubtitle": MessageLookupByLibrary.simpleMessage(
      "Based on your browsing",
    ),
    "region": MessageLookupByLibrary.simpleMessage("Region"),
    "regionAndijan": MessageLookupByLibrary.simpleMessage("Andijan"),
    "regionBukhara": MessageLookupByLibrary.simpleMessage("Bukhara"),
    "regionFergana": MessageLookupByLibrary.simpleMessage("Fergana"),
    "regionJizzakh": MessageLookupByLibrary.simpleMessage("Jizzakh"),
    "regionKarakalpakstan": MessageLookupByLibrary.simpleMessage(
      "Republic of Karakalpakstan",
    ),
    "regionKashkadarya": MessageLookupByLibrary.simpleMessage("Kashkadarya"),
    "regionKhorezm": MessageLookupByLibrary.simpleMessage("Khorezm"),
    "regionNamangan": MessageLookupByLibrary.simpleMessage("Namangan"),
    "regionNavoi": MessageLookupByLibrary.simpleMessage("Navoi"),
    "regionSamarkand": MessageLookupByLibrary.simpleMessage("Samarkand"),
    "regionSurkhandarya": MessageLookupByLibrary.simpleMessage("Surkhandarya"),
    "regionSyrdarya": MessageLookupByLibrary.simpleMessage("Syrdarya"),
    "regionTashkentCity": MessageLookupByLibrary.simpleMessage("Tashkent city"),
    "regionTashkentRegion": MessageLookupByLibrary.simpleMessage(
      "Tashkent region",
    ),
    "relatedProducts": MessageLookupByLibrary.simpleMessage("Related products"),
    "relist": MessageLookupByLibrary.simpleMessage("Relist"),
    "relistTitle": MessageLookupByLibrary.simpleMessage("Return to Sale"),
    "reopenOrder": MessageLookupByLibrary.simpleMessage("Reopen request"),
    "reopenOrderConfirm": MessageLookupByLibrary.simpleMessage(
      "Show this request to sellers again?",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "requiredField": MessageLookupByLibrary.simpleMessage("Required field"),
    "resetFilters": MessageLookupByLibrary.simpleMessage("Reset"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "reviewCommentHint": MessageLookupByLibrary.simpleMessage(
      "Share your experience (optional)",
    ),
    "reviewDeleted": MessageLookupByLibrary.simpleMessage("Review deleted"),
    "reviewSubmitted": MessageLookupByLibrary.simpleMessage(
      "Thank you for your review",
    ),
    "reviewUpdated": MessageLookupByLibrary.simpleMessage("Review updated"),
    "reviewsTitle": MessageLookupByLibrary.simpleMessage("Reviews"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save changes"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchHubAdvancedProductFilters": MessageLookupByLibrary.simpleMessage(
      "Product filters",
    ),
    "searchHubAwaitingTyping": MessageLookupByLibrary.simpleMessage(
      "Start typing to search listings, workshops, orders, and sellers.",
    ),
    "searchHubCategoryIdeas": MessageLookupByLibrary.simpleMessage(
      "Popular categories",
    ),
    "searchHubEverythingHint": MessageLookupByLibrary.simpleMessage(
      "Search parts, workshops, orders, sellers…",
    ),
    "searchHubNoGroupedHits": MessageLookupByLibrary.simpleMessage(
      "No matches yet",
    ),
    "searchHubOpenMap": MessageLookupByLibrary.simpleMessage("Map"),
    "searchHubRecent": MessageLookupByLibrary.simpleMessage("Recent searches"),
    "searchHubScopeCars": MessageLookupByLibrary.simpleMessage("Cars"),
    "searchHubScopeCarsSeed": MessageLookupByLibrary.simpleMessage("car"),
    "searchHubScopeNearby": MessageLookupByLibrary.simpleMessage("Nearby"),
    "searchHubScopeOrders": MessageLookupByLibrary.simpleMessage("Orders"),
    "searchHubScopeParts": MessageLookupByLibrary.simpleMessage("Parts"),
    "searchHubScopePartsSeed": MessageLookupByLibrary.simpleMessage(
      "auto parts",
    ),
    "searchHubScopeServices": MessageLookupByLibrary.simpleMessage("Services"),
    "searchHubScopeWorkshops": MessageLookupByLibrary.simpleMessage(
      "Auto Services",
    ),
    "searchHubScopeWorkshopsSeed": MessageLookupByLibrary.simpleMessage(
      "auto service",
    ),
    "searchHubSectionOrders": MessageLookupByLibrary.simpleMessage("Requests"),
    "searchHubSectionProducts": MessageLookupByLibrary.simpleMessage(
      "Products",
    ),
    "searchHubSectionSellers": MessageLookupByLibrary.simpleMessage("Sellers"),
    "searchHubSectionServices": MessageLookupByLibrary.simpleMessage(
      "Services",
    ),
    "searchHubSectionWorkshops": MessageLookupByLibrary.simpleMessage(
      "Auto Services",
    ),
    "searchHubTrending": MessageLookupByLibrary.simpleMessage("Trending"),
    "searchHubUnifiedTitle": MessageLookupByLibrary.simpleMessage("Discover"),
    "searchHubVoiceSoon": MessageLookupByLibrary.simpleMessage(
      "Voice search is coming soon",
    ),
    "searchSellerProducts": MessageLookupByLibrary.simpleMessage(
      "Search in store",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("See All"),
    "select": MessageLookupByLibrary.simpleMessage("Select"),
    "selectBirthDay": MessageLookupByLibrary.simpleMessage("Select Birth Day"),
    "selectBrand": MessageLookupByLibrary.simpleMessage("Select brand"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Select model"),
    "selectPartCategory": MessageLookupByLibrary.simpleMessage(
      "Select part category",
    ),
    "sellerAtUsername": m20,
    "sellerBioSection": MessageLookupByLibrary.simpleMessage("About"),
    "sellerCategories": MessageLookupByLibrary.simpleMessage(
      "Seller categories",
    ),
    "sellerDashboardPreview": MessageLookupByLibrary.simpleMessage(
      "Store preview",
    ),
    "sellerDescriptionSection": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "sellerFollowersProducts": m21,
    "sellerInformation": MessageLookupByLibrary.simpleMessage(
      "Seller information",
    ),
    "sellerProfile": MessageLookupByLibrary.simpleMessage("Seller profile"),
    "sellerSince": m22,
    "sellerSinceDescription": MessageLookupByLibrary.simpleMessage(
      "Shows seller registration month and year",
    ),
    "sellerSocialLinks": MessageLookupByLibrary.simpleMessage("Social links"),
    "sellerStatActiveProducts": MessageLookupByLibrary.simpleMessage("Active"),
    "sellerStatCategories": MessageLookupByLibrary.simpleMessage("Categories"),
    "sellerStatFollowers": MessageLookupByLibrary.simpleMessage("Followers"),
    "sellerStatProducts": MessageLookupByLibrary.simpleMessage("Products"),
    "sellerStatProfileViews": MessageLookupByLibrary.simpleMessage(
      "Profile views",
    ),
    "sellerStoreEmpty": MessageLookupByLibrary.simpleMessage(
      "This seller has no products yet",
    ),
    "sellerStoreEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Follow to get notified when they list new items.",
    ),
    "serverNotWorking": MessageLookupByLibrary.simpleMessage(
      "The server is currently not working. Please try again later.",
    ),
    "service": MessageLookupByLibrary.simpleMessage("Service"),
    "serviceFeatures": MessageLookupByLibrary.simpleMessage("Features"),
    "services": MessageLookupByLibrary.simpleMessage("Services"),
    "servicesHubEmptyNearby": MessageLookupByLibrary.simpleMessage(
      "No services with location nearby yet. Open the map or add your business.",
    ),
    "servicesHubEmptyTopRated": MessageLookupByLibrary.simpleMessage(
      "No top rated services yet.",
    ),
    "servicesHubOpenMapSubtitle": MessageLookupByLibrary.simpleMessage(
      "Explore workshops and services on the map",
    ),
    "servicesHubSubtitle": MessageLookupByLibrary.simpleMessage(
      "Find verified workshops and book services online",
    ),
    "sessionExpired": MessageLookupByLibrary.simpleMessage(
      "Your session has expired. Please log in again.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shareProfile": MessageLookupByLibrary.simpleMessage("Share profile"),
    "showEmail": MessageLookupByLibrary.simpleMessage("Show email"),
    "showFollowersCount": MessageLookupByLibrary.simpleMessage(
      "Show followers count",
    ),
    "showLocationPublicly": MessageLookupByLibrary.simpleMessage(
      "Show location publicly",
    ),
    "showPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Show phone number",
    ),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signInToBookService": MessageLookupByLibrary.simpleMessage(
      "Sign in to book this service",
    ),
    "signInToContinue": MessageLookupByLibrary.simpleMessage(
      "Sign in to continue",
    ),
    "signInToContinueHint": MessageLookupByLibrary.simpleMessage(
      "Create a free account to message sellers, save favorites, and list your parts.",
    ),
    "signInToMessageBuyer": MessageLookupByLibrary.simpleMessage(
      "Sign in to message this buyer",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "similarProducts": MessageLookupByLibrary.simpleMessage("Similar Products"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "sortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
    "sortNewest": MessageLookupByLibrary.simpleMessage("Newest"),
    "sortPriceAsc": MessageLookupByLibrary.simpleMessage("Price: low → high"),
    "sortPriceDesc": MessageLookupByLibrary.simpleMessage("Price: high → low"),
    "sortPriceHighLow": MessageLookupByLibrary.simpleMessage(
      "Price: high to low",
    ),
    "sortPriceLowHigh": MessageLookupByLibrary.simpleMessage(
      "Price: low to high",
    ),
    "sortRecommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "specialOffers": MessageLookupByLibrary.simpleMessage("Special Offers"),
    "storeAnalytics": MessageLookupByLibrary.simpleMessage("Store analytics"),
    "storeCreated": MessageLookupByLibrary.simpleMessage("Store created"),
    "storeProfileCompletion": MessageLookupByLibrary.simpleMessage(
      "Store profile completion",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "submitReview": MessageLookupByLibrary.simpleMessage("Submit review"),
    "success": MessageLookupByLibrary.simpleMessage("Success"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("support@myauto.uz"),
    "supportPhone": MessageLookupByLibrary.simpleMessage("+998 95 384 10 00"),
    "termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions",
    ),
    "thirdPartySharing": MessageLookupByLibrary.simpleMessage(
      "3. Third-party Sharing",
    ),
    "thirdPartySharingText": MessageLookupByLibrary.simpleMessage(
      "We do not sell your data. We may share it with third parties only to provide our services (e.g., hosting, analytics).",
    ),
    "timeExample": MessageLookupByLibrary.simpleMessage(
      "Example: 9:00 - 18:00",
    ),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "titleOfParts": MessageLookupByLibrary.simpleMessage("Title of parts"),
    "titleOfServices": MessageLookupByLibrary.simpleMessage(
      "Title of services",
    ),
    "topCategories": MessageLookupByLibrary.simpleMessage("Top categories"),
    "topDeals": MessageLookupByLibrary.simpleMessage("Top Deals"),
    "topProducts": MessageLookupByLibrary.simpleMessage("Top products"),
    "trendingAkp": MessageLookupByLibrary.simpleMessage(
      "Automatic transmission",
    ),
    "trendingBattery": MessageLookupByLibrary.simpleMessage("Battery"),
    "trendingBrakes": MessageLookupByLibrary.simpleMessage("Brakes"),
    "trendingDetailing": MessageLookupByLibrary.simpleMessage("Detailing"),
    "trendingDiagnostics": MessageLookupByLibrary.simpleMessage("Diagnostics"),
    "trendingEngineOil": MessageLookupByLibrary.simpleMessage("Engine oil"),
    "trendingNow": MessageLookupByLibrary.simpleMessage("Trending Now"),
    "trendingNowSubtitle": MessageLookupByLibrary.simpleMessage(
      "Popular this week",
    ),
    "trendingTires": MessageLookupByLibrary.simpleMessage("Tires"),
    "trendingTowTruck": MessageLookupByLibrary.simpleMessage("Tow truck"),
    "tryAnotherSearch": MessageLookupByLibrary.simpleMessage(
      "Try another search or post a request",
    ),
    "tuning": MessageLookupByLibrary.simpleMessage("Tuning"),
    "unableToLoadStore": MessageLookupByLibrary.simpleMessage(
      "Unable to load store",
    ),
    "unfollow": MessageLookupByLibrary.simpleMessage("Unfollow"),
    "unfollowConfirm": MessageLookupByLibrary.simpleMessage(
      "Unfollow this seller?",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "used": MessageLookupByLibrary.simpleMessage("Used"),
    "user": MessageLookupByLibrary.simpleMessage("User"),
    "userAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "User already exists",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "verificationStatus": MessageLookupByLibrary.simpleMessage("Verification"),
    "verificationWhatIsIt": MessageLookupByLibrary.simpleMessage(
      "Verification confirms your store is real. Verified sellers get a badge and more buyer trust.",
    ),
    "verifiedAccountOwnerInfo": MessageLookupByLibrary.simpleMessage(
      "Your store is verified by AutoRin. Buyers see the verified badge next to your name and trust your listings more.",
    ),
    "verifiedAccountPointIdentity": MessageLookupByLibrary.simpleMessage(
      "Seller identity confirmed",
    ),
    "verifiedAccountPointTrusted": MessageLookupByLibrary.simpleMessage(
      "Trusted store on AutoRin",
    ),
    "verifiedAccountTitle": MessageLookupByLibrary.simpleMessage(
      "Verified account",
    ),
    "verifiedAccountVisitorInfo": MessageLookupByLibrary.simpleMessage(
      "AutoRin checked this seller and their store. The badge means a real, trusted seller you can buy from with more confidence.",
    ),
    "viewDetails": MessageLookupByLibrary.simpleMessage("View details"),
    "viewProfile": MessageLookupByLibrary.simpleMessage("View profile"),
    "views": MessageLookupByLibrary.simpleMessage("Views"),
    "viewsOfPhone": MessageLookupByLibrary.simpleMessage("Phone views"),
    "whatDoYouWantSell": MessageLookupByLibrary.simpleMessage(
      "What do you want to sell?",
    ),
    "withDiscount": MessageLookupByLibrary.simpleMessage("With discount"),
    "workingTime": MessageLookupByLibrary.simpleMessage("Working time"),
    "workshopAbout": MessageLookupByLibrary.simpleMessage("About"),
    "workshopDeleted": MessageLookupByLibrary.simpleMessage(
      "Workshop deleted successfully",
    ),
    "workshopFastResponse": MessageLookupByLibrary.simpleMessage(
      "Fast response",
    ),
    "workshopNearbyTitle": MessageLookupByLibrary.simpleMessage(
      "Nearby workshops",
    ),
    "workshopOnRequest": MessageLookupByLibrary.simpleMessage("On request"),
    "workshopOpenNow": MessageLookupByLibrary.simpleMessage("Open now"),
    "workshopOwnerReply": m23,
    "workshopPopular": MessageLookupByLibrary.simpleMessage("Popular"),
    "workshopPriceFrom": m24,
    "workshopScreenSubtitle": MessageLookupByLibrary.simpleMessage(
      "Trusted auto businesses near you",
    ),
    "workshopScreenTitle": MessageLookupByLibrary.simpleMessage("Workshops"),
    "workshopSearchResults": MessageLookupByLibrary.simpleMessage(
      "Search results",
    ),
    "workshopStatusClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "workshopStatusOpen": MessageLookupByLibrary.simpleMessage("Open"),
    "workshopUntitled": MessageLookupByLibrary.simpleMessage(
      "Untitled workshop",
    ),
    "workshopVerified": MessageLookupByLibrary.simpleMessage("Verified"),
    "workshopsLiveMap": MessageLookupByLibrary.simpleMessage("Live map"),
    "writeReview": MessageLookupByLibrary.simpleMessage("Write a review"),
    "writeSeller": MessageLookupByLibrary.simpleMessage("Write seller"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "youCanUploadUpTo5Photos": MessageLookupByLibrary.simpleMessage(
      "You can upload up to 5 photos",
    ),
  };
}
