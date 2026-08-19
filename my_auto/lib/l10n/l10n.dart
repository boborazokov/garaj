import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ru.dart';
import 'l10n_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @appMarketplaceTagline.
  ///
  /// In en, this message translates to:
  /// **'Garage marketplace'**
  String get appMarketplaceTagline;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field required'**
  String get fieldRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @signInToContinueHint.
  ///
  /// In en, this message translates to:
  /// **'Create a free account to message sellers, save favorites, and list your parts.'**
  String get signInToContinueHint;

  /// No description provided for @continueBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Continue browsing'**
  String get continueBrowsing;

  /// No description provided for @browseAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as guest'**
  String get browseAsGuest;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectBirthDay.
  ///
  /// In en, this message translates to:
  /// **'Select Birth Day'**
  String get selectBirthDay;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In to your account'**
  String get logIn;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get favorites;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved items yet'**
  String get favoritesEmpty;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get afternoon;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get night;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @topDeals.
  ///
  /// In en, this message translates to:
  /// **'Top Deals'**
  String get topDeals;

  /// No description provided for @whatDoYouWantSell.
  ///
  /// In en, this message translates to:
  /// **'What do you want to sell?'**
  String get whatDoYouWantSell;

  /// No description provided for @passengerCars.
  ///
  /// In en, this message translates to:
  /// **'Passenger Cars'**
  String get passengerCars;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @parts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get parts;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @tuning.
  ///
  /// In en, this message translates to:
  /// **'Tuning'**
  String get tuning;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @writeSeller.
  ///
  /// In en, this message translates to:
  /// **'Write seller'**
  String get writeSeller;

  /// No description provided for @callSeller.
  ///
  /// In en, this message translates to:
  /// **'Call the seller'**
  String get callSeller;

  /// No description provided for @myServices.
  ///
  /// In en, this message translates to:
  /// **'My Services'**
  String get myServices;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @profileSectionMyActivity.
  ///
  /// In en, this message translates to:
  /// **'My activity'**
  String get profileSectionMyActivity;

  /// No description provided for @profileSubtitleMyProducts.
  ///
  /// In en, this message translates to:
  /// **'Listings & spare parts'**
  String get profileSubtitleMyProducts;

  /// No description provided for @profileSubtitleMyServices.
  ///
  /// In en, this message translates to:
  /// **'Workshops you manage'**
  String get profileSubtitleMyServices;

  /// No description provided for @profileSubtitleMyOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get profileSubtitleMyOrders;

  /// No description provided for @profileSubtitleMessages.
  ///
  /// In en, this message translates to:
  /// **'Chats with sellers'**
  String get profileSubtitleMessages;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get helpAndSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutDescription;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to the login screen.'**
  String get logoutSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'We are committed to protecting your privacy. This policy explains how we collect, use, and protect your data.'**
  String get privacyPolicyIntro;

  /// No description provided for @dataCollection.
  ///
  /// In en, this message translates to:
  /// **'1. Data Collection'**
  String get dataCollection;

  /// No description provided for @dataCollectionText.
  ///
  /// In en, this message translates to:
  /// **'We collect personal information such as your name, email address, and phone number when you create an account or use our services.'**
  String get dataCollectionText;

  /// No description provided for @dataUsage.
  ///
  /// In en, this message translates to:
  /// **'2. Data Usage'**
  String get dataUsage;

  /// No description provided for @dataUsageText.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to provide and improve our services, personalize your experience, and communicate with you.'**
  String get dataUsageText;

  /// No description provided for @thirdPartySharing.
  ///
  /// In en, this message translates to:
  /// **'3. Third-party Sharing'**
  String get thirdPartySharing;

  /// No description provided for @thirdPartySharingText.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your data. We may share it with third parties only to provide our services (e.g., hosting, analytics).'**
  String get thirdPartySharingText;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInformation;

  /// No description provided for @contactInformationText.
  ///
  /// In en, this message translates to:
  /// **'Questions about privacy or your data: support@myauto.uz or +998 95 384 10 00.'**
  String get contactInformationText;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: June 2026'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyAccountData.
  ///
  /// In en, this message translates to:
  /// **'2. Account & listing data'**
  String get privacyAccountData;

  /// No description provided for @privacyAccountDataText.
  ///
  /// In en, this message translates to:
  /// **'We store your profile (name, phone, photo), listings (parts, workshops), messages, orders, and device tokens for push notifications. Location is optional and only used if you provide it.'**
  String get privacyAccountDataText;

  /// No description provided for @privacyDataRetention.
  ///
  /// In en, this message translates to:
  /// **'5. Data retention'**
  String get privacyDataRetention;

  /// No description provided for @privacyDataRetentionText.
  ///
  /// In en, this message translates to:
  /// **'We keep your data while your account is active. When you delete your account, personal data is removed and listings are archived.'**
  String get privacyDataRetentionText;

  /// No description provided for @privacyAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'6. Delete your account'**
  String get privacyAccountDeletion;

  /// No description provided for @privacyAccountDeletionText.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account anytime in Profile → Delete account. This permanently removes your personal information and archives your listings. This action cannot be undone.'**
  String get privacyAccountDeletionText;

  /// No description provided for @privacyChildren.
  ///
  /// In en, this message translates to:
  /// **'7. Children'**
  String get privacyChildren;

  /// No description provided for @privacyChildrenText.
  ///
  /// In en, this message translates to:
  /// **'My Auto is not intended for users under 16. We do not knowingly collect data from children.'**
  String get privacyChildrenText;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'4. Security'**
  String get privacySecurity;

  /// No description provided for @privacySecurityText.
  ///
  /// In en, this message translates to:
  /// **'We use encryption in transit (HTTPS), secure authentication, and access controls. No method is 100% secure, but we work to protect your information.'**
  String get privacySecurityText;

  /// No description provided for @privacyPolicyChanges.
  ///
  /// In en, this message translates to:
  /// **'9. Policy changes'**
  String get privacyPolicyChanges;

  /// No description provided for @privacyPolicyChangesText.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy. Continued use of the app after changes means you accept the updated policy.'**
  String get privacyPolicyChangesText;

  /// No description provided for @contactUsIntro.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help with listings, orders, and your account.'**
  String get contactUsIntro;

  /// No description provided for @contactUsEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We usually reply within 1 business day'**
  String get contactUsEmailSubtitle;

  /// No description provided for @contactUsPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat, 9:00–18:00 (Tashkent time)'**
  String get contactUsPhoneSubtitle;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@myauto.uz'**
  String get supportEmail;

  /// No description provided for @supportPhone.
  ///
  /// In en, this message translates to:
  /// **'+998 95 384 10 00'**
  String get supportPhone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete your account permanently?'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile and personal data will be removed. Your listings will be archived. This cannot be undone.'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account. Try again or contact support.'**
  String get deleteAccountFailed;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @myListingsEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active listings yet'**
  String get myListingsEmptyActive;

  /// No description provided for @myListingsEmptyInactive.
  ///
  /// In en, this message translates to:
  /// **'No archived listings'**
  String get myListingsEmptyInactive;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network settings.'**
  String get noInternetConnection;

  /// No description provided for @serverNotWorking.
  ///
  /// In en, this message translates to:
  /// **'The server is currently not working. Please try again later.'**
  String get serverNotWorking;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorOccurred;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @enterCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ve sent you a 5-digit code — enter it here to continue'**
  String get enterCodeMessage;

  /// No description provided for @confirmationCodeNeedsToBe5Symbols.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code needs to be 5 symbols'**
  String get confirmationCodeNeedsToBe5Symbols;

  /// No description provided for @invalidOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtpCode;

  /// No description provided for @userAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'User already exists'**
  String get userAlreadyExists;

  /// No description provided for @titleOfParts.
  ///
  /// In en, this message translates to:
  /// **'Title of parts'**
  String get titleOfParts;

  /// No description provided for @descriptionOfParts.
  ///
  /// In en, this message translates to:
  /// **'Description of parts'**
  String get descriptionOfParts;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceDescription.
  ///
  /// In en, this message translates to:
  /// **'Price description'**
  String get priceDescription;

  /// No description provided for @priceDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter price description here...'**
  String get priceDescriptionPlaceholder;

  /// No description provided for @maxFiveImages.
  ///
  /// In en, this message translates to:
  /// **'Max 5 images'**
  String get maxFiveImages;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get fillAllFields;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description here...'**
  String get enterDescription;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @exampleTittleParts.
  ///
  /// In en, this message translates to:
  /// **'Example: Piston'**
  String get exampleTittleParts;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get chooseLocation;

  /// No description provided for @regionAndijan.
  ///
  /// In en, this message translates to:
  /// **'Andijan'**
  String get regionAndijan;

  /// No description provided for @regionBukhara.
  ///
  /// In en, this message translates to:
  /// **'Bukhara'**
  String get regionBukhara;

  /// No description provided for @regionJizzakh.
  ///
  /// In en, this message translates to:
  /// **'Jizzakh'**
  String get regionJizzakh;

  /// No description provided for @regionKashkadarya.
  ///
  /// In en, this message translates to:
  /// **'Kashkadarya'**
  String get regionKashkadarya;

  /// No description provided for @regionNavoi.
  ///
  /// In en, this message translates to:
  /// **'Navoi'**
  String get regionNavoi;

  /// No description provided for @regionNamangan.
  ///
  /// In en, this message translates to:
  /// **'Namangan'**
  String get regionNamangan;

  /// No description provided for @regionSamarkand.
  ///
  /// In en, this message translates to:
  /// **'Samarkand'**
  String get regionSamarkand;

  /// No description provided for @regionSurkhandarya.
  ///
  /// In en, this message translates to:
  /// **'Surkhandarya'**
  String get regionSurkhandarya;

  /// No description provided for @regionSyrdarya.
  ///
  /// In en, this message translates to:
  /// **'Syrdarya'**
  String get regionSyrdarya;

  /// No description provided for @regionTashkentRegion.
  ///
  /// In en, this message translates to:
  /// **'Tashkent region'**
  String get regionTashkentRegion;

  /// No description provided for @regionFergana.
  ///
  /// In en, this message translates to:
  /// **'Fergana'**
  String get regionFergana;

  /// No description provided for @regionKhorezm.
  ///
  /// In en, this message translates to:
  /// **'Khorezm'**
  String get regionKhorezm;

  /// No description provided for @regionKarakalpakstan.
  ///
  /// In en, this message translates to:
  /// **'Republic of Karakalpakstan'**
  String get regionKarakalpakstan;

  /// No description provided for @regionTashkentCity.
  ///
  /// In en, this message translates to:
  /// **'Tashkent city'**
  String get regionTashkentCity;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @partCreated.
  ///
  /// In en, this message translates to:
  /// **'Part created successfully'**
  String get partCreated;

  /// No description provided for @forbiddenResource.
  ///
  /// In en, this message translates to:
  /// **'Forbidden resource'**
  String get forbiddenResource;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related products'**
  String get relatedProducts;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get noImages;

  /// No description provided for @sellerSince.
  ///
  /// In en, this message translates to:
  /// **'Seller on Garage since {date}'**
  String sellerSince(Object date);

  /// No description provided for @sellerSinceDescription.
  ///
  /// In en, this message translates to:
  /// **'Shows seller registration month and year'**
  String get sellerSinceDescription;

  /// No description provided for @allSellerProducts.
  ///
  /// In en, this message translates to:
  /// **'All seller’s listings >'**
  String get allSellerProducts;

  /// No description provided for @otherListingsBySeller.
  ///
  /// In en, this message translates to:
  /// **'Other listings by seller'**
  String get otherListingsBySeller;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @areYouSureToDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get areYouSureToDelete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeleted;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdated;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @availableUntil.
  ///
  /// In en, this message translates to:
  /// **'On the site until {date}'**
  String availableUntil(Object date);

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @viewsOfPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone views'**
  String get viewsOfPhone;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @depleted.
  ///
  /// In en, this message translates to:
  /// **'Depleted'**
  String get depleted;

  /// No description provided for @confirmReturnToSale.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to make this product available for sale again?'**
  String get confirmReturnToSale;

  /// No description provided for @relist.
  ///
  /// In en, this message translates to:
  /// **'Relist'**
  String get relist;

  /// No description provided for @relistTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to Sale'**
  String get relistTitle;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProductTitle;

  /// No description provided for @areYouSureToDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get areYouSureToDeleteProduct;

  /// No description provided for @postedOn.
  ///
  /// In en, this message translates to:
  /// **'Posted on {date}'**
  String postedOn(Object date);

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get addService;

  /// No description provided for @chooseLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose location on map'**
  String get chooseLocationOnMap;

  /// No description provided for @workingTime.
  ///
  /// In en, this message translates to:
  /// **'Working time'**
  String get workingTime;

  /// No description provided for @timeExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 9:00 - 18:00'**
  String get timeExample;

  /// No description provided for @titleOfServices.
  ///
  /// In en, this message translates to:
  /// **'Title of services'**
  String get titleOfServices;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @noWorkshopsFound.
  ///
  /// In en, this message translates to:
  /// **'No workshops found'**
  String get noWorkshopsFound;

  /// No description provided for @openFrom.
  ///
  /// In en, this message translates to:
  /// **'Open from'**
  String get openFrom;

  /// No description provided for @deleteWorkshopTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workshop'**
  String get deleteWorkshopTitle;

  /// No description provided for @areYouSureToDeleteWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workshop?'**
  String get areYouSureToDeleteWorkshop;

  /// No description provided for @workshopDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workshop deleted successfully'**
  String get workshopDeleted;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No yet Services'**
  String get noServices;

  /// No description provided for @noWorkshops.
  ///
  /// In en, this message translates to:
  /// **'No yet Workshops'**
  String get noWorkshops;

  /// No description provided for @noDiscount.
  ///
  /// In en, this message translates to:
  /// **'No discount'**
  String get noDiscount;

  /// No description provided for @withDiscount.
  ///
  /// In en, this message translates to:
  /// **'With discount'**
  String get withDiscount;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @newPart.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newPart;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @noAvailable.
  ///
  /// In en, this message translates to:
  /// **'No available'**
  String get noAvailable;

  /// No description provided for @modelOfCar.
  ///
  /// In en, this message translates to:
  /// **'Model of car'**
  String get modelOfCar;

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @byAgreement.
  ///
  /// In en, this message translates to:
  /// **'By agreement'**
  String get byAgreement;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @continueWithoutPhotos.
  ///
  /// In en, this message translates to:
  /// **'Continue without photos'**
  String get continueWithoutPhotos;

  /// No description provided for @youCanUploadUpTo5Photos.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to 5 photos'**
  String get youCanUploadUpTo5Photos;

  /// No description provided for @publishProduct.
  ///
  /// In en, this message translates to:
  /// **'Publish product'**
  String get publishProduct;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @productSuccessfullyPublished.
  ///
  /// In en, this message translates to:
  /// **'Product successfully published'**
  String get productSuccessfullyPublished;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @enterTitleOfPart.
  ///
  /// In en, this message translates to:
  /// **'Enter part name'**
  String get enterTitleOfPart;

  /// No description provided for @chooseCondition.
  ///
  /// In en, this message translates to:
  /// **'Please select the condition'**
  String get chooseCondition;

  /// No description provided for @chooseDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select the delivery method'**
  String get chooseDeliveryMethod;

  /// No description provided for @enterDescriptionPart.
  ///
  /// In en, this message translates to:
  /// **'Enter a detailed description of the part'**
  String get enterDescriptionPart;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkTheme;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get included;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @sellerProfile.
  ///
  /// In en, this message translates to:
  /// **'Seller profile'**
  String get sellerProfile;

  /// No description provided for @didntFindWhatYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find what you need?'**
  String get didntFindWhatYouNeed;

  /// No description provided for @createRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post a buy request and let sellers contact you.'**
  String get createRequestSubtitle;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create request'**
  String get createOrder;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @carModel.
  ///
  /// In en, this message translates to:
  /// **'Car model'**
  String get carModel;

  /// No description provided for @partCategory.
  ///
  /// In en, this message translates to:
  /// **'Part category'**
  String get partCategory;

  /// No description provided for @selectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select brand'**
  String get selectBrand;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get selectModel;

  /// No description provided for @selectPartCategory.
  ///
  /// In en, this message translates to:
  /// **'Select part category'**
  String get selectPartCategory;

  /// No description provided for @budgetOptional.
  ///
  /// In en, this message translates to:
  /// **'Budget (optional)'**
  String get budgetOptional;

  /// No description provided for @orderUrgencyTitle.
  ///
  /// In en, this message translates to:
  /// **'How urgent is it?'**
  String get orderUrgencyTitle;

  /// No description provided for @orderUrgencyHint.
  ///
  /// In en, this message translates to:
  /// **'Sellers see this on your request card.'**
  String get orderUrgencyHint;

  /// No description provided for @orderUrgencyLow.
  ///
  /// In en, this message translates to:
  /// **'Not urgent'**
  String get orderUrgencyLow;

  /// No description provided for @orderUrgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get orderUrgencyNormal;

  /// No description provided for @orderUrgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get orderUrgencyUrgent;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created successfully'**
  String get orderCreated;

  /// No description provided for @callAuthor.
  ///
  /// In en, this message translates to:
  /// **'Call author'**
  String get callAuthor;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noOrders;

  /// No description provided for @noOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'When buyers post requests, they\'ll appear here.'**
  String get noOrdersHint;

  /// No description provided for @closeOrder.
  ///
  /// In en, this message translates to:
  /// **'Close request'**
  String get closeOrder;

  /// No description provided for @closeOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this request as closed?'**
  String get closeOrderConfirm;

  /// No description provided for @reopenOrder.
  ///
  /// In en, this message translates to:
  /// **'Reopen request'**
  String get reopenOrder;

  /// No description provided for @reopenOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Show this request to sellers again?'**
  String get reopenOrderConfirm;

  /// No description provided for @orderStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orderStatusActive;

  /// No description provided for @orderStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get orderStatusClosed;

  /// No description provided for @orderDetailLookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get orderDetailLookingFor;

  /// No description provided for @orderDetailOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller offers'**
  String get orderDetailOffersTitle;

  /// No description provided for @orderDetailOffersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} offers'**
  String orderDetailOffersCount(int count);

  /// No description provided for @orderDetailNoOffers.
  ///
  /// In en, this message translates to:
  /// **'No offers yet. Sellers will propose parts and prices for your request here.'**
  String get orderDetailNoOffers;

  /// No description provided for @orderDetailSendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send offer'**
  String get orderDetailSendOffer;

  /// No description provided for @orderDetailMessageBuyer.
  ///
  /// In en, this message translates to:
  /// **'Message buyer'**
  String get orderDetailMessageBuyer;

  /// No description provided for @orderDetailYourOffer.
  ///
  /// In en, this message translates to:
  /// **'Your offer'**
  String get orderDetailYourOffer;

  /// No description provided for @orderDetailOfferMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the part you can supply for this request…'**
  String get orderDetailOfferMessageHint;

  /// No description provided for @orderDetailOfferPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Your price (optional)'**
  String get orderDetailOfferPriceHint;

  /// No description provided for @orderDetailSubmitOffer.
  ///
  /// In en, this message translates to:
  /// **'Submit offer'**
  String get orderDetailSubmitOffer;

  /// No description provided for @orderDetailChatSeller.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get orderDetailChatSeller;

  /// No description provided for @orderDetailSellerListing.
  ///
  /// In en, this message translates to:
  /// **'Seller\'s listing'**
  String get orderDetailSellerListing;

  /// No description provided for @orderDetailAlternativeListing.
  ///
  /// In en, this message translates to:
  /// **'Alternative part (seller\'s listing)'**
  String get orderDetailAlternativeListing;

  /// No description provided for @orderDetailDeliveryDays.
  ///
  /// In en, this message translates to:
  /// **'Delivery ~{days} days'**
  String orderDetailDeliveryDays(int days);

  /// No description provided for @orderDetailBudgetNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Budget negotiable'**
  String get orderDetailBudgetNegotiable;

  /// No description provided for @orderDetailPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get orderDetailPosted;

  /// No description provided for @orderDetailAcceptedOffer.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get orderDetailAcceptedOffer;

  /// No description provided for @orderDetailViewListing.
  ///
  /// In en, this message translates to:
  /// **'View listing'**
  String get orderDetailViewListing;

  /// No description provided for @orderDetailOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'Offer: {amount}'**
  String orderDetailOfferPrice(String amount);

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience (optional)'**
  String get reviewCommentHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review'**
  String get reviewSubmitted;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get editReview;

  /// No description provided for @reviewUpdated.
  ///
  /// In en, this message translates to:
  /// **'Review updated'**
  String get reviewUpdated;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get deleteReview;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete your review permanently?'**
  String get deleteReviewConfirm;

  /// No description provided for @loadMoreReviews.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreReviews;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get reviewDeleted;

  /// No description provided for @promotedTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get promotedTop;

  /// No description provided for @promotedBadge.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get promotedBadge;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @featuredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Promoted listings'**
  String get featuredSubtitle;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @priceFrom.
  ///
  /// In en, this message translates to:
  /// **'Price from'**
  String get priceFrom;

  /// No description provided for @priceTo.
  ///
  /// In en, this message translates to:
  /// **'Price to'**
  String get priceTo;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @anyRegion.
  ///
  /// In en, this message translates to:
  /// **'Any region'**
  String get anyRegion;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended For You'**
  String get recommendedForYou;

  /// No description provided for @recommendedForYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your browsing'**
  String get recommendedForYouSubtitle;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @trendingNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Popular this week'**
  String get trendingNowSubtitle;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get nearYou;

  /// No description provided for @nearYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listings in your area'**
  String get nearYouSubtitle;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentlyViewed;

  /// No description provided for @recentlyViewedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get recentlyViewedSubtitle;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @newArrivalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh listings today'**
  String get newArrivalsSubtitle;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Products'**
  String get similarProducts;

  /// No description provided for @peopleAlsoViewed.
  ///
  /// In en, this message translates to:
  /// **'People Also Viewed'**
  String get peopleAlsoViewed;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price: low → high'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price: high → low'**
  String get sortPriceDesc;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search or post a request'**
  String get tryAnotherSearch;

  /// No description provided for @createProductUnfinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t finish this listing'**
  String get createProductUnfinishedTitle;

  /// No description provided for @createProductUnfinishedHint.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue or start a new one?'**
  String get createProductUnfinishedHint;

  /// No description provided for @createProductContinueDraft.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get createProductContinueDraft;

  /// No description provided for @createProductStartNew.
  ///
  /// In en, this message translates to:
  /// **'New listing'**
  String get createProductStartNew;

  /// No description provided for @createProductUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get createProductUntitled;

  /// No description provided for @createProductExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without publishing?'**
  String get createProductExitTitle;

  /// No description provided for @createProductExitHint.
  ///
  /// In en, this message translates to:
  /// **'You can save a draft and continue later.'**
  String get createProductExitHint;

  /// No description provided for @createProductKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get createProductKeepEditing;

  /// No description provided for @createProductSaveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save and exit'**
  String get createProductSaveAndExit;

  /// No description provided for @createProductDiscardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard draft'**
  String get createProductDiscardDraft;

  /// No description provided for @createProductStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get createProductStepPhotos;

  /// No description provided for @createProductStepVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get createProductStepVehicle;

  /// No description provided for @createProductStepInfo.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get createProductStepInfo;

  /// No description provided for @createProductStepPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get createProductStepPrice;

  /// No description provided for @createProductStepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get createProductStepLocation;

  /// No description provided for @createProductStepPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get createProductStepPreview;

  /// No description provided for @createProductPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get createProductPreviewTitle;

  /// No description provided for @createProductPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how buyers will see your listing.'**
  String get createProductPreviewSubtitle;

  /// No description provided for @createProductLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is the part?'**
  String get createProductLocationTitle;

  /// No description provided for @createProductLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a point on the map so nearby buyers can find you faster.'**
  String get createProductLocationHint;

  /// No description provided for @createProductUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get createProductUseMyLocation;

  /// No description provided for @createProductConditionNewHint.
  ///
  /// In en, this message translates to:
  /// **'Factory-new, unused'**
  String get createProductConditionNewHint;

  /// No description provided for @createProductConditionUsedHint.
  ///
  /// In en, this message translates to:
  /// **'Pre-owned, in working order'**
  String get createProductConditionUsedHint;

  /// No description provided for @createProductContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get createProductContinue;

  /// No description provided for @createProductPublishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get createProductPublishNow;

  /// No description provided for @createProductUpdateListing.
  ///
  /// In en, this message translates to:
  /// **'Update listing'**
  String get createProductUpdateListing;

  /// No description provided for @createProductStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String createProductStepProgress(int current, int total);

  /// No description provided for @createProductDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get createProductDraftSaved;

  /// No description provided for @createProductPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos sell your part'**
  String get createProductPhotosTitle;

  /// No description provided for @createProductPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'First photo is the cover. Add up to 8 images.'**
  String get createProductPhotosHint;

  /// No description provided for @createProductTapAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photos'**
  String get createProductTapAddPhotos;

  /// No description provided for @createProductGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get createProductGallery;

  /// No description provided for @createProductCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get createProductCamera;

  /// No description provided for @createProductAddMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add more photos'**
  String get createProductAddMorePhotos;

  /// No description provided for @createProductCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get createProductCover;

  /// No description provided for @createProductDragReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get createProductDragReorder;

  /// No description provided for @createProductTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell faster with great photos'**
  String get createProductTrustTitle;

  /// No description provided for @createProductTrustBody.
  ///
  /// In en, this message translates to:
  /// **'Add 3+ photos, a clear title and a fair price — buyers trust complete listings.'**
  String get createProductTrustBody;

  /// No description provided for @createProductInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe your part'**
  String get createProductInfoTitle;

  /// No description provided for @createProductTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Toyota Camry brake pads — new'**
  String get createProductTitleHint;

  /// No description provided for @createProductVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Which vehicle?'**
  String get createProductVehicleTitle;

  /// No description provided for @createProductVehicleHint.
  ///
  /// In en, this message translates to:
  /// **'Helps buyers find your part faster.'**
  String get createProductVehicleHint;

  /// No description provided for @createProductRecentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get createProductRecentlyUsed;

  /// No description provided for @createProductBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get createProductBrand;

  /// No description provided for @createProductPartCategory.
  ///
  /// In en, this message translates to:
  /// **'Part category'**
  String get createProductPartCategory;

  /// No description provided for @createProductYearOptional.
  ///
  /// In en, this message translates to:
  /// **'Year (optional)'**
  String get createProductYearOptional;

  /// No description provided for @createProductSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get createProductSelect;

  /// No description provided for @createProductNoModels.
  ///
  /// In en, this message translates to:
  /// **'No models for this brand. Pick another brand or add models in admin.'**
  String get createProductNoModels;

  /// No description provided for @createProductPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your price'**
  String get createProductPriceTitle;

  /// No description provided for @createProductPriceSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested around {price} {currency}'**
  String createProductPriceSuggested(int price, String currency);

  /// No description provided for @createProductNegotiableTitle.
  ///
  /// In en, this message translates to:
  /// **'Price is negotiable'**
  String get createProductNegotiableTitle;

  /// No description provided for @createProductNegotiableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buyers can make offers'**
  String get createProductNegotiableSubtitle;

  /// No description provided for @createProductPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing… {percent}%'**
  String createProductPublishing(int percent);

  /// No description provided for @createProductPublishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing published successfully'**
  String get createProductPublishedSuccess;

  /// No description provided for @createProductOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet — you can fill the form and publish when online.'**
  String get createProductOfflineBanner;

  /// No description provided for @createProductWarnNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo'**
  String get createProductWarnNoPhotos;

  /// No description provided for @createProductWarnTitleShort.
  ///
  /// In en, this message translates to:
  /// **'Title is too short'**
  String get createProductWarnTitleShort;

  /// No description provided for @createProductWarnNoCategory.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle or category'**
  String get createProductWarnNoCategory;

  /// No description provided for @createProductWarnNoPrice.
  ///
  /// In en, this message translates to:
  /// **'Set a price'**
  String get createProductWarnNoPrice;

  /// No description provided for @createProductWarnNoCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get createProductWarnNoCurrency;

  /// No description provided for @createProductDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'You recently posted a listing with the same title'**
  String get createProductDuplicateTitle;

  /// No description provided for @createProductQuickErrorPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get createProductQuickErrorPhoto;

  /// No description provided for @createProductQuickErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (3+ characters)'**
  String get createProductQuickErrorTitle;

  /// No description provided for @createProductQuickErrorPrice.
  ///
  /// In en, this message translates to:
  /// **'Set a price'**
  String get createProductQuickErrorPrice;

  /// No description provided for @createProductOfflinePublish.
  ///
  /// In en, this message translates to:
  /// **'No internet. Draft saved — try again when online.'**
  String get createProductOfflinePublish;

  /// No description provided for @createProductErrorSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to publish listings.'**
  String get createProductErrorSignIn;

  /// No description provided for @createProductErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server. Check your connection and that the backend is running.'**
  String get createProductErrorServer;

  /// No description provided for @createProductErrorCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category (Vehicle step).'**
  String get createProductErrorCategory;

  /// No description provided for @createProductRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get createProductRetry;

  /// No description provided for @createProductOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get createProductOk;

  /// No description provided for @chatConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatConversationTitle;

  /// No description provided for @chatHeaderTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing…'**
  String get chatHeaderTyping;

  /// No description provided for @chatPeerRecentlyActive.
  ///
  /// In en, this message translates to:
  /// **'Recently active in this chat'**
  String get chatPeerRecentlyActive;

  /// No description provided for @chatPeerLastSeenInChat.
  ///
  /// In en, this message translates to:
  /// **'Last reply in chat · {time}'**
  String chatPeerLastSeenInChat(Object time);

  /// No description provided for @chatPeerNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies from them yet'**
  String get chatPeerNoMessagesYet;

  /// No description provided for @chatHeaderInChatOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'(status is for this chat only)'**
  String get chatHeaderInChatOnlyHint;

  /// No description provided for @chatJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get chatJustNow;

  /// No description provided for @chatMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String chatMinutesAgo(Object n);

  /// No description provided for @chatHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String chatHoursAgo(Object n);

  /// No description provided for @chatDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} d ago'**
  String chatDaysAgo(Object n);

  /// No description provided for @chatReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatReply;

  /// No description provided for @chatCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get chatCopy;

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chatCopied;

  /// No description provided for @chatOriginalMessageNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Original message isn\'t loaded yet. Scroll up to load more.'**
  String get chatOriginalMessageNotLoaded;

  /// No description provided for @chatSelectConversation.
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get chatSelectConversation;

  /// No description provided for @chatSelectConversationHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a chat from the list to start messaging.'**
  String get chatSelectConversationHint;

  /// No description provided for @chatMessageHintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Write a message… (Enter to send, Shift+Enter for new line)'**
  String get chatMessageHintDesktop;

  /// No description provided for @chatReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}'**
  String chatReplyingTo(String name);

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get chatMessageHint;

  /// No description provided for @chatAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get chatAttach;

  /// No description provided for @chatAttachPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photo from gallery'**
  String get chatAttachPhotos;

  /// No description provided for @chatTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get chatTakePhoto;

  /// No description provided for @chatLastPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatLastPhoto;

  /// No description provided for @chatLastVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get chatLastVoice;

  /// No description provided for @chatMicPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record voice messages.'**
  String get chatMicPermissionRequired;

  /// No description provided for @chatVoiceHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Hold to record'**
  String get chatVoiceHoldHint;

  /// No description provided for @chatVoiceSlideToCancel.
  ///
  /// In en, this message translates to:
  /// **'← Slide to cancel'**
  String get chatVoiceSlideToCancel;

  /// No description provided for @chatVoiceReleaseToCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get chatVoiceReleaseToCancel;

  /// No description provided for @searchHubUnifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get searchHubUnifiedTitle;

  /// No description provided for @searchHubEverythingHint.
  ///
  /// In en, this message translates to:
  /// **'Search parts, workshops, orders, sellers…'**
  String get searchHubEverythingHint;

  /// No description provided for @searchHubVoiceSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice search is coming soon'**
  String get searchHubVoiceSoon;

  /// No description provided for @searchHubOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get searchHubOpenMap;

  /// No description provided for @searchHubAdvancedProductFilters.
  ///
  /// In en, this message translates to:
  /// **'Product filters'**
  String get searchHubAdvancedProductFilters;

  /// No description provided for @searchHubRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchHubRecent;

  /// No description provided for @searchHubTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get searchHubTrending;

  /// No description provided for @searchHubCategoryIdeas.
  ///
  /// In en, this message translates to:
  /// **'Popular categories'**
  String get searchHubCategoryIdeas;

  /// No description provided for @searchHubAwaitingTyping.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search listings, workshops, orders, and sellers.'**
  String get searchHubAwaitingTyping;

  /// No description provided for @searchHubNoGroupedHits.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get searchHubNoGroupedHits;

  /// No description provided for @searchHubSectionProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get searchHubSectionProducts;

  /// No description provided for @searchHubSectionWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Auto Services'**
  String get searchHubSectionWorkshops;

  /// No description provided for @searchHubSectionServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get searchHubSectionServices;

  /// No description provided for @searchHubSectionOrders.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get searchHubSectionOrders;

  /// No description provided for @searchHubSectionSellers.
  ///
  /// In en, this message translates to:
  /// **'Sellers'**
  String get searchHubSectionSellers;

  /// No description provided for @homeStickyNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get homeStickyNearYou;

  /// No description provided for @homeStickyChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homeStickyChooseLocation;

  /// No description provided for @homeExploreNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Live discovery map'**
  String get homeExploreNearbyTitle;

  /// No description provided for @homeExploreNearbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workshops • listings • live requests nearby'**
  String get homeExploreNearbySubtitle;

  /// No description provided for @homeQuickActionsRow.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsRow;

  /// No description provided for @homeHotOrdersPreview.
  ///
  /// In en, this message translates to:
  /// **'Open requests nearby'**
  String get homeHotOrdersPreview;

  /// No description provided for @homeNearbyWorkshopsPreview.
  ///
  /// In en, this message translates to:
  /// **'Workshops nearby'**
  String get homeNearbyWorkshopsPreview;

  /// No description provided for @homeTrendingServicesPreview.
  ///
  /// In en, this message translates to:
  /// **'Trending services'**
  String get homeTrendingServicesPreview;

  /// No description provided for @homeSellerSpotlight.
  ///
  /// In en, this message translates to:
  /// **'Spotlight sellers'**
  String get homeSellerSpotlight;

  /// No description provided for @homeChatsPreviewSection.
  ///
  /// In en, this message translates to:
  /// **'Your conversations'**
  String get homeChatsPreviewSection;

  /// No description provided for @homeAlertsPreviewSection.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get homeAlertsPreviewSection;

  /// No description provided for @homeOpenMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get homeOpenMessages;

  /// No description provided for @homeOpenNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeOpenNotifications;

  /// No description provided for @homeListingCountHint.
  ///
  /// In en, this message translates to:
  /// **'{n} listings'**
  String homeListingCountHint(Object n);

  /// No description provided for @notificationsCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsCenterTitle;

  /// No description provided for @notificationsCenterEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Alerts about new followers, orders, workshops and deals will appear here. Your message threads stay in Messages.'**
  String get notificationsCenterEmptyBody;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts'**
  String get notificationsRecent;

  /// No description provided for @notificationsCenterFooterHint.
  ///
  /// In en, this message translates to:
  /// **'You’ll get alerts for orders, workshops and deals on this device.'**
  String get notificationsCenterFooterHint;

  /// No description provided for @notificationsAlertsOn.
  ///
  /// In en, this message translates to:
  /// **'Alerts on'**
  String get notificationsAlertsOn;

  /// No description provided for @notificationsAlertsOff.
  ///
  /// In en, this message translates to:
  /// **'Alerts off'**
  String get notificationsAlertsOff;

  /// No description provided for @notificationsEnableHint.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications so you don’t miss order and chat updates.'**
  String get notificationsEnableHint;

  /// No description provided for @notificationsEnableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsEnableButton;

  /// No description provided for @notificationsWhatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you’ll receive'**
  String get notificationsWhatYouGet;

  /// No description provided for @notificationsTopicMessages.
  ///
  /// In en, this message translates to:
  /// **'New messages and chat replies'**
  String get notificationsTopicMessages;

  /// No description provided for @notificationsTopicOrders.
  ///
  /// In en, this message translates to:
  /// **'Order status and buyer/seller updates'**
  String get notificationsTopicOrders;

  /// No description provided for @notificationsTopicWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Workshop bookings and service replies'**
  String get notificationsTopicWorkshops;

  /// No description provided for @notificationsTopicPromos.
  ///
  /// In en, this message translates to:
  /// **'Deals and featured listings'**
  String get notificationsTopicPromos;

  /// No description provided for @notificationsTopicFollowers.
  ///
  /// In en, this message translates to:
  /// **'New store followers'**
  String get notificationsTopicFollowers;

  /// No description provided for @notificationsIosSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'You can also enable alerts in Settings → Notifications → Garage.'**
  String get notificationsIosSettingsHint;

  /// No description provided for @homeNoChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get homeNoChatsYet;

  /// No description provided for @homeSeeCategoryServices.
  ///
  /// In en, this message translates to:
  /// **'See services'**
  String get homeSeeCategoryServices;

  /// No description provided for @homeQuickSellProduct.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get homeQuickSellProduct;

  /// No description provided for @homeQuickCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get homeQuickCreateOrder;

  /// No description provided for @homeQuickAddWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Auto Service'**
  String get homeQuickAddWorkshop;

  /// No description provided for @notificationsPermissionHintShort.
  ///
  /// In en, this message translates to:
  /// **'Enable alerts'**
  String get notificationsPermissionHintShort;

  /// No description provided for @searchHubScopeCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get searchHubScopeCars;

  /// No description provided for @searchHubScopeParts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get searchHubScopeParts;

  /// No description provided for @searchHubScopeServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get searchHubScopeServices;

  /// No description provided for @searchHubScopeWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Auto Services'**
  String get searchHubScopeWorkshops;

  /// No description provided for @searchHubScopeOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get searchHubScopeOrders;

  /// No description provided for @searchHubScopeNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get searchHubScopeNearby;

  /// No description provided for @searchHubScopeCarsSeed.
  ///
  /// In en, this message translates to:
  /// **'car'**
  String get searchHubScopeCarsSeed;

  /// No description provided for @searchHubScopePartsSeed.
  ///
  /// In en, this message translates to:
  /// **'auto parts'**
  String get searchHubScopePartsSeed;

  /// No description provided for @searchHubScopeWorkshopsSeed.
  ///
  /// In en, this message translates to:
  /// **'auto service'**
  String get searchHubScopeWorkshopsSeed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorAuthUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorAuthUnauthorized;

  /// No description provided for @errorAuthForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action.'**
  String get errorAuthForbidden;

  /// No description provided for @errorAuthUserExists.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered.'**
  String get errorAuthUserExists;

  /// No description provided for @errorAuthUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get errorAuthUserNotFound;

  /// No description provided for @errorAuthInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect phone or password.'**
  String get errorAuthInvalidCredentials;

  /// No description provided for @errorAuthInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get errorAuthInvalidOtp;

  /// No description provided for @errorAuthOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Request a new one.'**
  String get errorAuthOtpExpired;

  /// No description provided for @errorAuthConfirmationTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Sign-up session expired. Please register again.'**
  String get errorAuthConfirmationTokenMissing;

  /// No description provided for @errorAuthConfirmationTokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid sign-up session. Please register again.'**
  String get errorAuthConfirmationTokenInvalid;

  /// No description provided for @errorAuthConfirmationTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification expired. Request a new code.'**
  String get errorAuthConfirmationTokenExpired;

  /// No description provided for @errorAuthSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Real-time updates require a secure connection.'**
  String get errorAuthSubscriptionRequired;

  /// No description provided for @errorValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again.'**
  String get errorValidationFailed;

  /// No description provided for @errorValidationFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large.'**
  String get errorValidationFileTooLarge;

  /// No description provided for @errorValidationFileTypeInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file type is not supported.'**
  String get errorValidationFileTypeInvalid;

  /// No description provided for @errorValidationRequestTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Request is too large.'**
  String get errorValidationRequestTooLarge;

  /// No description provided for @errorValidationRequestTooComplex.
  ///
  /// In en, this message translates to:
  /// **'Request is too complex. Simplify and retry.'**
  String get errorValidationRequestTooComplex;

  /// No description provided for @errorResourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found.'**
  String get errorResourceNotFound;

  /// No description provided for @errorOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Request not found.'**
  String get errorOrderNotFound;

  /// No description provided for @errorOrderNotClosed.
  ///
  /// In en, this message translates to:
  /// **'This request is not closed.'**
  String get errorOrderNotClosed;

  /// No description provided for @errorPartNotFound.
  ///
  /// In en, this message translates to:
  /// **'Listing not found.'**
  String get errorPartNotFound;

  /// No description provided for @errorWorkshopNotFound.
  ///
  /// In en, this message translates to:
  /// **'Auto service not found.'**
  String get errorWorkshopNotFound;

  /// No description provided for @errorServiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service not found.'**
  String get errorServiceNotFound;

  /// No description provided for @errorConversationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Chat not found.'**
  String get errorConversationNotFound;

  /// No description provided for @errorMessageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Message not found.'**
  String get errorMessageNotFound;

  /// No description provided for @errorBusinessNotParticipant.
  ///
  /// In en, this message translates to:
  /// **'You are not part of this chat.'**
  String get errorBusinessNotParticipant;

  /// No description provided for @errorBusinessNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This action is not allowed.'**
  String get errorBusinessNotAllowed;

  /// No description provided for @errorBusinessCannotReviewOwn.
  ///
  /// In en, this message translates to:
  /// **'You cannot review your own listing.'**
  String get errorBusinessCannotReviewOwn;

  /// No description provided for @errorBusinessAlreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already left a review.'**
  String get errorBusinessAlreadyReviewed;

  /// No description provided for @errorBusinessCannotBookOwn.
  ///
  /// In en, this message translates to:
  /// **'You cannot book your own service.'**
  String get errorBusinessCannotBookOwn;

  /// No description provided for @errorBusinessCannotRespondOwnOrder.
  ///
  /// In en, this message translates to:
  /// **'You cannot respond to your own request.'**
  String get errorBusinessCannotRespondOwnOrder;

  /// No description provided for @errorBusinessOrderWatchDenied.
  ///
  /// In en, this message translates to:
  /// **'You cannot watch this request.'**
  String get errorBusinessOrderWatchDenied;

  /// No description provided for @errorBusinessMessageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Message is too long.'**
  String get errorBusinessMessageTooLong;

  /// No description provided for @errorBusinessRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait and try again.'**
  String get errorBusinessRateLimit;

  /// No description provided for @errorWsUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Connection not authenticated.'**
  String get errorWsUnauthenticated;

  /// No description provided for @errorWsTooManyConnections.
  ///
  /// In en, this message translates to:
  /// **'Too many active connections.'**
  String get errorWsTooManyConnections;

  /// No description provided for @errorWsHandshakeRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many connection attempts. Try again later.'**
  String get errorWsHandshakeRateLimited;

  /// No description provided for @errorWsOriginNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Connection blocked for security reasons.'**
  String get errorWsOriginNotAllowed;

  /// No description provided for @errorDeviceOffline.
  ///
  /// In en, this message translates to:
  /// **'Device is offline. Open the app to receive updates.'**
  String get errorDeviceOffline;

  /// No description provided for @errorCannotMessageSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot message yourself'**
  String get errorCannotMessageSelf;

  /// No description provided for @errorSellerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Seller is unavailable'**
  String get errorSellerUnavailable;

  /// No description provided for @errorAuthorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Author is unavailable'**
  String get errorAuthorUnavailable;

  /// No description provided for @errorNoListings.
  ///
  /// In en, this message translates to:
  /// **'No listings'**
  String get errorNoListings;

  /// No description provided for @workshopVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get workshopVerified;

  /// No description provided for @workshopOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get workshopOpenNow;

  /// No description provided for @workshopFastResponse.
  ///
  /// In en, this message translates to:
  /// **'Fast response'**
  String get workshopFastResponse;

  /// No description provided for @workshopAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get workshopAbout;

  /// No description provided for @workshopOnRequest.
  ///
  /// In en, this message translates to:
  /// **'On request'**
  String get workshopOnRequest;

  /// No description provided for @workshopPriceFrom.
  ///
  /// In en, this message translates to:
  /// **'from {amount} {currency}'**
  String workshopPriceFrom(String amount, String currency);

  /// No description provided for @workshopOwnerReply.
  ///
  /// In en, this message translates to:
  /// **'Owner: {text}'**
  String workshopOwnerReply(String text);

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @bookServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Book service'**
  String get bookServiceTitle;

  /// No description provided for @bookWorkshopRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Booking request sent'**
  String get bookWorkshopRequestSent;

  /// No description provided for @bookWorkshopCouldNotBook.
  ///
  /// In en, this message translates to:
  /// **'Could not book. Try again.'**
  String get bookWorkshopCouldNotBook;

  /// No description provided for @bookDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bookDate;

  /// No description provided for @bookTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get bookTime;

  /// No description provided for @bookDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get bookDateTime;

  /// No description provided for @bookNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes for the workshop (optional)'**
  String get bookNotesOptional;

  /// No description provided for @bookConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get bookConfirmBooking;

  /// No description provided for @bookRequestBooking.
  ///
  /// In en, this message translates to:
  /// **'Request booking'**
  String get bookRequestBooking;

  /// No description provided for @bookServiceOptional.
  ///
  /// In en, this message translates to:
  /// **'Service (optional)'**
  String get bookServiceOptional;

  /// No description provided for @bookServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Oil change, diagnostics…'**
  String get bookServiceHint;

  /// No description provided for @bookNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get bookNotes;

  /// No description provided for @chatNoConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatNoConversationsYet;

  /// No description provided for @chatSayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get chatSayHello;

  /// No description provided for @chatReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get chatReconnecting;

  /// No description provided for @mapLayerWorkshops.
  ///
  /// In en, this message translates to:
  /// **'Workshops'**
  String get mapLayerWorkshops;

  /// No description provided for @mapLayerRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get mapLayerRequests;

  /// No description provided for @mapFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters & map'**
  String get mapFiltersTitle;

  /// No description provided for @mapHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Density heatmap'**
  String get mapHeatmapTitle;

  /// No description provided for @mapHeatmapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight areas with more listings'**
  String get mapHeatmapSubtitle;

  /// No description provided for @mapShownOnMap.
  ///
  /// In en, this message translates to:
  /// **'Shown on map'**
  String get mapShownOnMap;

  /// No description provided for @mapQuickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick filters'**
  String get mapQuickFilters;

  /// No description provided for @mapAllWorkshops.
  ///
  /// In en, this message translates to:
  /// **'All workshops'**
  String get mapAllWorkshops;

  /// No description provided for @mapSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get mapSearchRadius;

  /// No description provided for @mapOpenPin.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mapOpenPin;

  /// No description provided for @mapRouteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get mapRouteTooltip;

  /// No description provided for @mapShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get mapShareTooltip;

  /// No description provided for @mapLocationDefaultArea.
  ///
  /// In en, this message translates to:
  /// **'Using default map area — enable location for best results'**
  String get mapLocationDefaultArea;

  /// No description provided for @mapLocationGpsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on location (GPS) in device settings'**
  String get mapLocationGpsDisabled;

  /// No description provided for @mapLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your position'**
  String get mapLocationPermissionRequired;

  /// No description provided for @mapLocationPermissionForever.
  ///
  /// In en, this message translates to:
  /// **'Allow location in app settings'**
  String get mapLocationPermissionForever;

  /// No description provided for @mapLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location'**
  String get mapLocationFailed;

  /// No description provided for @mapFilterOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get mapFilterOpenNow;

  /// No description provided for @mapFilterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get mapFilterNearby;

  /// No description provided for @mapFilterVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get mapFilterVerified;

  /// No description provided for @mapFilterTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get mapFilterTopRated;

  /// No description provided for @mapFilterPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get mapFilterPremium;

  /// No description provided for @workshopScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Workshops'**
  String get workshopScreenTitle;

  /// No description provided for @workshopScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted auto businesses near you'**
  String get workshopScreenSubtitle;

  /// No description provided for @servicesHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find verified workshops and book services online'**
  String get servicesHubSubtitle;

  /// No description provided for @servicesHubEmptyNearby.
  ///
  /// In en, this message translates to:
  /// **'No services with location nearby yet. Open the map or add your business.'**
  String get servicesHubEmptyNearby;

  /// No description provided for @servicesHubEmptyTopRated.
  ///
  /// In en, this message translates to:
  /// **'No top rated services yet.'**
  String get servicesHubEmptyTopRated;

  /// No description provided for @servicesHubOpenMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore workshops and services on the map'**
  String get servicesHubOpenMapSubtitle;

  /// No description provided for @workshopPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get workshopPopular;

  /// No description provided for @workshopNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby workshops'**
  String get workshopNearbyTitle;

  /// No description provided for @workshopSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get workshopSearchResults;

  /// No description provided for @workshopsLiveMap.
  ///
  /// In en, this message translates to:
  /// **'Live map'**
  String get workshopsLiveMap;

  /// No description provided for @trendingTires.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get trendingTires;

  /// No description provided for @trendingDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get trendingDiagnostics;

  /// No description provided for @trendingEngineOil.
  ///
  /// In en, this message translates to:
  /// **'Engine oil'**
  String get trendingEngineOil;

  /// No description provided for @trendingTowTruck.
  ///
  /// In en, this message translates to:
  /// **'Tow truck'**
  String get trendingTowTruck;

  /// No description provided for @trendingDetailing.
  ///
  /// In en, this message translates to:
  /// **'Detailing'**
  String get trendingDetailing;

  /// No description provided for @trendingAkp.
  ///
  /// In en, this message translates to:
  /// **'Automatic transmission'**
  String get trendingAkp;

  /// No description provided for @trendingBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get trendingBattery;

  /// No description provided for @trendingBrakes.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get trendingBrakes;

  /// No description provided for @orderPartEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get orderPartEngine;

  /// No description provided for @orderPartBumper.
  ///
  /// In en, this message translates to:
  /// **'Bumper'**
  String get orderPartBumper;

  /// No description provided for @orderPartHeadlights.
  ///
  /// In en, this message translates to:
  /// **'Headlights'**
  String get orderPartHeadlights;

  /// No description provided for @orderPartBrakes.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get orderPartBrakes;

  /// No description provided for @orderPartSuspension.
  ///
  /// In en, this message translates to:
  /// **'Suspension'**
  String get orderPartSuspension;

  /// No description provided for @orderDetailNeedsPart.
  ///
  /// In en, this message translates to:
  /// **'Need: {part}'**
  String orderDetailNeedsPart(String part);

  /// No description provided for @serviceFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get serviceFeatures;

  /// No description provided for @signInToBookService.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book this service'**
  String get signInToBookService;

  /// No description provided for @signInToMessageBuyer.
  ///
  /// In en, this message translates to:
  /// **'Sign in to message this buyer'**
  String get signInToMessageBuyer;

  /// No description provided for @badgeVerified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get badgeVerified;

  /// No description provided for @badgePremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get badgePremium;

  /// No description provided for @badgeFast.
  ///
  /// In en, this message translates to:
  /// **'FAST'**
  String get badgeFast;

  /// No description provided for @badgeTopRated.
  ///
  /// In en, this message translates to:
  /// **'TOP RATED'**
  String get badgeTopRated;

  /// No description provided for @createWorkshopServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select services you offer'**
  String get createWorkshopServicesTitle;

  /// No description provided for @createWorkshopPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get createWorkshopPopular;

  /// No description provided for @createWorkshopAllServices.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get createWorkshopAllServices;

  /// No description provided for @createWorkshopServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Service types ({count}). Pick all that apply to your business.'**
  String createWorkshopServicesHint(int count);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get shareProfile;

  /// No description provided for @sellerFollowersProducts.
  ///
  /// In en, this message translates to:
  /// **'{followers} followers • {products} products • Joined {date}'**
  String sellerFollowersProducts(
      String followers, String products, String date);

  /// No description provided for @sellerStatProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get sellerStatProducts;

  /// No description provided for @sellerStatCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get sellerStatCategories;

  /// No description provided for @sellerStatFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get sellerStatFollowers;

  /// No description provided for @noFollowersYet.
  ///
  /// In en, this message translates to:
  /// **'No followers yet'**
  String get noFollowersYet;

  /// No description provided for @followedOn.
  ///
  /// In en, this message translates to:
  /// **'Followed on {date}'**
  String followedOn(String date);

  /// No description provided for @sellerStatProfileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile views'**
  String get sellerStatProfileViews;

  /// No description provided for @sellerStatActiveProducts.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sellerStatActiveProducts;

  /// No description provided for @sellerCategories.
  ///
  /// In en, this message translates to:
  /// **'Seller categories'**
  String get sellerCategories;

  /// No description provided for @sellerBioSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sellerBioSection;

  /// No description provided for @sellerDescriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sellerDescriptionSection;

  /// No description provided for @sellerSocialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get sellerSocialLinks;

  /// No description provided for @sellerInformation.
  ///
  /// In en, this message translates to:
  /// **'Seller information'**
  String get sellerInformation;

  /// No description provided for @latestProducts.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestProducts;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularProducts;

  /// No description provided for @searchSellerProducts.
  ///
  /// In en, this message translates to:
  /// **'Search in store'**
  String get searchSellerProducts;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHighLow;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @moreFromSeller.
  ///
  /// In en, this message translates to:
  /// **'More from this seller'**
  String get moreFromSeller;

  /// No description provided for @sellerStoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'This seller has no products yet'**
  String get sellerStoreEmpty;

  /// No description provided for @sellerStoreEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Follow to get notified when they list new items.'**
  String get sellerStoreEmptyHint;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @showLocationPublicly.
  ///
  /// In en, this message translates to:
  /// **'Show location publicly'**
  String get showLocationPublicly;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get privacySettings;

  /// No description provided for @showPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Show phone number'**
  String get showPhoneNumber;

  /// No description provided for @showEmail.
  ///
  /// In en, this message translates to:
  /// **'Show email'**
  String get showEmail;

  /// No description provided for @showFollowersCount.
  ///
  /// In en, this message translates to:
  /// **'Show followers count'**
  String get showFollowersCount;

  /// No description provided for @allowMessages.
  ///
  /// In en, this message translates to:
  /// **'Allow messages'**
  String get allowMessages;

  /// No description provided for @sellerDashboardPreview.
  ///
  /// In en, this message translates to:
  /// **'Store preview'**
  String get sellerDashboardPreview;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @publicVisibility.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicVisibility;

  /// No description provided for @privateVisibility.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateVisibility;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @sellerAtUsername.
  ///
  /// In en, this message translates to:
  /// **'@{username}'**
  String sellerAtUsername(String username);

  /// No description provided for @editStore.
  ///
  /// In en, this message translates to:
  /// **'Edit store'**
  String get editStore;

  /// No description provided for @manageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage products'**
  String get manageProducts;

  /// No description provided for @storeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Store analytics'**
  String get storeAnalytics;

  /// No description provided for @unableToLoadStore.
  ///
  /// In en, this message translates to:
  /// **'Unable to load store'**
  String get unableToLoadStore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @storeProfileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Store profile completion'**
  String get storeProfileCompletion;

  /// No description provided for @missingFields.
  ///
  /// In en, this message translates to:
  /// **'Missing:'**
  String get missingFields;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfile;

  /// No description provided for @missingAvatar.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get missingAvatar;

  /// No description provided for @missingStoreBanner.
  ///
  /// In en, this message translates to:
  /// **'Store banner'**
  String get missingStoreBanner;

  /// No description provided for @missingBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get missingBio;

  /// No description provided for @missingDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get missingDescription;

  /// No description provided for @missingSocialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get missingSocialLinks;

  /// No description provided for @missingLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get missingLocation;

  /// No description provided for @missingUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get missingUsername;

  /// No description provided for @changeBanner.
  ///
  /// In en, this message translates to:
  /// **'Change banner'**
  String get changeBanner;

  /// No description provided for @quickSellerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Quick dashboard'**
  String get quickSellerDashboard;

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardToday;

  /// No description provided for @dashboardProductViews.
  ///
  /// In en, this message translates to:
  /// **'Product views'**
  String get dashboardProductViews;

  /// No description provided for @dashboardMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get dashboardMessages;

  /// No description provided for @dashboardNewFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get dashboardNewFollowers;

  /// No description provided for @dashboardProductsSold.
  ///
  /// In en, this message translates to:
  /// **'Products sold'**
  String get dashboardProductsSold;

  /// No description provided for @openAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Open analytics'**
  String get openAnalytics;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product management'**
  String get productManagement;

  /// No description provided for @draftProducts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftProducts;

  /// No description provided for @archivedProducts.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedProducts;

  /// No description provided for @pendingModeration.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingModeration;

  /// No description provided for @storeCreated.
  ///
  /// In en, this message translates to:
  /// **'Store created'**
  String get storeCreated;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationStatus;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @verifiedAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified account'**
  String get verifiedAccountTitle;

  /// No description provided for @verifiedAccountVisitorInfo.
  ///
  /// In en, this message translates to:
  /// **'AutoRin checked this seller and their store. The badge means a real, trusted seller you can buy from with more confidence.'**
  String get verifiedAccountVisitorInfo;

  /// No description provided for @verifiedAccountOwnerInfo.
  ///
  /// In en, this message translates to:
  /// **'Your store is verified by AutoRin. Buyers see the verified badge next to your name and trust your listings more.'**
  String get verifiedAccountOwnerInfo;

  /// No description provided for @verifiedAccountPointIdentity.
  ///
  /// In en, this message translates to:
  /// **'Seller identity confirmed'**
  String get verifiedAccountPointIdentity;

  /// No description provided for @verifiedAccountPointTrusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted store on AutoRin'**
  String get verifiedAccountPointTrusted;

  /// No description provided for @verificationWhatIsIt.
  ///
  /// In en, this message translates to:
  /// **'Verification confirms your store is real. Verified sellers get a badge and more buyer trust.'**
  String get verificationWhatIsIt;

  /// No description provided for @contactPreferences.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactPreferences;

  /// No description provided for @messagesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Messages disabled'**
  String get messagesDisabled;

  /// No description provided for @ownerStoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no products yet'**
  String get ownerStoreEmpty;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add first product'**
  String get addFirstProduct;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @unfollowConfirm.
  ///
  /// In en, this message translates to:
  /// **'Unfollow this seller?'**
  String get unfollowConfirm;

  /// No description provided for @range7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get range7Days;

  /// No description provided for @range30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get range30Days;

  /// No description provided for @range90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get range90Days;

  /// No description provided for @dashboardLeads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get dashboardLeads;

  /// No description provided for @productClicks.
  ///
  /// In en, this message translates to:
  /// **'Product clicks'**
  String get productClicks;

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top products'**
  String get topProducts;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get topCategories;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chats;

  /// No description provided for @myStore.
  ///
  /// In en, this message translates to:
  /// **'My store'**
  String get myStore;

  /// No description provided for @ownerMyListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get ownerMyListings;

  /// No description provided for @myListingsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total listings'**
  String get myListingsTotalLabel;

  /// No description provided for @myListingsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{activeLabel} · {activeCount} · {inactiveLabel} · {inactiveCount}'**
  String myListingsBreakdown(String activeLabel, int activeCount,
      String inactiveLabel, int inactiveCount);

  /// No description provided for @workshopUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled workshop'**
  String get workshopUntitled;

  /// No description provided for @workshopStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get workshopStatusOpen;

  /// No description provided for @workshopStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get workshopStatusClosed;

  /// No description provided for @promoteListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote listing'**
  String get promoteListingTitle;

  /// No description provided for @promoteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote product'**
  String get promoteProductTitle;

  /// No description provided for @promoteWorkshopTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote workshop'**
  String get promoteWorkshopTitle;

  /// No description provided for @promoteServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote service'**
  String get promoteServiceTitle;

  /// No description provided for @promotePlanBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get promotePlanBasic;

  /// No description provided for @promotePlanStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get promotePlanStandard;

  /// No description provided for @promotePlanPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get promotePlanPremium;

  /// No description provided for @promotePlanVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get promotePlanVip;

  /// No description provided for @promotePlanDuration.
  ///
  /// In en, this message translates to:
  /// **'{days} days · priority {priority}'**
  String promotePlanDuration(int days, int priority);

  /// No description provided for @activatePromotion.
  ///
  /// In en, this message translates to:
  /// **'Activate promotion'**
  String get activatePromotion;

  /// No description provided for @promotionActivatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promotion activated successfully'**
  String get promotionActivatedSuccess;

  /// No description provided for @notificationAccountVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'You are verified'**
  String get notificationAccountVerifiedTitle;

  /// No description provided for @notificationAccountVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is now verified by the AutoRin team.'**
  String get notificationAccountVerifiedBody;

  /// No description provided for @notificationNewFollowerTitle.
  ///
  /// In en, this message translates to:
  /// **'New follower'**
  String get notificationNewFollowerTitle;

  /// No description provided for @notificationNewFollowerBody.
  ///
  /// In en, this message translates to:
  /// **'Someone started following your store.'**
  String get notificationNewFollowerBody;

  /// No description provided for @notificationOrderReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Order update'**
  String get notificationOrderReplyTitle;

  /// No description provided for @notificationPromotedExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion ended'**
  String get notificationPromotedExpiredTitle;

  /// No description provided for @notificationPromotedExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your listing is no longer promoted. Renew to stay on top.'**
  String get notificationPromotedExpiredBody;

  /// No description provided for @notificationFavoriteMatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Price match'**
  String get notificationFavoriteMatchedTitle;

  /// No description provided for @notificationFavoriteMatchedBody.
  ///
  /// In en, this message translates to:
  /// **'A saved listing matches what you were looking for.'**
  String get notificationFavoriteMatchedBody;

  /// No description provided for @notificationSellerResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller replied'**
  String get notificationSellerResponseTitle;

  /// No description provided for @notificationNewMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get notificationNewMessageTitle;

  /// No description provided for @notificationNewMessageBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the conversation.'**
  String get notificationNewMessageBody;

  /// No description provided for @notificationOrderReplyBody.
  ///
  /// In en, this message translates to:
  /// **'There is an update on your order.'**
  String get notificationOrderReplyBody;

  /// No description provided for @notificationWorkshopBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Workshop booking'**
  String get notificationWorkshopBookingTitle;

  /// No description provided for @notificationWorkshopBookingBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new booking or service reply.'**
  String get notificationWorkshopBookingBody;

  /// No description provided for @notificationGenericAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get notificationGenericAlertTitle;

  /// No description provided for @notificationGenericAlertBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new alert.'**
  String get notificationGenericAlertBody;

  /// No description provided for @pushChannelName.
  ///
  /// In en, this message translates to:
  /// **'Garage alerts'**
  String get pushChannelName;

  /// No description provided for @pushChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat messages, orders, workshops and deals.'**
  String get pushChannelDescription;

  /// No description provided for @notificationOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notificationOpenAction;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ru':
      return SRu();
    case 'uz':
      return SUz();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
