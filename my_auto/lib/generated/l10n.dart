// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Garage`
  String get appTitle {
    return Intl.message('Garage', name: 'appTitle', desc: '', args: []);
  }

  /// `Hi, {name}`
  String homeGreeting(String name) {
    return Intl.message(
      'Hi, $name',
      name: 'homeGreeting',
      desc: '',
      args: [name],
    );
  }

  /// `Garage marketplace`
  String get appMarketplaceTagline {
    return Intl.message(
      'Garage marketplace',
      name: 'appMarketplaceTagline',
      desc: '',
      args: [],
    );
  }

  /// `Field required`
  String get fieldRequired {
    return Intl.message(
      'Field required',
      name: 'fieldRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Password must be at least 6 characters`
  String get passwordLength {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordLength',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Sign In`
  String get signIn {
    return Intl.message('Sign In', name: 'signIn', desc: '', args: []);
  }

  /// `Sign in to continue`
  String get signInToContinue {
    return Intl.message(
      'Sign in to continue',
      name: 'signInToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Create a free account to message sellers, save favorites, and list your parts.`
  String get signInToContinueHint {
    return Intl.message(
      'Create a free account to message sellers, save favorites, and list your parts.',
      name: 'signInToContinueHint',
      desc: '',
      args: [],
    );
  }

  /// `Continue browsing`
  String get continueBrowsing {
    return Intl.message(
      'Continue browsing',
      name: 'continueBrowsing',
      desc: '',
      args: [],
    );
  }

  /// `Browse as guest`
  String get browseAsGuest {
    return Intl.message(
      'Browse as guest',
      name: 'browseAsGuest',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Guest`
  String get guest {
    return Intl.message('Guest', name: 'guest', desc: '', args: []);
  }

  /// `Don't have an account?`
  String get noAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message('Sign Up', name: 'signUp', desc: '', args: []);
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Select Birth Day`
  String get selectBirthDay {
    return Intl.message(
      'Select Birth Day',
      name: 'selectBirthDay',
      desc: '',
      args: [],
    );
  }

  /// `Log In to your account`
  String get logIn {
    return Intl.message(
      'Log In to your account',
      name: 'logIn',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Services`
  String get services {
    return Intl.message('Services', name: 'services', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Order`
  String get order {
    return Intl.message('Order', name: 'order', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Saved`
  String get favorites {
    return Intl.message('Saved', name: 'favorites', desc: '', args: []);
  }

  /// `No saved items yet`
  String get favoritesEmpty {
    return Intl.message(
      'No saved items yet',
      name: 'favoritesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Good Morning`
  String get morning {
    return Intl.message('Good Morning', name: 'morning', desc: '', args: []);
  }

  /// `Good Afternoon`
  String get afternoon {
    return Intl.message(
      'Good Afternoon',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good Night`
  String get night {
    return Intl.message('Good Night', name: 'night', desc: '', args: []);
  }

  /// `Special Offers`
  String get specialOffers {
    return Intl.message(
      'Special Offers',
      name: 'specialOffers',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message('See All', name: 'seeAll', desc: '', args: []);
  }

  /// `Top Deals`
  String get topDeals {
    return Intl.message('Top Deals', name: 'topDeals', desc: '', args: []);
  }

  /// `What do you want to sell?`
  String get whatDoYouWantSell {
    return Intl.message(
      'What do you want to sell?',
      name: 'whatDoYouWantSell',
      desc: '',
      args: [],
    );
  }

  /// `Passenger Cars`
  String get passengerCars {
    return Intl.message(
      'Passenger Cars',
      name: 'passengerCars',
      desc: '',
      args: [],
    );
  }

  /// `Service`
  String get service {
    return Intl.message('Service', name: 'service', desc: '', args: []);
  }

  /// `Parts`
  String get parts {
    return Intl.message('Parts', name: 'parts', desc: '', args: []);
  }

  /// `Announcements`
  String get announcements {
    return Intl.message(
      'Announcements',
      name: 'announcements',
      desc: '',
      args: [],
    );
  }

  /// `Tuning`
  String get tuning {
    return Intl.message('Tuning', name: 'tuning', desc: '', args: []);
  }

  /// `Account Details`
  String get accountDetails {
    return Intl.message(
      'Account Details',
      name: 'accountDetails',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `My Orders`
  String get myOrders {
    return Intl.message('My Orders', name: 'myOrders', desc: '', args: []);
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Write seller`
  String get writeSeller {
    return Intl.message(
      'Write seller',
      name: 'writeSeller',
      desc: '',
      args: [],
    );
  }

  /// `Call the seller`
  String get callSeller {
    return Intl.message(
      'Call the seller',
      name: 'callSeller',
      desc: '',
      args: [],
    );
  }

  /// `My Services`
  String get myServices {
    return Intl.message('My Services', name: 'myServices', desc: '', args: []);
  }

  /// `My Products`
  String get myProducts {
    return Intl.message('My Products', name: 'myProducts', desc: '', args: []);
  }

  /// `My activity`
  String get profileSectionMyActivity {
    return Intl.message(
      'My activity',
      name: 'profileSectionMyActivity',
      desc: '',
      args: [],
    );
  }

  /// `Listings & spare parts`
  String get profileSubtitleMyProducts {
    return Intl.message(
      'Listings & spare parts',
      name: 'profileSubtitleMyProducts',
      desc: '',
      args: [],
    );
  }

  /// `Workshops you manage`
  String get profileSubtitleMyServices {
    return Intl.message(
      'Workshops you manage',
      name: 'profileSubtitleMyServices',
      desc: '',
      args: [],
    );
  }

  /// `Recent orders`
  String get profileSubtitleMyOrders {
    return Intl.message(
      'Recent orders',
      name: 'profileSubtitleMyOrders',
      desc: '',
      args: [],
    );
  }

  /// `Chats with sellers`
  String get profileSubtitleMessages {
    return Intl.message(
      'Chats with sellers',
      name: 'profileSubtitleMessages',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get profileSectionPreferences {
    return Intl.message(
      'Preferences',
      name: 'profileSectionPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get profileSectionSupport {
    return Intl.message(
      'Support',
      name: 'profileSectionSupport',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message('Contact Us', name: 'contactUs', desc: '', args: []);
  }

  /// `Terms and Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Help and Support`
  String get helpAndSupport {
    return Intl.message(
      'Help and Support',
      name: 'helpAndSupport',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Are you sure you want to log out?`
  String get logoutDescription {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logoutDescription',
      desc: '',
      args: [],
    );
  }

  /// `You will be redirected to the login screen.`
  String get logoutSubtitle {
    return Intl.message(
      'You will be redirected to the login screen.',
      name: 'logoutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `We are committed to protecting your privacy. This policy explains how we collect, use, and protect your data.`
  String get privacyPolicyIntro {
    return Intl.message(
      'We are committed to protecting your privacy. This policy explains how we collect, use, and protect your data.',
      name: 'privacyPolicyIntro',
      desc: '',
      args: [],
    );
  }

  /// `1. Data Collection`
  String get dataCollection {
    return Intl.message(
      '1. Data Collection',
      name: 'dataCollection',
      desc: '',
      args: [],
    );
  }

  /// `We collect personal information such as your name, email address, and phone number when you create an account or use our services.`
  String get dataCollectionText {
    return Intl.message(
      'We collect personal information such as your name, email address, and phone number when you create an account or use our services.',
      name: 'dataCollectionText',
      desc: '',
      args: [],
    );
  }

  /// `2. Data Usage`
  String get dataUsage {
    return Intl.message('2. Data Usage', name: 'dataUsage', desc: '', args: []);
  }

  /// `Your data is used to provide and improve our services, personalize your experience, and communicate with you.`
  String get dataUsageText {
    return Intl.message(
      'Your data is used to provide and improve our services, personalize your experience, and communicate with you.',
      name: 'dataUsageText',
      desc: '',
      args: [],
    );
  }

  /// `3. Third-party Sharing`
  String get thirdPartySharing {
    return Intl.message(
      '3. Third-party Sharing',
      name: 'thirdPartySharing',
      desc: '',
      args: [],
    );
  }

  /// `We do not sell your data. We may share it with third parties only to provide our services (e.g., hosting, analytics).`
  String get thirdPartySharingText {
    return Intl.message(
      'We do not sell your data. We may share it with third parties only to provide our services (e.g., hosting, analytics).',
      name: 'thirdPartySharingText',
      desc: '',
      args: [],
    );
  }

  /// `Contact information`
  String get contactInformation {
    return Intl.message(
      'Contact information',
      name: 'contactInformation',
      desc: '',
      args: [],
    );
  }

  /// `Questions about privacy or your data: support@myauto.uz or +998 95 384 10 00.`
  String get contactInformationText {
    return Intl.message(
      'Questions about privacy or your data: support@myauto.uz or +998 95 384 10 00.',
      name: 'contactInformationText',
      desc: '',
      args: [],
    );
  }

  /// `Last updated: June 2026`
  String get privacyPolicyLastUpdated {
    return Intl.message(
      'Last updated: June 2026',
      name: 'privacyPolicyLastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `2. Account & listing data`
  String get privacyAccountData {
    return Intl.message(
      '2. Account & listing data',
      name: 'privacyAccountData',
      desc: '',
      args: [],
    );
  }

  /// `We store your profile (name, phone, photo), listings (parts, workshops), messages, orders, and device tokens for push notifications. Location is optional and only used if you provide it.`
  String get privacyAccountDataText {
    return Intl.message(
      'We store your profile (name, phone, photo), listings (parts, workshops), messages, orders, and device tokens for push notifications. Location is optional and only used if you provide it.',
      name: 'privacyAccountDataText',
      desc: '',
      args: [],
    );
  }

  /// `5. Data retention`
  String get privacyDataRetention {
    return Intl.message(
      '5. Data retention',
      name: 'privacyDataRetention',
      desc: '',
      args: [],
    );
  }

  /// `We keep your data while your account is active. When you delete your account, personal data is removed and listings are archived.`
  String get privacyDataRetentionText {
    return Intl.message(
      'We keep your data while your account is active. When you delete your account, personal data is removed and listings are archived.',
      name: 'privacyDataRetentionText',
      desc: '',
      args: [],
    );
  }

  /// `6. Delete your account`
  String get privacyAccountDeletion {
    return Intl.message(
      '6. Delete your account',
      name: 'privacyAccountDeletion',
      desc: '',
      args: [],
    );
  }

  /// `You can delete your account anytime in Profile → Delete account. This permanently removes your personal information and archives your listings. This action cannot be undone.`
  String get privacyAccountDeletionText {
    return Intl.message(
      'You can delete your account anytime in Profile → Delete account. This permanently removes your personal information and archives your listings. This action cannot be undone.',
      name: 'privacyAccountDeletionText',
      desc: '',
      args: [],
    );
  }

  /// `7. Children`
  String get privacyChildren {
    return Intl.message(
      '7. Children',
      name: 'privacyChildren',
      desc: '',
      args: [],
    );
  }

  /// `My Auto is not intended for users under 16. We do not knowingly collect data from children.`
  String get privacyChildrenText {
    return Intl.message(
      'My Auto is not intended for users under 16. We do not knowingly collect data from children.',
      name: 'privacyChildrenText',
      desc: '',
      args: [],
    );
  }

  /// `4. Security`
  String get privacySecurity {
    return Intl.message(
      '4. Security',
      name: 'privacySecurity',
      desc: '',
      args: [],
    );
  }

  /// `We use encryption in transit (HTTPS), secure authentication, and access controls. No method is 100% secure, but we work to protect your information.`
  String get privacySecurityText {
    return Intl.message(
      'We use encryption in transit (HTTPS), secure authentication, and access controls. No method is 100% secure, but we work to protect your information.',
      name: 'privacySecurityText',
      desc: '',
      args: [],
    );
  }

  /// `9. Policy changes`
  String get privacyPolicyChanges {
    return Intl.message(
      '9. Policy changes',
      name: 'privacyPolicyChanges',
      desc: '',
      args: [],
    );
  }

  /// `We may update this policy. Continued use of the app after changes means you accept the updated policy.`
  String get privacyPolicyChangesText {
    return Intl.message(
      'We may update this policy. Continued use of the app after changes means you accept the updated policy.',
      name: 'privacyPolicyChangesText',
      desc: '',
      args: [],
    );
  }

  /// `We're here to help with listings, orders, and your account.`
  String get contactUsIntro {
    return Intl.message(
      'We\'re here to help with listings, orders, and your account.',
      name: 'contactUsIntro',
      desc: '',
      args: [],
    );
  }

  /// `We usually reply within 1 business day`
  String get contactUsEmailSubtitle {
    return Intl.message(
      'We usually reply within 1 business day',
      name: 'contactUsEmailSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Mon–Sat, 9:00–18:00 (Tashkent time)`
  String get contactUsPhoneSubtitle {
    return Intl.message(
      'Mon–Sat, 9:00–18:00 (Tashkent time)',
      name: 'contactUsPhoneSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `support@myauto.uz`
  String get supportEmail {
    return Intl.message(
      'support@myauto.uz',
      name: 'supportEmail',
      desc: '',
      args: [],
    );
  }

  /// `+998 95 384 10 00`
  String get supportPhone {
    return Intl.message(
      '+998 95 384 10 00',
      name: 'supportPhone',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get deleteAccount {
    return Intl.message(
      'Delete account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete your account permanently?`
  String get deleteAccountDescription {
    return Intl.message(
      'Delete your account permanently?',
      name: 'deleteAccountDescription',
      desc: '',
      args: [],
    );
  }

  /// `Your profile and personal data will be removed. Your listings will be archived. This cannot be undone.`
  String get deleteAccountSubtitle {
    return Intl.message(
      'Your profile and personal data will be removed. Your listings will be archived. This cannot be undone.',
      name: 'deleteAccountSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete permanently`
  String get deleteAccountConfirm {
    return Intl.message(
      'Delete permanently',
      name: 'deleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been deleted`
  String get deleteAccountSuccess {
    return Intl.message(
      'Your account has been deleted',
      name: 'deleteAccountSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Could not delete account. Try again or contact support.`
  String get deleteAccountFailed {
    return Intl.message(
      'Could not delete account. Try again or contact support.',
      name: 'deleteAccountFailed',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get profileSectionAccount {
    return Intl.message(
      'Account',
      name: 'profileSectionAccount',
      desc: '',
      args: [],
    );
  }

  /// `No active listings yet`
  String get myListingsEmptyActive {
    return Intl.message(
      'No active listings yet',
      name: 'myListingsEmptyActive',
      desc: '',
      args: [],
    );
  }

  /// `No archived listings`
  String get myListingsEmptyInactive {
    return Intl.message(
      'No archived listings',
      name: 'myListingsEmptyInactive',
      desc: '',
      args: [],
    );
  }

  /// `Your session has expired. Please log in again.`
  String get sessionExpired {
    return Intl.message(
      'Your session has expired. Please log in again.',
      name: 'sessionExpired',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection. Please check your network settings.`
  String get noInternetConnection {
    return Intl.message(
      'No internet connection. Please check your network settings.',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `The server is currently not working. Please try again later.`
  String get serverNotWorking {
    return Intl.message(
      'The server is currently not working. Please try again later.',
      name: 'serverNotWorking',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred. Please try again later.`
  String get errorOccurred {
    return Intl.message(
      'An error occurred. Please try again later.',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Info`
  String get info {
    return Intl.message('Info', name: 'info', desc: '', args: []);
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: '', args: []);
  }

  /// `We’ve sent you a 5-digit code — enter it here to continue`
  String get enterCodeMessage {
    return Intl.message(
      'We’ve sent you a 5-digit code — enter it here to continue',
      name: 'enterCodeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation code needs to be 5 symbols`
  String get confirmationCodeNeedsToBe5Symbols {
    return Intl.message(
      'Confirmation code needs to be 5 symbols',
      name: 'confirmationCodeNeedsToBe5Symbols',
      desc: '',
      args: [],
    );
  }

  /// `Invalid OTP code`
  String get invalidOtpCode {
    return Intl.message(
      'Invalid OTP code',
      name: 'invalidOtpCode',
      desc: '',
      args: [],
    );
  }

  /// `User already exists`
  String get userAlreadyExists {
    return Intl.message(
      'User already exists',
      name: 'userAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Title of parts`
  String get titleOfParts {
    return Intl.message(
      'Title of parts',
      name: 'titleOfParts',
      desc: '',
      args: [],
    );
  }

  /// `Description of parts`
  String get descriptionOfParts {
    return Intl.message(
      'Description of parts',
      name: 'descriptionOfParts',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Price description`
  String get priceDescription {
    return Intl.message(
      'Price description',
      name: 'priceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter price description here...`
  String get priceDescriptionPlaceholder {
    return Intl.message(
      'Enter price description here...',
      name: 'priceDescriptionPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Max 5 images`
  String get maxFiveImages {
    return Intl.message(
      'Max 5 images',
      name: 'maxFiveImages',
      desc: '',
      args: [],
    );
  }

  /// `Fill all fields`
  String get fillAllFields {
    return Intl.message(
      'Fill all fields',
      name: 'fillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Add product`
  String get addProduct {
    return Intl.message('Add product', name: 'addProduct', desc: '', args: []);
  }

  /// `Required field`
  String get requiredField {
    return Intl.message(
      'Required field',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Enter description here...`
  String get enterDescription {
    return Intl.message(
      'Enter description here...',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Choose category`
  String get chooseCategory {
    return Intl.message(
      'Choose category',
      name: 'chooseCategory',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message('Required', name: 'required', desc: '', args: []);
  }

  /// `Example: Piston`
  String get exampleTittleParts {
    return Intl.message(
      'Example: Piston',
      name: 'exampleTittleParts',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Choose location`
  String get chooseLocation {
    return Intl.message(
      'Choose location',
      name: 'chooseLocation',
      desc: '',
      args: [],
    );
  }

  /// `Andijan`
  String get regionAndijan {
    return Intl.message('Andijan', name: 'regionAndijan', desc: '', args: []);
  }

  /// `Bukhara`
  String get regionBukhara {
    return Intl.message('Bukhara', name: 'regionBukhara', desc: '', args: []);
  }

  /// `Jizzakh`
  String get regionJizzakh {
    return Intl.message('Jizzakh', name: 'regionJizzakh', desc: '', args: []);
  }

  /// `Kashkadarya`
  String get regionKashkadarya {
    return Intl.message(
      'Kashkadarya',
      name: 'regionKashkadarya',
      desc: '',
      args: [],
    );
  }

  /// `Navoi`
  String get regionNavoi {
    return Intl.message('Navoi', name: 'regionNavoi', desc: '', args: []);
  }

  /// `Namangan`
  String get regionNamangan {
    return Intl.message('Namangan', name: 'regionNamangan', desc: '', args: []);
  }

  /// `Samarkand`
  String get regionSamarkand {
    return Intl.message(
      'Samarkand',
      name: 'regionSamarkand',
      desc: '',
      args: [],
    );
  }

  /// `Surkhandarya`
  String get regionSurkhandarya {
    return Intl.message(
      'Surkhandarya',
      name: 'regionSurkhandarya',
      desc: '',
      args: [],
    );
  }

  /// `Syrdarya`
  String get regionSyrdarya {
    return Intl.message('Syrdarya', name: 'regionSyrdarya', desc: '', args: []);
  }

  /// `Tashkent region`
  String get regionTashkentRegion {
    return Intl.message(
      'Tashkent region',
      name: 'regionTashkentRegion',
      desc: '',
      args: [],
    );
  }

  /// `Fergana`
  String get regionFergana {
    return Intl.message('Fergana', name: 'regionFergana', desc: '', args: []);
  }

  /// `Khorezm`
  String get regionKhorezm {
    return Intl.message('Khorezm', name: 'regionKhorezm', desc: '', args: []);
  }

  /// `Republic of Karakalpakstan`
  String get regionKarakalpakstan {
    return Intl.message(
      'Republic of Karakalpakstan',
      name: 'regionKarakalpakstan',
      desc: '',
      args: [],
    );
  }

  /// `Tashkent city`
  String get regionTashkentCity {
    return Intl.message(
      'Tashkent city',
      name: 'regionTashkentCity',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Part created successfully`
  String get partCreated {
    return Intl.message(
      'Part created successfully',
      name: 'partCreated',
      desc: '',
      args: [],
    );
  }

  /// `Forbidden resource`
  String get forbiddenResource {
    return Intl.message(
      'Forbidden resource',
      name: 'forbiddenResource',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Images`
  String get images {
    return Intl.message('Images', name: 'images', desc: '', args: []);
  }

  /// `User`
  String get user {
    return Intl.message('User', name: 'user', desc: '', args: []);
  }

  /// `Related products`
  String get relatedProducts {
    return Intl.message(
      'Related products',
      name: 'relatedProducts',
      desc: '',
      args: [],
    );
  }

  /// `No images`
  String get noImages {
    return Intl.message('No images', name: 'noImages', desc: '', args: []);
  }

  /// `Seller on Garage since {date}`
  String sellerSince(Object date) {
    return Intl.message(
      'Seller on Garage since $date',
      name: 'sellerSince',
      desc: '',
      args: [date],
    );
  }

  /// `Shows seller registration month and year`
  String get sellerSinceDescription {
    return Intl.message(
      'Shows seller registration month and year',
      name: 'sellerSinceDescription',
      desc: '',
      args: [],
    );
  }

  /// `All seller’s listings >`
  String get allSellerProducts {
    return Intl.message(
      'All seller’s listings >',
      name: 'allSellerProducts',
      desc: '',
      args: [],
    );
  }

  /// `Other listings by seller`
  String get otherListingsBySeller {
    return Intl.message(
      'Other listings by seller',
      name: 'otherListingsBySeller',
      desc: '',
      args: [],
    );
  }

  /// `No products`
  String get noProducts {
    return Intl.message('No products', name: 'noProducts', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Are you sure you want to delete?`
  String get areYouSureToDelete {
    return Intl.message(
      'Are you sure you want to delete?',
      name: 'areYouSureToDelete',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Product deleted successfully`
  String get productDeleted {
    return Intl.message(
      'Product deleted successfully',
      name: 'productDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Product updated successfully`
  String get productUpdated {
    return Intl.message(
      'Product updated successfully',
      name: 'productUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `On the site until {date}`
  String availableUntil(Object date) {
    return Intl.message(
      'On the site until $date',
      name: 'availableUntil',
      desc: '',
      args: [date],
    );
  }

  /// `Views`
  String get views {
    return Intl.message('Views', name: 'views', desc: '', args: []);
  }

  /// `Phone views`
  String get viewsOfPhone {
    return Intl.message(
      'Phone views',
      name: 'viewsOfPhone',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Inactive`
  String get inactive {
    return Intl.message('Inactive', name: 'inactive', desc: '', args: []);
  }

  /// `Depleted`
  String get depleted {
    return Intl.message('Depleted', name: 'depleted', desc: '', args: []);
  }

  /// `Are you sure you want to make this product available for sale again?`
  String get confirmReturnToSale {
    return Intl.message(
      'Are you sure you want to make this product available for sale again?',
      name: 'confirmReturnToSale',
      desc: '',
      args: [],
    );
  }

  /// `Relist`
  String get relist {
    return Intl.message('Relist', name: 'relist', desc: '', args: []);
  }

  /// `Return to Sale`
  String get relistTitle {
    return Intl.message(
      'Return to Sale',
      name: 'relistTitle',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Delete product`
  String get deleteProductTitle {
    return Intl.message(
      'Delete product',
      name: 'deleteProductTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this product?`
  String get areYouSureToDeleteProduct {
    return Intl.message(
      'Are you sure you want to delete this product?',
      name: 'areYouSureToDeleteProduct',
      desc: '',
      args: [],
    );
  }

  /// `Posted on {date}`
  String postedOn(Object date) {
    return Intl.message(
      'Posted on $date',
      name: 'postedOn',
      desc: '',
      args: [date],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Add service`
  String get addService {
    return Intl.message('Add service', name: 'addService', desc: '', args: []);
  }

  /// `Choose location on map`
  String get chooseLocationOnMap {
    return Intl.message(
      'Choose location on map',
      name: 'chooseLocationOnMap',
      desc: '',
      args: [],
    );
  }

  /// `Working time`
  String get workingTime {
    return Intl.message(
      'Working time',
      name: 'workingTime',
      desc: '',
      args: [],
    );
  }

  /// `Example: 9:00 - 18:00`
  String get timeExample {
    return Intl.message(
      'Example: 9:00 - 18:00',
      name: 'timeExample',
      desc: '',
      args: [],
    );
  }

  /// `Title of services`
  String get titleOfServices {
    return Intl.message(
      'Title of services',
      name: 'titleOfServices',
      desc: '',
      args: [],
    );
  }

  /// `Edit Service`
  String get editService {
    return Intl.message(
      'Edit Service',
      name: 'editService',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `All products`
  String get allProducts {
    return Intl.message(
      'All products',
      name: 'allProducts',
      desc: '',
      args: [],
    );
  }

  /// `No workshops found`
  String get noWorkshopsFound {
    return Intl.message(
      'No workshops found',
      name: 'noWorkshopsFound',
      desc: '',
      args: [],
    );
  }

  /// `Open from`
  String get openFrom {
    return Intl.message('Open from', name: 'openFrom', desc: '', args: []);
  }

  /// `Delete workshop`
  String get deleteWorkshopTitle {
    return Intl.message(
      'Delete workshop',
      name: 'deleteWorkshopTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this workshop?`
  String get areYouSureToDeleteWorkshop {
    return Intl.message(
      'Are you sure you want to delete this workshop?',
      name: 'areYouSureToDeleteWorkshop',
      desc: '',
      args: [],
    );
  }

  /// `Workshop deleted successfully`
  String get workshopDeleted {
    return Intl.message(
      'Workshop deleted successfully',
      name: 'workshopDeleted',
      desc: '',
      args: [],
    );
  }

  /// `No yet Services`
  String get noServices {
    return Intl.message(
      'No yet Services',
      name: 'noServices',
      desc: '',
      args: [],
    );
  }

  /// `No yet Workshops`
  String get noWorkshops {
    return Intl.message(
      'No yet Workshops',
      name: 'noWorkshops',
      desc: '',
      args: [],
    );
  }

  /// `No discount`
  String get noDiscount {
    return Intl.message('No discount', name: 'noDiscount', desc: '', args: []);
  }

  /// `With discount`
  String get withDiscount {
    return Intl.message(
      'With discount',
      name: 'withDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Condition`
  String get condition {
    return Intl.message('Condition', name: 'condition', desc: '', args: []);
  }

  /// `New`
  String get newPart {
    return Intl.message('New', name: 'newPart', desc: '', args: []);
  }

  /// `Used`
  String get used {
    return Intl.message('Used', name: 'used', desc: '', args: []);
  }

  /// `Delivery`
  String get delivery {
    return Intl.message('Delivery', name: 'delivery', desc: '', args: []);
  }

  /// `Available`
  String get available {
    return Intl.message('Available', name: 'available', desc: '', args: []);
  }

  /// `No available`
  String get noAvailable {
    return Intl.message(
      'No available',
      name: 'noAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Model of car`
  String get modelOfCar {
    return Intl.message('Model of car', name: 'modelOfCar', desc: '', args: []);
  }

  /// `Negotiable`
  String get negotiable {
    return Intl.message('Negotiable', name: 'negotiable', desc: '', args: []);
  }

  /// `By agreement`
  String get byAgreement {
    return Intl.message(
      'By agreement',
      name: 'byAgreement',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Photos`
  String get photos {
    return Intl.message('Photos', name: 'photos', desc: '', args: []);
  }

  /// `Enter price`
  String get enterPrice {
    return Intl.message('Enter price', name: 'enterPrice', desc: '', args: []);
  }

  /// `Add photo`
  String get addPhoto {
    return Intl.message('Add photo', name: 'addPhoto', desc: '', args: []);
  }

  /// `Continue without photos`
  String get continueWithoutPhotos {
    return Intl.message(
      'Continue without photos',
      name: 'continueWithoutPhotos',
      desc: '',
      args: [],
    );
  }

  /// `You can upload up to 5 photos`
  String get youCanUploadUpTo5Photos {
    return Intl.message(
      'You can upload up to 5 photos',
      name: 'youCanUploadUpTo5Photos',
      desc: '',
      args: [],
    );
  }

  /// `Publish product`
  String get publishProduct {
    return Intl.message(
      'Publish product',
      name: 'publishProduct',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get publish {
    return Intl.message('Publish', name: 'publish', desc: '', args: []);
  }

  /// `Product successfully published`
  String get productSuccessfullyPublished {
    return Intl.message(
      'Product successfully published',
      name: 'productSuccessfullyPublished',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get productDetails {
    return Intl.message(
      'Product Details',
      name: 'productDetails',
      desc: '',
      args: [],
    );
  }

  /// `Enter part name`
  String get enterTitleOfPart {
    return Intl.message(
      'Enter part name',
      name: 'enterTitleOfPart',
      desc: '',
      args: [],
    );
  }

  /// `Please select the condition`
  String get chooseCondition {
    return Intl.message(
      'Please select the condition',
      name: 'chooseCondition',
      desc: '',
      args: [],
    );
  }

  /// `Please select the delivery method`
  String get chooseDeliveryMethod {
    return Intl.message(
      'Please select the delivery method',
      name: 'chooseDeliveryMethod',
      desc: '',
      args: [],
    );
  }

  /// `Enter a detailed description of the part`
  String get enterDescriptionPart {
    return Intl.message(
      'Enter a detailed description of the part',
      name: 'enterDescriptionPart',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get darkTheme {
    return Intl.message('Dark mode', name: 'darkTheme', desc: '', args: []);
  }

  /// `Included`
  String get included {
    return Intl.message('Included', name: 'included', desc: '', args: []);
  }

  /// `Out of stock`
  String get outOfStock {
    return Intl.message('Out of stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `View details`
  String get viewDetails {
    return Intl.message(
      'View details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Product updated successfully`
  String get productUpdatedSuccessfully {
    return Intl.message(
      'Product updated successfully',
      name: 'productUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Seller profile`
  String get sellerProfile {
    return Intl.message(
      'Seller profile',
      name: 'sellerProfile',
      desc: '',
      args: [],
    );
  }

  /// `Didn't find what you need?`
  String get didntFindWhatYouNeed {
    return Intl.message(
      'Didn\'t find what you need?',
      name: 'didntFindWhatYouNeed',
      desc: '',
      args: [],
    );
  }

  /// `Post a buy request and let sellers contact you.`
  String get createRequestSubtitle {
    return Intl.message(
      'Post a buy request and let sellers contact you.',
      name: 'createRequestSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Create Request`
  String get createRequest {
    return Intl.message(
      'Create Request',
      name: 'createRequest',
      desc: '',
      args: [],
    );
  }

  /// `Create request`
  String get createOrder {
    return Intl.message(
      'Create request',
      name: 'createOrder',
      desc: '',
      args: [],
    );
  }

  /// `My requests`
  String get myRequests {
    return Intl.message('My requests', name: 'myRequests', desc: '', args: []);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Phone number`
  String get phoneNumber {
    return Intl.message(
      'Phone number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Brand`
  String get brand {
    return Intl.message('Brand', name: 'brand', desc: '', args: []);
  }

  /// `Car model`
  String get carModel {
    return Intl.message('Car model', name: 'carModel', desc: '', args: []);
  }

  /// `Part category`
  String get partCategory {
    return Intl.message(
      'Part category',
      name: 'partCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select brand`
  String get selectBrand {
    return Intl.message(
      'Select brand',
      name: 'selectBrand',
      desc: '',
      args: [],
    );
  }

  /// `Select model`
  String get selectModel {
    return Intl.message(
      'Select model',
      name: 'selectModel',
      desc: '',
      args: [],
    );
  }

  /// `Select part category`
  String get selectPartCategory {
    return Intl.message(
      'Select part category',
      name: 'selectPartCategory',
      desc: '',
      args: [],
    );
  }

  /// `Budget (optional)`
  String get budgetOptional {
    return Intl.message(
      'Budget (optional)',
      name: 'budgetOptional',
      desc: '',
      args: [],
    );
  }

  /// `How urgent is it?`
  String get orderUrgencyTitle {
    return Intl.message(
      'How urgent is it?',
      name: 'orderUrgencyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sellers see this on your request card.`
  String get orderUrgencyHint {
    return Intl.message(
      'Sellers see this on your request card.',
      name: 'orderUrgencyHint',
      desc: '',
      args: [],
    );
  }

  /// `Not urgent`
  String get orderUrgencyLow {
    return Intl.message(
      'Not urgent',
      name: 'orderUrgencyLow',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get orderUrgencyNormal {
    return Intl.message(
      'Normal',
      name: 'orderUrgencyNormal',
      desc: '',
      args: [],
    );
  }

  /// `Urgent`
  String get orderUrgencyUrgent {
    return Intl.message(
      'Urgent',
      name: 'orderUrgencyUrgent',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Request created successfully`
  String get orderCreated {
    return Intl.message(
      'Request created successfully',
      name: 'orderCreated',
      desc: '',
      args: [],
    );
  }

  /// `Call author`
  String get callAuthor {
    return Intl.message('Call author', name: 'callAuthor', desc: '', args: []);
  }

  /// `No requests yet`
  String get noOrders {
    return Intl.message(
      'No requests yet',
      name: 'noOrders',
      desc: '',
      args: [],
    );
  }

  /// `When buyers post requests, they'll appear here.`
  String get noOrdersHint {
    return Intl.message(
      'When buyers post requests, they\'ll appear here.',
      name: 'noOrdersHint',
      desc: '',
      args: [],
    );
  }

  /// `Close request`
  String get closeOrder {
    return Intl.message(
      'Close request',
      name: 'closeOrder',
      desc: '',
      args: [],
    );
  }

  /// `Mark this request as closed?`
  String get closeOrderConfirm {
    return Intl.message(
      'Mark this request as closed?',
      name: 'closeOrderConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Reopen request`
  String get reopenOrder {
    return Intl.message(
      'Reopen request',
      name: 'reopenOrder',
      desc: '',
      args: [],
    );
  }

  /// `Show this request to sellers again?`
  String get reopenOrderConfirm {
    return Intl.message(
      'Show this request to sellers again?',
      name: 'reopenOrderConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get orderStatusActive {
    return Intl.message(
      'Active',
      name: 'orderStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get orderStatusClosed {
    return Intl.message(
      'Closed',
      name: 'orderStatusClosed',
      desc: '',
      args: [],
    );
  }

  /// `Looking for`
  String get orderDetailLookingFor {
    return Intl.message(
      'Looking for',
      name: 'orderDetailLookingFor',
      desc: '',
      args: [],
    );
  }

  /// `Seller offers`
  String get orderDetailOffersTitle {
    return Intl.message(
      'Seller offers',
      name: 'orderDetailOffersTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} offers`
  String orderDetailOffersCount(int count) {
    return Intl.message(
      '$count offers',
      name: 'orderDetailOffersCount',
      desc: '',
      args: [count],
    );
  }

  /// `No offers yet. Sellers will propose parts and prices for your request here.`
  String get orderDetailNoOffers {
    return Intl.message(
      'No offers yet. Sellers will propose parts and prices for your request here.',
      name: 'orderDetailNoOffers',
      desc: '',
      args: [],
    );
  }

  /// `Send offer`
  String get orderDetailSendOffer {
    return Intl.message(
      'Send offer',
      name: 'orderDetailSendOffer',
      desc: '',
      args: [],
    );
  }

  /// `Message buyer`
  String get orderDetailMessageBuyer {
    return Intl.message(
      'Message buyer',
      name: 'orderDetailMessageBuyer',
      desc: '',
      args: [],
    );
  }

  /// `Your offer`
  String get orderDetailYourOffer {
    return Intl.message(
      'Your offer',
      name: 'orderDetailYourOffer',
      desc: '',
      args: [],
    );
  }

  /// `Describe the part you can supply for this request…`
  String get orderDetailOfferMessageHint {
    return Intl.message(
      'Describe the part you can supply for this request…',
      name: 'orderDetailOfferMessageHint',
      desc: '',
      args: [],
    );
  }

  /// `Your price (optional)`
  String get orderDetailOfferPriceHint {
    return Intl.message(
      'Your price (optional)',
      name: 'orderDetailOfferPriceHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit offer`
  String get orderDetailSubmitOffer {
    return Intl.message(
      'Submit offer',
      name: 'orderDetailSubmitOffer',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get orderDetailChatSeller {
    return Intl.message(
      'Chat',
      name: 'orderDetailChatSeller',
      desc: '',
      args: [],
    );
  }

  /// `Seller's listing`
  String get orderDetailSellerListing {
    return Intl.message(
      'Seller\'s listing',
      name: 'orderDetailSellerListing',
      desc: '',
      args: [],
    );
  }

  /// `Alternative part (seller's listing)`
  String get orderDetailAlternativeListing {
    return Intl.message(
      'Alternative part (seller\'s listing)',
      name: 'orderDetailAlternativeListing',
      desc: '',
      args: [],
    );
  }

  /// `Delivery ~{days} days`
  String orderDetailDeliveryDays(int days) {
    return Intl.message(
      'Delivery ~$days days',
      name: 'orderDetailDeliveryDays',
      desc: '',
      args: [days],
    );
  }

  /// `Budget negotiable`
  String get orderDetailBudgetNegotiable {
    return Intl.message(
      'Budget negotiable',
      name: 'orderDetailBudgetNegotiable',
      desc: '',
      args: [],
    );
  }

  /// `Posted`
  String get orderDetailPosted {
    return Intl.message(
      'Posted',
      name: 'orderDetailPosted',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get orderDetailAcceptedOffer {
    return Intl.message(
      'Accepted',
      name: 'orderDetailAcceptedOffer',
      desc: '',
      args: [],
    );
  }

  /// `View listing`
  String get orderDetailViewListing {
    return Intl.message(
      'View listing',
      name: 'orderDetailViewListing',
      desc: '',
      args: [],
    );
  }

  /// `Offer: {amount}`
  String orderDetailOfferPrice(String amount) {
    return Intl.message(
      'Offer: $amount',
      name: 'orderDetailOfferPrice',
      desc: '',
      args: [amount],
    );
  }

  /// `Write a review`
  String get writeReview {
    return Intl.message(
      'Write a review',
      name: 'writeReview',
      desc: '',
      args: [],
    );
  }

  /// `Share your experience (optional)`
  String get reviewCommentHint {
    return Intl.message(
      'Share your experience (optional)',
      name: 'reviewCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit review`
  String get submitReview {
    return Intl.message(
      'Submit review',
      name: 'submitReview',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get reviewsTitle {
    return Intl.message('Reviews', name: 'reviewsTitle', desc: '', args: []);
  }

  /// `No reviews yet`
  String get noReviewsYet {
    return Intl.message(
      'No reviews yet',
      name: 'noReviewsYet',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your review`
  String get reviewSubmitted {
    return Intl.message(
      'Thank you for your review',
      name: 'reviewSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Edit review`
  String get editReview {
    return Intl.message('Edit review', name: 'editReview', desc: '', args: []);
  }

  /// `Review updated`
  String get reviewUpdated {
    return Intl.message(
      'Review updated',
      name: 'reviewUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Delete review`
  String get deleteReview {
    return Intl.message(
      'Delete review',
      name: 'deleteReview',
      desc: '',
      args: [],
    );
  }

  /// `Delete your review permanently?`
  String get deleteReviewConfirm {
    return Intl.message(
      'Delete your review permanently?',
      name: 'deleteReviewConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get loadMoreReviews {
    return Intl.message(
      'Load more',
      name: 'loadMoreReviews',
      desc: '',
      args: [],
    );
  }

  /// `Review deleted`
  String get reviewDeleted {
    return Intl.message(
      'Review deleted',
      name: 'reviewDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Top`
  String get promotedTop {
    return Intl.message('Top', name: 'promotedTop', desc: '', args: []);
  }

  /// `TOP`
  String get promotedBadge {
    return Intl.message('TOP', name: 'promotedBadge', desc: '', args: []);
  }

  /// `Featured`
  String get featured {
    return Intl.message('Featured', name: 'featured', desc: '', args: []);
  }

  /// `Promoted listings`
  String get featuredSubtitle {
    return Intl.message(
      'Promoted listings',
      name: 'featuredSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get filters {
    return Intl.message('Filters', name: 'filters', desc: '', args: []);
  }

  /// `Apply`
  String get applyFilters {
    return Intl.message('Apply', name: 'applyFilters', desc: '', args: []);
  }

  /// `Reset`
  String get resetFilters {
    return Intl.message('Reset', name: 'resetFilters', desc: '', args: []);
  }

  /// `Price from`
  String get priceFrom {
    return Intl.message('Price from', name: 'priceFrom', desc: '', args: []);
  }

  /// `Price to`
  String get priceTo {
    return Intl.message('Price to', name: 'priceTo', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Region`
  String get region {
    return Intl.message('Region', name: 'region', desc: '', args: []);
  }

  /// `Any region`
  String get anyRegion {
    return Intl.message('Any region', name: 'anyRegion', desc: '', args: []);
  }

  /// `Sort by`
  String get sortBy {
    return Intl.message('Sort by', name: 'sortBy', desc: '', args: []);
  }

  /// `Recommended`
  String get sortRecommended {
    return Intl.message(
      'Recommended',
      name: 'sortRecommended',
      desc: '',
      args: [],
    );
  }

  /// `Recommended For You`
  String get recommendedForYou {
    return Intl.message(
      'Recommended For You',
      name: 'recommendedForYou',
      desc: '',
      args: [],
    );
  }

  /// `Based on your browsing`
  String get recommendedForYouSubtitle {
    return Intl.message(
      'Based on your browsing',
      name: 'recommendedForYouSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Trending Now`
  String get trendingNow {
    return Intl.message(
      'Trending Now',
      name: 'trendingNow',
      desc: '',
      args: [],
    );
  }

  /// `Popular this week`
  String get trendingNowSubtitle {
    return Intl.message(
      'Popular this week',
      name: 'trendingNowSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Near You`
  String get nearYou {
    return Intl.message('Near You', name: 'nearYou', desc: '', args: []);
  }

  /// `Listings in your area`
  String get nearYouSubtitle {
    return Intl.message(
      'Listings in your area',
      name: 'nearYouSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Recently Viewed`
  String get recentlyViewed {
    return Intl.message(
      'Recently Viewed',
      name: 'recentlyViewed',
      desc: '',
      args: [],
    );
  }

  /// `Pick up where you left off`
  String get recentlyViewedSubtitle {
    return Intl.message(
      'Pick up where you left off',
      name: 'recentlyViewedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `New Arrivals`
  String get newArrivals {
    return Intl.message(
      'New Arrivals',
      name: 'newArrivals',
      desc: '',
      args: [],
    );
  }

  /// `Fresh listings today`
  String get newArrivalsSubtitle {
    return Intl.message(
      'Fresh listings today',
      name: 'newArrivalsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Similar Products`
  String get similarProducts {
    return Intl.message(
      'Similar Products',
      name: 'similarProducts',
      desc: '',
      args: [],
    );
  }

  /// `People Also Viewed`
  String get peopleAlsoViewed {
    return Intl.message(
      'People Also Viewed',
      name: 'peopleAlsoViewed',
      desc: '',
      args: [],
    );
  }

  /// `Newest`
  String get sortNewest {
    return Intl.message('Newest', name: 'sortNewest', desc: '', args: []);
  }

  /// `Price: low → high`
  String get sortPriceAsc {
    return Intl.message(
      'Price: low → high',
      name: 'sortPriceAsc',
      desc: '',
      args: [],
    );
  }

  /// `Price: high → low`
  String get sortPriceDesc {
    return Intl.message(
      'Price: high → low',
      name: 'sortPriceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Try another search or post a request`
  String get tryAnotherSearch {
    return Intl.message(
      'Try another search or post a request',
      name: 'tryAnotherSearch',
      desc: '',
      args: [],
    );
  }

  /// `You didn't finish this listing`
  String get createProductUnfinishedTitle {
    return Intl.message(
      'You didn\'t finish this listing',
      name: 'createProductUnfinishedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to continue or start a new one?`
  String get createProductUnfinishedHint {
    return Intl.message(
      'Do you want to continue or start a new one?',
      name: 'createProductUnfinishedHint',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get createProductContinueDraft {
    return Intl.message(
      'Continue',
      name: 'createProductContinueDraft',
      desc: '',
      args: [],
    );
  }

  /// `New listing`
  String get createProductStartNew {
    return Intl.message(
      'New listing',
      name: 'createProductStartNew',
      desc: '',
      args: [],
    );
  }

  /// `Untitled`
  String get createProductUntitled {
    return Intl.message(
      'Untitled',
      name: 'createProductUntitled',
      desc: '',
      args: [],
    );
  }

  /// `Leave without publishing?`
  String get createProductExitTitle {
    return Intl.message(
      'Leave without publishing?',
      name: 'createProductExitTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can save a draft and continue later.`
  String get createProductExitHint {
    return Intl.message(
      'You can save a draft and continue later.',
      name: 'createProductExitHint',
      desc: '',
      args: [],
    );
  }

  /// `Keep editing`
  String get createProductKeepEditing {
    return Intl.message(
      'Keep editing',
      name: 'createProductKeepEditing',
      desc: '',
      args: [],
    );
  }

  /// `Save and exit`
  String get createProductSaveAndExit {
    return Intl.message(
      'Save and exit',
      name: 'createProductSaveAndExit',
      desc: '',
      args: [],
    );
  }

  /// `Discard draft`
  String get createProductDiscardDraft {
    return Intl.message(
      'Discard draft',
      name: 'createProductDiscardDraft',
      desc: '',
      args: [],
    );
  }

  /// `Photos`
  String get createProductStepPhotos {
    return Intl.message(
      'Photos',
      name: 'createProductStepPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle`
  String get createProductStepVehicle {
    return Intl.message(
      'Vehicle',
      name: 'createProductStepVehicle',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get createProductStepInfo {
    return Intl.message(
      'Details',
      name: 'createProductStepInfo',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get createProductStepPrice {
    return Intl.message(
      'Price',
      name: 'createProductStepPrice',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get createProductStepLocation {
    return Intl.message(
      'Location',
      name: 'createProductStepLocation',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get createProductStepPreview {
    return Intl.message(
      'Preview',
      name: 'createProductStepPreview',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get createProductPreviewTitle {
    return Intl.message(
      'Preview',
      name: 'createProductPreviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `This is how buyers will see your listing.`
  String get createProductPreviewSubtitle {
    return Intl.message(
      'This is how buyers will see your listing.',
      name: 'createProductPreviewSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Where is the part?`
  String get createProductLocationTitle {
    return Intl.message(
      'Where is the part?',
      name: 'createProductLocationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pick a point on the map so nearby buyers can find you faster.`
  String get createProductLocationHint {
    return Intl.message(
      'Pick a point on the map so nearby buyers can find you faster.',
      name: 'createProductLocationHint',
      desc: '',
      args: [],
    );
  }

  /// `Use my location`
  String get createProductUseMyLocation {
    return Intl.message(
      'Use my location',
      name: 'createProductUseMyLocation',
      desc: '',
      args: [],
    );
  }

  /// `Factory-new, unused`
  String get createProductConditionNewHint {
    return Intl.message(
      'Factory-new, unused',
      name: 'createProductConditionNewHint',
      desc: '',
      args: [],
    );
  }

  /// `Pre-owned, in working order`
  String get createProductConditionUsedHint {
    return Intl.message(
      'Pre-owned, in working order',
      name: 'createProductConditionUsedHint',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get createProductContinue {
    return Intl.message(
      'Continue',
      name: 'createProductContinue',
      desc: '',
      args: [],
    );
  }

  /// `Publish now`
  String get createProductPublishNow {
    return Intl.message(
      'Publish now',
      name: 'createProductPublishNow',
      desc: '',
      args: [],
    );
  }

  /// `Update listing`
  String get createProductUpdateListing {
    return Intl.message(
      'Update listing',
      name: 'createProductUpdateListing',
      desc: '',
      args: [],
    );
  }

  /// `Step {current} of {total}`
  String createProductStepProgress(int current, int total) {
    return Intl.message(
      'Step $current of $total',
      name: 'createProductStepProgress',
      desc: '',
      args: [current, total],
    );
  }

  /// `Draft saved`
  String get createProductDraftSaved {
    return Intl.message(
      'Draft saved',
      name: 'createProductDraftSaved',
      desc: '',
      args: [],
    );
  }

  /// `Photos sell your part`
  String get createProductPhotosTitle {
    return Intl.message(
      'Photos sell your part',
      name: 'createProductPhotosTitle',
      desc: '',
      args: [],
    );
  }

  /// `First photo is the cover. Add up to 8 images.`
  String get createProductPhotosHint {
    return Intl.message(
      'First photo is the cover. Add up to 8 images.',
      name: 'createProductPhotosHint',
      desc: '',
      args: [],
    );
  }

  /// `Tap to add photos`
  String get createProductTapAddPhotos {
    return Intl.message(
      'Tap to add photos',
      name: 'createProductTapAddPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get createProductGallery {
    return Intl.message(
      'Gallery',
      name: 'createProductGallery',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get createProductCamera {
    return Intl.message(
      'Camera',
      name: 'createProductCamera',
      desc: '',
      args: [],
    );
  }

  /// `Add more photos`
  String get createProductAddMorePhotos {
    return Intl.message(
      'Add more photos',
      name: 'createProductAddMorePhotos',
      desc: '',
      args: [],
    );
  }

  /// `Cover`
  String get createProductCover {
    return Intl.message(
      'Cover',
      name: 'createProductCover',
      desc: '',
      args: [],
    );
  }

  /// `Drag to reorder`
  String get createProductDragReorder {
    return Intl.message(
      'Drag to reorder',
      name: 'createProductDragReorder',
      desc: '',
      args: [],
    );
  }

  /// `Sell faster with great photos`
  String get createProductTrustTitle {
    return Intl.message(
      'Sell faster with great photos',
      name: 'createProductTrustTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add 3+ photos, a clear title and a fair price — buyers trust complete listings.`
  String get createProductTrustBody {
    return Intl.message(
      'Add 3+ photos, a clear title and a fair price — buyers trust complete listings.',
      name: 'createProductTrustBody',
      desc: '',
      args: [],
    );
  }

  /// `Describe your part`
  String get createProductInfoTitle {
    return Intl.message(
      'Describe your part',
      name: 'createProductInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Toyota Camry brake pads — new`
  String get createProductTitleHint {
    return Intl.message(
      'e.g. Toyota Camry brake pads — new',
      name: 'createProductTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `Which vehicle?`
  String get createProductVehicleTitle {
    return Intl.message(
      'Which vehicle?',
      name: 'createProductVehicleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Helps buyers find your part faster.`
  String get createProductVehicleHint {
    return Intl.message(
      'Helps buyers find your part faster.',
      name: 'createProductVehicleHint',
      desc: '',
      args: [],
    );
  }

  /// `Recently used`
  String get createProductRecentlyUsed {
    return Intl.message(
      'Recently used',
      name: 'createProductRecentlyUsed',
      desc: '',
      args: [],
    );
  }

  /// `Brand`
  String get createProductBrand {
    return Intl.message(
      'Brand',
      name: 'createProductBrand',
      desc: '',
      args: [],
    );
  }

  /// `Part category`
  String get createProductPartCategory {
    return Intl.message(
      'Part category',
      name: 'createProductPartCategory',
      desc: '',
      args: [],
    );
  }

  /// `Year (optional)`
  String get createProductYearOptional {
    return Intl.message(
      'Year (optional)',
      name: 'createProductYearOptional',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get createProductSelect {
    return Intl.message(
      'Select',
      name: 'createProductSelect',
      desc: '',
      args: [],
    );
  }

  /// `No models for this brand. Pick another brand or add models in admin.`
  String get createProductNoModels {
    return Intl.message(
      'No models for this brand. Pick another brand or add models in admin.',
      name: 'createProductNoModels',
      desc: '',
      args: [],
    );
  }

  /// `Set your price`
  String get createProductPriceTitle {
    return Intl.message(
      'Set your price',
      name: 'createProductPriceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Suggested around {price} {currency}`
  String createProductPriceSuggested(int price, String currency) {
    return Intl.message(
      'Suggested around $price $currency',
      name: 'createProductPriceSuggested',
      desc: '',
      args: [price, currency],
    );
  }

  /// `Price is negotiable`
  String get createProductNegotiableTitle {
    return Intl.message(
      'Price is negotiable',
      name: 'createProductNegotiableTitle',
      desc: '',
      args: [],
    );
  }

  /// `Buyers can make offers`
  String get createProductNegotiableSubtitle {
    return Intl.message(
      'Buyers can make offers',
      name: 'createProductNegotiableSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Publishing… {percent}%`
  String createProductPublishing(int percent) {
    return Intl.message(
      'Publishing… $percent%',
      name: 'createProductPublishing',
      desc: '',
      args: [percent],
    );
  }

  /// `Listing published successfully`
  String get createProductPublishedSuccess {
    return Intl.message(
      'Listing published successfully',
      name: 'createProductPublishedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No internet — you can fill the form and publish when online.`
  String get createProductOfflineBanner {
    return Intl.message(
      'No internet — you can fill the form and publish when online.',
      name: 'createProductOfflineBanner',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one photo`
  String get createProductWarnNoPhotos {
    return Intl.message(
      'Add at least one photo',
      name: 'createProductWarnNoPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Title is too short`
  String get createProductWarnTitleShort {
    return Intl.message(
      'Title is too short',
      name: 'createProductWarnTitleShort',
      desc: '',
      args: [],
    );
  }

  /// `Select vehicle or category`
  String get createProductWarnNoCategory {
    return Intl.message(
      'Select vehicle or category',
      name: 'createProductWarnNoCategory',
      desc: '',
      args: [],
    );
  }

  /// `Set a price`
  String get createProductWarnNoPrice {
    return Intl.message(
      'Set a price',
      name: 'createProductWarnNoPrice',
      desc: '',
      args: [],
    );
  }

  /// `Select currency`
  String get createProductWarnNoCurrency {
    return Intl.message(
      'Select currency',
      name: 'createProductWarnNoCurrency',
      desc: '',
      args: [],
    );
  }

  /// `You recently posted a listing with the same title`
  String get createProductDuplicateTitle {
    return Intl.message(
      'You recently posted a listing with the same title',
      name: 'createProductDuplicateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add a photo`
  String get createProductQuickErrorPhoto {
    return Intl.message(
      'Add a photo',
      name: 'createProductQuickErrorPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Title (3+ characters)`
  String get createProductQuickErrorTitle {
    return Intl.message(
      'Title (3+ characters)',
      name: 'createProductQuickErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set a price`
  String get createProductQuickErrorPrice {
    return Intl.message(
      'Set a price',
      name: 'createProductQuickErrorPrice',
      desc: '',
      args: [],
    );
  }

  /// `No internet. Draft saved — try again when online.`
  String get createProductOfflinePublish {
    return Intl.message(
      'No internet. Draft saved — try again when online.',
      name: 'createProductOfflinePublish',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in to publish listings.`
  String get createProductErrorSignIn {
    return Intl.message(
      'Please sign in to publish listings.',
      name: 'createProductErrorSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Cannot reach server. Check your connection and that the backend is running.`
  String get createProductErrorServer {
    return Intl.message(
      'Cannot reach server. Check your connection and that the backend is running.',
      name: 'createProductErrorServer',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category (Vehicle step).`
  String get createProductErrorCategory {
    return Intl.message(
      'Please select a category (Vehicle step).',
      name: 'createProductErrorCategory',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get createProductRetry {
    return Intl.message(
      'Retry',
      name: 'createProductRetry',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get createProductOk {
    return Intl.message('OK', name: 'createProductOk', desc: '', args: []);
  }

  /// `Chat`
  String get chatConversationTitle {
    return Intl.message(
      'Chat',
      name: 'chatConversationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Typing…`
  String get chatHeaderTyping {
    return Intl.message(
      'Typing…',
      name: 'chatHeaderTyping',
      desc: '',
      args: [],
    );
  }

  /// `Recently active in this chat`
  String get chatPeerRecentlyActive {
    return Intl.message(
      'Recently active in this chat',
      name: 'chatPeerRecentlyActive',
      desc: '',
      args: [],
    );
  }

  /// `Last reply in chat · {time}`
  String chatPeerLastSeenInChat(Object time) {
    return Intl.message(
      'Last reply in chat · $time',
      name: 'chatPeerLastSeenInChat',
      desc: '',
      args: [time],
    );
  }

  /// `No replies from them yet`
  String get chatPeerNoMessagesYet {
    return Intl.message(
      'No replies from them yet',
      name: 'chatPeerNoMessagesYet',
      desc: '',
      args: [],
    );
  }

  /// `(status is for this chat only)`
  String get chatHeaderInChatOnlyHint {
    return Intl.message(
      '(status is for this chat only)',
      name: 'chatHeaderInChatOnlyHint',
      desc: '',
      args: [],
    );
  }

  /// `just now`
  String get chatJustNow {
    return Intl.message('just now', name: 'chatJustNow', desc: '', args: []);
  }

  /// `{n} min ago`
  String chatMinutesAgo(Object n) {
    return Intl.message(
      '$n min ago',
      name: 'chatMinutesAgo',
      desc: '',
      args: [n],
    );
  }

  /// `{n} h ago`
  String chatHoursAgo(Object n) {
    return Intl.message('$n h ago', name: 'chatHoursAgo', desc: '', args: [n]);
  }

  /// `{n} d ago`
  String chatDaysAgo(Object n) {
    return Intl.message('$n d ago', name: 'chatDaysAgo', desc: '', args: [n]);
  }

  /// `Reply`
  String get chatReply {
    return Intl.message('Reply', name: 'chatReply', desc: '', args: []);
  }

  /// `Copy`
  String get chatCopy {
    return Intl.message('Copy', name: 'chatCopy', desc: '', args: []);
  }

  /// `Copied`
  String get chatCopied {
    return Intl.message('Copied', name: 'chatCopied', desc: '', args: []);
  }

  /// `Original message isn't loaded yet. Scroll up to load more.`
  String get chatOriginalMessageNotLoaded {
    return Intl.message(
      'Original message isn\'t loaded yet. Scroll up to load more.',
      name: 'chatOriginalMessageNotLoaded',
      desc: '',
      args: [],
    );
  }

  /// `Select a conversation`
  String get chatSelectConversation {
    return Intl.message(
      'Select a conversation',
      name: 'chatSelectConversation',
      desc: '',
      args: [],
    );
  }

  /// `Choose a chat from the list to start messaging.`
  String get chatSelectConversationHint {
    return Intl.message(
      'Choose a chat from the list to start messaging.',
      name: 'chatSelectConversationHint',
      desc: '',
      args: [],
    );
  }

  /// `Write a message… (Enter to send, Shift+Enter for new line)`
  String get chatMessageHintDesktop {
    return Intl.message(
      'Write a message… (Enter to send, Shift+Enter for new line)',
      name: 'chatMessageHintDesktop',
      desc: '',
      args: [],
    );
  }

  /// `Reply to {name}`
  String chatReplyingTo(String name) {
    return Intl.message(
      'Reply to $name',
      name: 'chatReplyingTo',
      desc: '',
      args: [name],
    );
  }

  /// `Message…`
  String get chatMessageHint {
    return Intl.message(
      'Message…',
      name: 'chatMessageHint',
      desc: '',
      args: [],
    );
  }

  /// `Attach`
  String get chatAttach {
    return Intl.message('Attach', name: 'chatAttach', desc: '', args: []);
  }

  /// `Photo from gallery`
  String get chatAttachPhotos {
    return Intl.message(
      'Photo from gallery',
      name: 'chatAttachPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Take a photo`
  String get chatTakePhoto {
    return Intl.message(
      'Take a photo',
      name: 'chatTakePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get chatLastPhoto {
    return Intl.message('Photo', name: 'chatLastPhoto', desc: '', args: []);
  }

  /// `Voice message`
  String get chatLastVoice {
    return Intl.message(
      'Voice message',
      name: 'chatLastVoice',
      desc: '',
      args: [],
    );
  }

  /// `Microphone permission is required to record voice messages.`
  String get chatMicPermissionRequired {
    return Intl.message(
      'Microphone permission is required to record voice messages.',
      name: 'chatMicPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Hold to record`
  String get chatVoiceHoldHint {
    return Intl.message(
      'Hold to record',
      name: 'chatVoiceHoldHint',
      desc: '',
      args: [],
    );
  }

  /// `← Slide to cancel`
  String get chatVoiceSlideToCancel {
    return Intl.message(
      '← Slide to cancel',
      name: 'chatVoiceSlideToCancel',
      desc: '',
      args: [],
    );
  }

  /// `Release to cancel`
  String get chatVoiceReleaseToCancel {
    return Intl.message(
      'Release to cancel',
      name: 'chatVoiceReleaseToCancel',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get searchHubUnifiedTitle {
    return Intl.message(
      'Discover',
      name: 'searchHubUnifiedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search parts, workshops, orders, sellers…`
  String get searchHubEverythingHint {
    return Intl.message(
      'Search parts, workshops, orders, sellers…',
      name: 'searchHubEverythingHint',
      desc: '',
      args: [],
    );
  }

  /// `Voice search is coming soon`
  String get searchHubVoiceSoon {
    return Intl.message(
      'Voice search is coming soon',
      name: 'searchHubVoiceSoon',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get searchHubOpenMap {
    return Intl.message('Map', name: 'searchHubOpenMap', desc: '', args: []);
  }

  /// `Product filters`
  String get searchHubAdvancedProductFilters {
    return Intl.message(
      'Product filters',
      name: 'searchHubAdvancedProductFilters',
      desc: '',
      args: [],
    );
  }

  /// `Recent searches`
  String get searchHubRecent {
    return Intl.message(
      'Recent searches',
      name: 'searchHubRecent',
      desc: '',
      args: [],
    );
  }

  /// `Trending`
  String get searchHubTrending {
    return Intl.message(
      'Trending',
      name: 'searchHubTrending',
      desc: '',
      args: [],
    );
  }

  /// `Popular categories`
  String get searchHubCategoryIdeas {
    return Intl.message(
      'Popular categories',
      name: 'searchHubCategoryIdeas',
      desc: '',
      args: [],
    );
  }

  /// `Start typing to search listings, workshops, orders, and sellers.`
  String get searchHubAwaitingTyping {
    return Intl.message(
      'Start typing to search listings, workshops, orders, and sellers.',
      name: 'searchHubAwaitingTyping',
      desc: '',
      args: [],
    );
  }

  /// `No matches yet`
  String get searchHubNoGroupedHits {
    return Intl.message(
      'No matches yet',
      name: 'searchHubNoGroupedHits',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get searchHubSectionProducts {
    return Intl.message(
      'Products',
      name: 'searchHubSectionProducts',
      desc: '',
      args: [],
    );
  }

  /// `Auto Services`
  String get searchHubSectionWorkshops {
    return Intl.message(
      'Auto Services',
      name: 'searchHubSectionWorkshops',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get searchHubSectionServices {
    return Intl.message(
      'Services',
      name: 'searchHubSectionServices',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get searchHubSectionOrders {
    return Intl.message(
      'Requests',
      name: 'searchHubSectionOrders',
      desc: '',
      args: [],
    );
  }

  /// `Sellers`
  String get searchHubSectionSellers {
    return Intl.message(
      'Sellers',
      name: 'searchHubSectionSellers',
      desc: '',
      args: [],
    );
  }

  /// `Near you`
  String get homeStickyNearYou {
    return Intl.message(
      'Near you',
      name: 'homeStickyNearYou',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get homeStickyChooseLocation {
    return Intl.message(
      'Location',
      name: 'homeStickyChooseLocation',
      desc: '',
      args: [],
    );
  }

  /// `Live discovery map`
  String get homeExploreNearbyTitle {
    return Intl.message(
      'Live discovery map',
      name: 'homeExploreNearbyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Workshops • listings • live requests nearby`
  String get homeExploreNearbySubtitle {
    return Intl.message(
      'Workshops • listings • live requests nearby',
      name: 'homeExploreNearbySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Quick actions`
  String get homeQuickActionsRow {
    return Intl.message(
      'Quick actions',
      name: 'homeQuickActionsRow',
      desc: '',
      args: [],
    );
  }

  /// `Open requests nearby`
  String get homeHotOrdersPreview {
    return Intl.message(
      'Open requests nearby',
      name: 'homeHotOrdersPreview',
      desc: '',
      args: [],
    );
  }

  /// `Workshops nearby`
  String get homeNearbyWorkshopsPreview {
    return Intl.message(
      'Workshops nearby',
      name: 'homeNearbyWorkshopsPreview',
      desc: '',
      args: [],
    );
  }

  /// `Trending services`
  String get homeTrendingServicesPreview {
    return Intl.message(
      'Trending services',
      name: 'homeTrendingServicesPreview',
      desc: '',
      args: [],
    );
  }

  /// `Spotlight sellers`
  String get homeSellerSpotlight {
    return Intl.message(
      'Spotlight sellers',
      name: 'homeSellerSpotlight',
      desc: '',
      args: [],
    );
  }

  /// `Your conversations`
  String get homeChatsPreviewSection {
    return Intl.message(
      'Your conversations',
      name: 'homeChatsPreviewSection',
      desc: '',
      args: [],
    );
  }

  /// `Updates`
  String get homeAlertsPreviewSection {
    return Intl.message(
      'Updates',
      name: 'homeAlertsPreviewSection',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get homeOpenMessages {
    return Intl.message(
      'Messages',
      name: 'homeOpenMessages',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get homeOpenNotifications {
    return Intl.message(
      'Notifications',
      name: 'homeOpenNotifications',
      desc: '',
      args: [],
    );
  }

  /// `{n} listings`
  String homeListingCountHint(Object n) {
    return Intl.message(
      '$n listings',
      name: 'homeListingCountHint',
      desc: '',
      args: [n],
    );
  }

  /// `Notifications`
  String get notificationsCenterTitle {
    return Intl.message(
      'Notifications',
      name: 'notificationsCenterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Alerts about new followers, orders, workshops and deals will appear here. Your message threads stay in Messages.`
  String get notificationsCenterEmptyBody {
    return Intl.message(
      'Alerts about new followers, orders, workshops and deals will appear here. Your message threads stay in Messages.',
      name: 'notificationsCenterEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as read`
  String get notificationsMarkAllRead {
    return Intl.message(
      'Mark all as read',
      name: 'notificationsMarkAllRead',
      desc: '',
      args: [],
    );
  }

  /// `Recent alerts`
  String get notificationsRecent {
    return Intl.message(
      'Recent alerts',
      name: 'notificationsRecent',
      desc: '',
      args: [],
    );
  }

  /// `You’ll get alerts for orders, workshops and deals on this device.`
  String get notificationsCenterFooterHint {
    return Intl.message(
      'You’ll get alerts for orders, workshops and deals on this device.',
      name: 'notificationsCenterFooterHint',
      desc: '',
      args: [],
    );
  }

  /// `Alerts on`
  String get notificationsAlertsOn {
    return Intl.message(
      'Alerts on',
      name: 'notificationsAlertsOn',
      desc: '',
      args: [],
    );
  }

  /// `Alerts off`
  String get notificationsAlertsOff {
    return Intl.message(
      'Alerts off',
      name: 'notificationsAlertsOff',
      desc: '',
      args: [],
    );
  }

  /// `Turn on notifications so you don’t miss order and chat updates.`
  String get notificationsEnableHint {
    return Intl.message(
      'Turn on notifications so you don’t miss order and chat updates.',
      name: 'notificationsEnableHint',
      desc: '',
      args: [],
    );
  }

  /// `Enable notifications`
  String get notificationsEnableButton {
    return Intl.message(
      'Enable notifications',
      name: 'notificationsEnableButton',
      desc: '',
      args: [],
    );
  }

  /// `What you’ll receive`
  String get notificationsWhatYouGet {
    return Intl.message(
      'What you’ll receive',
      name: 'notificationsWhatYouGet',
      desc: '',
      args: [],
    );
  }

  /// `New messages and chat replies`
  String get notificationsTopicMessages {
    return Intl.message(
      'New messages and chat replies',
      name: 'notificationsTopicMessages',
      desc: '',
      args: [],
    );
  }

  /// `Order status and buyer/seller updates`
  String get notificationsTopicOrders {
    return Intl.message(
      'Order status and buyer/seller updates',
      name: 'notificationsTopicOrders',
      desc: '',
      args: [],
    );
  }

  /// `Workshop bookings and service replies`
  String get notificationsTopicWorkshops {
    return Intl.message(
      'Workshop bookings and service replies',
      name: 'notificationsTopicWorkshops',
      desc: '',
      args: [],
    );
  }

  /// `Deals and featured listings`
  String get notificationsTopicPromos {
    return Intl.message(
      'Deals and featured listings',
      name: 'notificationsTopicPromos',
      desc: '',
      args: [],
    );
  }

  /// `New store followers`
  String get notificationsTopicFollowers {
    return Intl.message(
      'New store followers',
      name: 'notificationsTopicFollowers',
      desc: '',
      args: [],
    );
  }

  /// `You can also enable alerts in Settings → Notifications → Garage.`
  String get notificationsIosSettingsHint {
    return Intl.message(
      'You can also enable alerts in Settings → Notifications → Garage.',
      name: 'notificationsIosSettingsHint',
      desc: '',
      args: [],
    );
  }

  /// `No chats yet`
  String get homeNoChatsYet {
    return Intl.message(
      'No chats yet',
      name: 'homeNoChatsYet',
      desc: '',
      args: [],
    );
  }

  /// `See services`
  String get homeSeeCategoryServices {
    return Intl.message(
      'See services',
      name: 'homeSeeCategoryServices',
      desc: '',
      args: [],
    );
  }

  /// `Sell`
  String get homeQuickSellProduct {
    return Intl.message(
      'Sell',
      name: 'homeQuickSellProduct',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get homeQuickCreateOrder {
    return Intl.message(
      'Order',
      name: 'homeQuickCreateOrder',
      desc: '',
      args: [],
    );
  }

  /// `Auto Service`
  String get homeQuickAddWorkshop {
    return Intl.message(
      'Auto Service',
      name: 'homeQuickAddWorkshop',
      desc: '',
      args: [],
    );
  }

  /// `Enable alerts`
  String get notificationsPermissionHintShort {
    return Intl.message(
      'Enable alerts',
      name: 'notificationsPermissionHintShort',
      desc: '',
      args: [],
    );
  }

  /// `Cars`
  String get searchHubScopeCars {
    return Intl.message('Cars', name: 'searchHubScopeCars', desc: '', args: []);
  }

  /// `Parts`
  String get searchHubScopeParts {
    return Intl.message(
      'Parts',
      name: 'searchHubScopeParts',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get searchHubScopeServices {
    return Intl.message(
      'Services',
      name: 'searchHubScopeServices',
      desc: '',
      args: [],
    );
  }

  /// `Auto Services`
  String get searchHubScopeWorkshops {
    return Intl.message(
      'Auto Services',
      name: 'searchHubScopeWorkshops',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get searchHubScopeOrders {
    return Intl.message(
      'Orders',
      name: 'searchHubScopeOrders',
      desc: '',
      args: [],
    );
  }

  /// `Nearby`
  String get searchHubScopeNearby {
    return Intl.message(
      'Nearby',
      name: 'searchHubScopeNearby',
      desc: '',
      args: [],
    );
  }

  /// `car`
  String get searchHubScopeCarsSeed {
    return Intl.message(
      'car',
      name: 'searchHubScopeCarsSeed',
      desc: '',
      args: [],
    );
  }

  /// `auto parts`
  String get searchHubScopePartsSeed {
    return Intl.message(
      'auto parts',
      name: 'searchHubScopePartsSeed',
      desc: '',
      args: [],
    );
  }

  /// `auto service`
  String get searchHubScopeWorkshopsSeed {
    return Intl.message(
      'auto service',
      name: 'searchHubScopeWorkshopsSeed',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get errorGeneric {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'errorGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in to continue.`
  String get errorAuthUnauthorized {
    return Intl.message(
      'Please sign in to continue.',
      name: 'errorAuthUnauthorized',
      desc: '',
      args: [],
    );
  }

  /// `You don't have permission for this action.`
  String get errorAuthForbidden {
    return Intl.message(
      'You don\'t have permission for this action.',
      name: 'errorAuthForbidden',
      desc: '',
      args: [],
    );
  }

  /// `This phone number is already registered.`
  String get errorAuthUserExists {
    return Intl.message(
      'This phone number is already registered.',
      name: 'errorAuthUserExists',
      desc: '',
      args: [],
    );
  }

  /// `Account not found.`
  String get errorAuthUserNotFound {
    return Intl.message(
      'Account not found.',
      name: 'errorAuthUserNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect phone or password.`
  String get errorAuthInvalidCredentials {
    return Intl.message(
      'Incorrect phone or password.',
      name: 'errorAuthInvalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Invalid verification code.`
  String get errorAuthInvalidOtp {
    return Intl.message(
      'Invalid verification code.',
      name: 'errorAuthInvalidOtp',
      desc: '',
      args: [],
    );
  }

  /// `Verification code expired. Request a new one.`
  String get errorAuthOtpExpired {
    return Intl.message(
      'Verification code expired. Request a new one.',
      name: 'errorAuthOtpExpired',
      desc: '',
      args: [],
    );
  }

  /// `Sign-up session expired. Please register again.`
  String get errorAuthConfirmationTokenMissing {
    return Intl.message(
      'Sign-up session expired. Please register again.',
      name: 'errorAuthConfirmationTokenMissing',
      desc: '',
      args: [],
    );
  }

  /// `Invalid sign-up session. Please register again.`
  String get errorAuthConfirmationTokenInvalid {
    return Intl.message(
      'Invalid sign-up session. Please register again.',
      name: 'errorAuthConfirmationTokenInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Verification expired. Request a new code.`
  String get errorAuthConfirmationTokenExpired {
    return Intl.message(
      'Verification expired. Request a new code.',
      name: 'errorAuthConfirmationTokenExpired',
      desc: '',
      args: [],
    );
  }

  /// `Real-time updates require a secure connection.`
  String get errorAuthSubscriptionRequired {
    return Intl.message(
      'Real-time updates require a secure connection.',
      name: 'errorAuthSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please check your input and try again.`
  String get errorValidationFailed {
    return Intl.message(
      'Please check your input and try again.',
      name: 'errorValidationFailed',
      desc: '',
      args: [],
    );
  }

  /// `File is too large.`
  String get errorValidationFileTooLarge {
    return Intl.message(
      'File is too large.',
      name: 'errorValidationFileTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `This file type is not supported.`
  String get errorValidationFileTypeInvalid {
    return Intl.message(
      'This file type is not supported.',
      name: 'errorValidationFileTypeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Request is too large.`
  String get errorValidationRequestTooLarge {
    return Intl.message(
      'Request is too large.',
      name: 'errorValidationRequestTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Request is too complex. Simplify and retry.`
  String get errorValidationRequestTooComplex {
    return Intl.message(
      'Request is too complex. Simplify and retry.',
      name: 'errorValidationRequestTooComplex',
      desc: '',
      args: [],
    );
  }

  /// `Item not found.`
  String get errorResourceNotFound {
    return Intl.message(
      'Item not found.',
      name: 'errorResourceNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Request not found.`
  String get errorOrderNotFound {
    return Intl.message(
      'Request not found.',
      name: 'errorOrderNotFound',
      desc: '',
      args: [],
    );
  }

  /// `This request is not closed.`
  String get errorOrderNotClosed {
    return Intl.message(
      'This request is not closed.',
      name: 'errorOrderNotClosed',
      desc: '',
      args: [],
    );
  }

  /// `Listing not found.`
  String get errorPartNotFound {
    return Intl.message(
      'Listing not found.',
      name: 'errorPartNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Auto service not found.`
  String get errorWorkshopNotFound {
    return Intl.message(
      'Auto service not found.',
      name: 'errorWorkshopNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Service not found.`
  String get errorServiceNotFound {
    return Intl.message(
      'Service not found.',
      name: 'errorServiceNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Chat not found.`
  String get errorConversationNotFound {
    return Intl.message(
      'Chat not found.',
      name: 'errorConversationNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Message not found.`
  String get errorMessageNotFound {
    return Intl.message(
      'Message not found.',
      name: 'errorMessageNotFound',
      desc: '',
      args: [],
    );
  }

  /// `You are not part of this chat.`
  String get errorBusinessNotParticipant {
    return Intl.message(
      'You are not part of this chat.',
      name: 'errorBusinessNotParticipant',
      desc: '',
      args: [],
    );
  }

  /// `This action is not allowed.`
  String get errorBusinessNotAllowed {
    return Intl.message(
      'This action is not allowed.',
      name: 'errorBusinessNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `You cannot review your own listing.`
  String get errorBusinessCannotReviewOwn {
    return Intl.message(
      'You cannot review your own listing.',
      name: 'errorBusinessCannotReviewOwn',
      desc: '',
      args: [],
    );
  }

  /// `You have already left a review.`
  String get errorBusinessAlreadyReviewed {
    return Intl.message(
      'You have already left a review.',
      name: 'errorBusinessAlreadyReviewed',
      desc: '',
      args: [],
    );
  }

  /// `You cannot book your own service.`
  String get errorBusinessCannotBookOwn {
    return Intl.message(
      'You cannot book your own service.',
      name: 'errorBusinessCannotBookOwn',
      desc: '',
      args: [],
    );
  }

  /// `You cannot respond to your own request.`
  String get errorBusinessCannotRespondOwnOrder {
    return Intl.message(
      'You cannot respond to your own request.',
      name: 'errorBusinessCannotRespondOwnOrder',
      desc: '',
      args: [],
    );
  }

  /// `You cannot watch this request.`
  String get errorBusinessOrderWatchDenied {
    return Intl.message(
      'You cannot watch this request.',
      name: 'errorBusinessOrderWatchDenied',
      desc: '',
      args: [],
    );
  }

  /// `Message is too long.`
  String get errorBusinessMessageTooLong {
    return Intl.message(
      'Message is too long.',
      name: 'errorBusinessMessageTooLong',
      desc: '',
      args: [],
    );
  }

  /// `Too many requests. Please wait and try again.`
  String get errorBusinessRateLimit {
    return Intl.message(
      'Too many requests. Please wait and try again.',
      name: 'errorBusinessRateLimit',
      desc: '',
      args: [],
    );
  }

  /// `Connection not authenticated.`
  String get errorWsUnauthenticated {
    return Intl.message(
      'Connection not authenticated.',
      name: 'errorWsUnauthenticated',
      desc: '',
      args: [],
    );
  }

  /// `Too many active connections.`
  String get errorWsTooManyConnections {
    return Intl.message(
      'Too many active connections.',
      name: 'errorWsTooManyConnections',
      desc: '',
      args: [],
    );
  }

  /// `Too many connection attempts. Try again later.`
  String get errorWsHandshakeRateLimited {
    return Intl.message(
      'Too many connection attempts. Try again later.',
      name: 'errorWsHandshakeRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Connection blocked for security reasons.`
  String get errorWsOriginNotAllowed {
    return Intl.message(
      'Connection blocked for security reasons.',
      name: 'errorWsOriginNotAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Device is offline. Open the app to receive updates.`
  String get errorDeviceOffline {
    return Intl.message(
      'Device is offline. Open the app to receive updates.',
      name: 'errorDeviceOffline',
      desc: '',
      args: [],
    );
  }

  /// `You cannot message yourself`
  String get errorCannotMessageSelf {
    return Intl.message(
      'You cannot message yourself',
      name: 'errorCannotMessageSelf',
      desc: '',
      args: [],
    );
  }

  /// `Seller is unavailable`
  String get errorSellerUnavailable {
    return Intl.message(
      'Seller is unavailable',
      name: 'errorSellerUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Author is unavailable`
  String get errorAuthorUnavailable {
    return Intl.message(
      'Author is unavailable',
      name: 'errorAuthorUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `No listings`
  String get errorNoListings {
    return Intl.message(
      'No listings',
      name: 'errorNoListings',
      desc: '',
      args: [],
    );
  }

  /// `Verified`
  String get workshopVerified {
    return Intl.message(
      'Verified',
      name: 'workshopVerified',
      desc: '',
      args: [],
    );
  }

  /// `Open now`
  String get workshopOpenNow {
    return Intl.message(
      'Open now',
      name: 'workshopOpenNow',
      desc: '',
      args: [],
    );
  }

  /// `Fast response`
  String get workshopFastResponse {
    return Intl.message(
      'Fast response',
      name: 'workshopFastResponse',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get workshopAbout {
    return Intl.message('About', name: 'workshopAbout', desc: '', args: []);
  }

  /// `On request`
  String get workshopOnRequest {
    return Intl.message(
      'On request',
      name: 'workshopOnRequest',
      desc: '',
      args: [],
    );
  }

  /// `from {amount} {currency}`
  String workshopPriceFrom(String amount, String currency) {
    return Intl.message(
      'from $amount $currency',
      name: 'workshopPriceFrom',
      desc: '',
      args: [amount, currency],
    );
  }

  /// `Owner: {text}`
  String workshopOwnerReply(String text) {
    return Intl.message(
      'Owner: $text',
      name: 'workshopOwnerReply',
      desc: '',
      args: [text],
    );
  }

  /// `Book now`
  String get bookNow {
    return Intl.message('Book now', name: 'bookNow', desc: '', args: []);
  }

  /// `Book service`
  String get bookServiceTitle {
    return Intl.message(
      'Book service',
      name: 'bookServiceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Booking request sent`
  String get bookWorkshopRequestSent {
    return Intl.message(
      'Booking request sent',
      name: 'bookWorkshopRequestSent',
      desc: '',
      args: [],
    );
  }

  /// `Could not book. Try again.`
  String get bookWorkshopCouldNotBook {
    return Intl.message(
      'Could not book. Try again.',
      name: 'bookWorkshopCouldNotBook',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get bookDate {
    return Intl.message('Date', name: 'bookDate', desc: '', args: []);
  }

  /// `Time`
  String get bookTime {
    return Intl.message('Time', name: 'bookTime', desc: '', args: []);
  }

  /// `Date & time`
  String get bookDateTime {
    return Intl.message(
      'Date & time',
      name: 'bookDateTime',
      desc: '',
      args: [],
    );
  }

  /// `Notes for the workshop (optional)`
  String get bookNotesOptional {
    return Intl.message(
      'Notes for the workshop (optional)',
      name: 'bookNotesOptional',
      desc: '',
      args: [],
    );
  }

  /// `Confirm booking`
  String get bookConfirmBooking {
    return Intl.message(
      'Confirm booking',
      name: 'bookConfirmBooking',
      desc: '',
      args: [],
    );
  }

  /// `Request booking`
  String get bookRequestBooking {
    return Intl.message(
      'Request booking',
      name: 'bookRequestBooking',
      desc: '',
      args: [],
    );
  }

  /// `Service (optional)`
  String get bookServiceOptional {
    return Intl.message(
      'Service (optional)',
      name: 'bookServiceOptional',
      desc: '',
      args: [],
    );
  }

  /// `Oil change, diagnostics…`
  String get bookServiceHint {
    return Intl.message(
      'Oil change, diagnostics…',
      name: 'bookServiceHint',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get bookNotes {
    return Intl.message('Notes', name: 'bookNotes', desc: '', args: []);
  }

  /// `No conversations yet`
  String get chatNoConversationsYet {
    return Intl.message(
      'No conversations yet',
      name: 'chatNoConversationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Say hello`
  String get chatSayHello {
    return Intl.message('Say hello', name: 'chatSayHello', desc: '', args: []);
  }

  /// `Reconnecting…`
  String get chatReconnecting {
    return Intl.message(
      'Reconnecting…',
      name: 'chatReconnecting',
      desc: '',
      args: [],
    );
  }

  /// `Workshops`
  String get mapLayerWorkshops {
    return Intl.message(
      'Workshops',
      name: 'mapLayerWorkshops',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get mapLayerRequests {
    return Intl.message(
      'Requests',
      name: 'mapLayerRequests',
      desc: '',
      args: [],
    );
  }

  /// `Filters & map`
  String get mapFiltersTitle {
    return Intl.message(
      'Filters & map',
      name: 'mapFiltersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Density heatmap`
  String get mapHeatmapTitle {
    return Intl.message(
      'Density heatmap',
      name: 'mapHeatmapTitle',
      desc: '',
      args: [],
    );
  }

  /// `Highlight areas with more listings`
  String get mapHeatmapSubtitle {
    return Intl.message(
      'Highlight areas with more listings',
      name: 'mapHeatmapSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Shown on map`
  String get mapShownOnMap {
    return Intl.message(
      'Shown on map',
      name: 'mapShownOnMap',
      desc: '',
      args: [],
    );
  }

  /// `Quick filters`
  String get mapQuickFilters {
    return Intl.message(
      'Quick filters',
      name: 'mapQuickFilters',
      desc: '',
      args: [],
    );
  }

  /// `All workshops`
  String get mapAllWorkshops {
    return Intl.message(
      'All workshops',
      name: 'mapAllWorkshops',
      desc: '',
      args: [],
    );
  }

  /// `Search radius`
  String get mapSearchRadius {
    return Intl.message(
      'Search radius',
      name: 'mapSearchRadius',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get mapOpenPin {
    return Intl.message('Open', name: 'mapOpenPin', desc: '', args: []);
  }

  /// `Route`
  String get mapRouteTooltip {
    return Intl.message('Route', name: 'mapRouteTooltip', desc: '', args: []);
  }

  /// `Share`
  String get mapShareTooltip {
    return Intl.message('Share', name: 'mapShareTooltip', desc: '', args: []);
  }

  /// `Using default map area — enable location for best results`
  String get mapLocationDefaultArea {
    return Intl.message(
      'Using default map area — enable location for best results',
      name: 'mapLocationDefaultArea',
      desc: '',
      args: [],
    );
  }

  /// `Turn on location (GPS) in device settings`
  String get mapLocationGpsDisabled {
    return Intl.message(
      'Turn on location (GPS) in device settings',
      name: 'mapLocationGpsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Location permission is required to show your position`
  String get mapLocationPermissionRequired {
    return Intl.message(
      'Location permission is required to show your position',
      name: 'mapLocationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Allow location in app settings`
  String get mapLocationPermissionForever {
    return Intl.message(
      'Allow location in app settings',
      name: 'mapLocationPermissionForever',
      desc: '',
      args: [],
    );
  }

  /// `Could not get your location`
  String get mapLocationFailed {
    return Intl.message(
      'Could not get your location',
      name: 'mapLocationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Open now`
  String get mapFilterOpenNow {
    return Intl.message(
      'Open now',
      name: 'mapFilterOpenNow',
      desc: '',
      args: [],
    );
  }

  /// `Nearby`
  String get mapFilterNearby {
    return Intl.message('Nearby', name: 'mapFilterNearby', desc: '', args: []);
  }

  /// `Verified`
  String get mapFilterVerified {
    return Intl.message(
      'Verified',
      name: 'mapFilterVerified',
      desc: '',
      args: [],
    );
  }

  /// `Top rated`
  String get mapFilterTopRated {
    return Intl.message(
      'Top rated',
      name: 'mapFilterTopRated',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get mapFilterPremium {
    return Intl.message(
      'Premium',
      name: 'mapFilterPremium',
      desc: '',
      args: [],
    );
  }

  /// `Workshops`
  String get workshopScreenTitle {
    return Intl.message(
      'Workshops',
      name: 'workshopScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Trusted auto businesses near you`
  String get workshopScreenSubtitle {
    return Intl.message(
      'Trusted auto businesses near you',
      name: 'workshopScreenSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Find verified workshops and book services online`
  String get servicesHubSubtitle {
    return Intl.message(
      'Find verified workshops and book services online',
      name: 'servicesHubSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No services with location nearby yet. Open the map or add your business.`
  String get servicesHubEmptyNearby {
    return Intl.message(
      'No services with location nearby yet. Open the map or add your business.',
      name: 'servicesHubEmptyNearby',
      desc: '',
      args: [],
    );
  }

  /// `No top rated services yet.`
  String get servicesHubEmptyTopRated {
    return Intl.message(
      'No top rated services yet.',
      name: 'servicesHubEmptyTopRated',
      desc: '',
      args: [],
    );
  }

  /// `Explore workshops and services on the map`
  String get servicesHubOpenMapSubtitle {
    return Intl.message(
      'Explore workshops and services on the map',
      name: 'servicesHubOpenMapSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get workshopPopular {
    return Intl.message('Popular', name: 'workshopPopular', desc: '', args: []);
  }

  /// `Nearby workshops`
  String get workshopNearbyTitle {
    return Intl.message(
      'Nearby workshops',
      name: 'workshopNearbyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search results`
  String get workshopSearchResults {
    return Intl.message(
      'Search results',
      name: 'workshopSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Live map`
  String get workshopsLiveMap {
    return Intl.message(
      'Live map',
      name: 'workshopsLiveMap',
      desc: '',
      args: [],
    );
  }

  /// `Tires`
  String get trendingTires {
    return Intl.message('Tires', name: 'trendingTires', desc: '', args: []);
  }

  /// `Diagnostics`
  String get trendingDiagnostics {
    return Intl.message(
      'Diagnostics',
      name: 'trendingDiagnostics',
      desc: '',
      args: [],
    );
  }

  /// `Engine oil`
  String get trendingEngineOil {
    return Intl.message(
      'Engine oil',
      name: 'trendingEngineOil',
      desc: '',
      args: [],
    );
  }

  /// `Tow truck`
  String get trendingTowTruck {
    return Intl.message(
      'Tow truck',
      name: 'trendingTowTruck',
      desc: '',
      args: [],
    );
  }

  /// `Detailing`
  String get trendingDetailing {
    return Intl.message(
      'Detailing',
      name: 'trendingDetailing',
      desc: '',
      args: [],
    );
  }

  /// `Automatic transmission`
  String get trendingAkp {
    return Intl.message(
      'Automatic transmission',
      name: 'trendingAkp',
      desc: '',
      args: [],
    );
  }

  /// `Battery`
  String get trendingBattery {
    return Intl.message('Battery', name: 'trendingBattery', desc: '', args: []);
  }

  /// `Brakes`
  String get trendingBrakes {
    return Intl.message('Brakes', name: 'trendingBrakes', desc: '', args: []);
  }

  /// `Engine`
  String get orderPartEngine {
    return Intl.message('Engine', name: 'orderPartEngine', desc: '', args: []);
  }

  /// `Bumper`
  String get orderPartBumper {
    return Intl.message('Bumper', name: 'orderPartBumper', desc: '', args: []);
  }

  /// `Headlights`
  String get orderPartHeadlights {
    return Intl.message(
      'Headlights',
      name: 'orderPartHeadlights',
      desc: '',
      args: [],
    );
  }

  /// `Brakes`
  String get orderPartBrakes {
    return Intl.message('Brakes', name: 'orderPartBrakes', desc: '', args: []);
  }

  /// `Suspension`
  String get orderPartSuspension {
    return Intl.message(
      'Suspension',
      name: 'orderPartSuspension',
      desc: '',
      args: [],
    );
  }

  /// `Need: {part}`
  String orderDetailNeedsPart(String part) {
    return Intl.message(
      'Need: $part',
      name: 'orderDetailNeedsPart',
      desc: '',
      args: [part],
    );
  }

  /// `Features`
  String get serviceFeatures {
    return Intl.message(
      'Features',
      name: 'serviceFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to book this service`
  String get signInToBookService {
    return Intl.message(
      'Sign in to book this service',
      name: 'signInToBookService',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to message this buyer`
  String get signInToMessageBuyer {
    return Intl.message(
      'Sign in to message this buyer',
      name: 'signInToMessageBuyer',
      desc: '',
      args: [],
    );
  }

  /// `VERIFIED`
  String get badgeVerified {
    return Intl.message('VERIFIED', name: 'badgeVerified', desc: '', args: []);
  }

  /// `PREMIUM`
  String get badgePremium {
    return Intl.message('PREMIUM', name: 'badgePremium', desc: '', args: []);
  }

  /// `FAST`
  String get badgeFast {
    return Intl.message('FAST', name: 'badgeFast', desc: '', args: []);
  }

  /// `TOP RATED`
  String get badgeTopRated {
    return Intl.message('TOP RATED', name: 'badgeTopRated', desc: '', args: []);
  }

  /// `Select services you offer`
  String get createWorkshopServicesTitle {
    return Intl.message(
      'Select services you offer',
      name: 'createWorkshopServicesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get createWorkshopPopular {
    return Intl.message(
      'Popular',
      name: 'createWorkshopPopular',
      desc: '',
      args: [],
    );
  }

  /// `All services`
  String get createWorkshopAllServices {
    return Intl.message(
      'All services',
      name: 'createWorkshopAllServices',
      desc: '',
      args: [],
    );
  }

  /// `Service types ({count}). Pick all that apply to your business.`
  String createWorkshopServicesHint(int count) {
    return Intl.message(
      'Service types ($count). Pick all that apply to your business.',
      name: 'createWorkshopServicesHint',
      desc: '',
      args: [count],
    );
  }

  /// `Save changes`
  String get saveChanges {
    return Intl.message(
      'Save changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message('Coming soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Follow`
  String get follow {
    return Intl.message('Follow', name: 'follow', desc: '', args: []);
  }

  /// `Following`
  String get following {
    return Intl.message('Following', name: 'following', desc: '', args: []);
  }

  /// `Share profile`
  String get shareProfile {
    return Intl.message(
      'Share profile',
      name: 'shareProfile',
      desc: '',
      args: [],
    );
  }

  /// `{followers} followers • {products} products • Joined {date}`
  String sellerFollowersProducts(
    String followers,
    String products,
    String date,
  ) {
    return Intl.message(
      '$followers followers • $products products • Joined $date',
      name: 'sellerFollowersProducts',
      desc: '',
      args: [followers, products, date],
    );
  }

  /// `Products`
  String get sellerStatProducts {
    return Intl.message(
      'Products',
      name: 'sellerStatProducts',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get sellerStatCategories {
    return Intl.message(
      'Categories',
      name: 'sellerStatCategories',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get sellerStatFollowers {
    return Intl.message(
      'Followers',
      name: 'sellerStatFollowers',
      desc: '',
      args: [],
    );
  }

  /// `No followers yet`
  String get noFollowersYet {
    return Intl.message(
      'No followers yet',
      name: 'noFollowersYet',
      desc: '',
      args: [],
    );
  }

  /// `Followed on {date}`
  String followedOn(String date) {
    return Intl.message(
      'Followed on $date',
      name: 'followedOn',
      desc: '',
      args: [date],
    );
  }

  /// `Profile views`
  String get sellerStatProfileViews {
    return Intl.message(
      'Profile views',
      name: 'sellerStatProfileViews',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get sellerStatActiveProducts {
    return Intl.message(
      'Active',
      name: 'sellerStatActiveProducts',
      desc: '',
      args: [],
    );
  }

  /// `Seller categories`
  String get sellerCategories {
    return Intl.message(
      'Seller categories',
      name: 'sellerCategories',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get sellerBioSection {
    return Intl.message('About', name: 'sellerBioSection', desc: '', args: []);
  }

  /// `Description`
  String get sellerDescriptionSection {
    return Intl.message(
      'Description',
      name: 'sellerDescriptionSection',
      desc: '',
      args: [],
    );
  }

  /// `Social links`
  String get sellerSocialLinks {
    return Intl.message(
      'Social links',
      name: 'sellerSocialLinks',
      desc: '',
      args: [],
    );
  }

  /// `Seller information`
  String get sellerInformation {
    return Intl.message(
      'Seller information',
      name: 'sellerInformation',
      desc: '',
      args: [],
    );
  }

  /// `Latest`
  String get latestProducts {
    return Intl.message('Latest', name: 'latestProducts', desc: '', args: []);
  }

  /// `Popular`
  String get popularProducts {
    return Intl.message('Popular', name: 'popularProducts', desc: '', args: []);
  }

  /// `Search in store`
  String get searchSellerProducts {
    return Intl.message(
      'Search in store',
      name: 'searchSellerProducts',
      desc: '',
      args: [],
    );
  }

  /// `Price: low to high`
  String get sortPriceLowHigh {
    return Intl.message(
      'Price: low to high',
      name: 'sortPriceLowHigh',
      desc: '',
      args: [],
    );
  }

  /// `Price: high to low`
  String get sortPriceHighLow {
    return Intl.message(
      'Price: high to low',
      name: 'sortPriceHighLow',
      desc: '',
      args: [],
    );
  }

  /// `View profile`
  String get viewProfile {
    return Intl.message(
      'View profile',
      name: 'viewProfile',
      desc: '',
      args: [],
    );
  }

  /// `More from this seller`
  String get moreFromSeller {
    return Intl.message(
      'More from this seller',
      name: 'moreFromSeller',
      desc: '',
      args: [],
    );
  }

  /// `This seller has no products yet`
  String get sellerStoreEmpty {
    return Intl.message(
      'This seller has no products yet',
      name: 'sellerStoreEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Follow to get notified when they list new items.`
  String get sellerStoreEmptyHint {
    return Intl.message(
      'Follow to get notified when they list new items.',
      name: 'sellerStoreEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `Email address`
  String get emailAddress {
    return Intl.message(
      'Email address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `Show location publicly`
  String get showLocationPublicly {
    return Intl.message(
      'Show location publicly',
      name: 'showLocationPublicly',
      desc: '',
      args: [],
    );
  }

  /// `Privacy settings`
  String get privacySettings {
    return Intl.message(
      'Privacy settings',
      name: 'privacySettings',
      desc: '',
      args: [],
    );
  }

  /// `Show phone number`
  String get showPhoneNumber {
    return Intl.message(
      'Show phone number',
      name: 'showPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Show email`
  String get showEmail {
    return Intl.message('Show email', name: 'showEmail', desc: '', args: []);
  }

  /// `Show followers count`
  String get showFollowersCount {
    return Intl.message(
      'Show followers count',
      name: 'showFollowersCount',
      desc: '',
      args: [],
    );
  }

  /// `Allow messages`
  String get allowMessages {
    return Intl.message(
      'Allow messages',
      name: 'allowMessages',
      desc: '',
      args: [],
    );
  }

  /// `Store preview`
  String get sellerDashboardPreview {
    return Intl.message(
      'Store preview',
      name: 'sellerDashboardPreview',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get aboutSection {
    return Intl.message('About', name: 'aboutSection', desc: '', args: []);
  }

  /// `Public`
  String get publicVisibility {
    return Intl.message('Public', name: 'publicVisibility', desc: '', args: []);
  }

  /// `Private`
  String get privateVisibility {
    return Intl.message(
      'Private',
      name: 'privateVisibility',
      desc: '',
      args: [],
    );
  }

  /// `Grid`
  String get gridView {
    return Intl.message('Grid', name: 'gridView', desc: '', args: []);
  }

  /// `List`
  String get listView {
    return Intl.message('List', name: 'listView', desc: '', args: []);
  }

  /// `@{username}`
  String sellerAtUsername(String username) {
    return Intl.message(
      '@$username',
      name: 'sellerAtUsername',
      desc: '',
      args: [username],
    );
  }

  /// `Edit store`
  String get editStore {
    return Intl.message('Edit store', name: 'editStore', desc: '', args: []);
  }

  /// `Manage products`
  String get manageProducts {
    return Intl.message(
      'Manage products',
      name: 'manageProducts',
      desc: '',
      args: [],
    );
  }

  /// `Store analytics`
  String get storeAnalytics {
    return Intl.message(
      'Store analytics',
      name: 'storeAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load store`
  String get unableToLoadStore {
    return Intl.message(
      'Unable to load store',
      name: 'unableToLoadStore',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Store profile completion`
  String get storeProfileCompletion {
    return Intl.message(
      'Store profile completion',
      name: 'storeProfileCompletion',
      desc: '',
      args: [],
    );
  }

  /// `Missing:`
  String get missingFields {
    return Intl.message('Missing:', name: 'missingFields', desc: '', args: []);
  }

  /// `Complete profile`
  String get completeProfile {
    return Intl.message(
      'Complete profile',
      name: 'completeProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile photo`
  String get missingAvatar {
    return Intl.message(
      'Profile photo',
      name: 'missingAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Store banner`
  String get missingStoreBanner {
    return Intl.message(
      'Store banner',
      name: 'missingStoreBanner',
      desc: '',
      args: [],
    );
  }

  /// `Bio`
  String get missingBio {
    return Intl.message('Bio', name: 'missingBio', desc: '', args: []);
  }

  /// `Description`
  String get missingDescription {
    return Intl.message(
      'Description',
      name: 'missingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Social links`
  String get missingSocialLinks {
    return Intl.message(
      'Social links',
      name: 'missingSocialLinks',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get missingLocation {
    return Intl.message(
      'Location',
      name: 'missingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get missingUsername {
    return Intl.message(
      'Username',
      name: 'missingUsername',
      desc: '',
      args: [],
    );
  }

  /// `Change banner`
  String get changeBanner {
    return Intl.message(
      'Change banner',
      name: 'changeBanner',
      desc: '',
      args: [],
    );
  }

  /// `Quick dashboard`
  String get quickSellerDashboard {
    return Intl.message(
      'Quick dashboard',
      name: 'quickSellerDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get dashboardToday {
    return Intl.message('Overview', name: 'dashboardToday', desc: '', args: []);
  }

  /// `Product views`
  String get dashboardProductViews {
    return Intl.message(
      'Product views',
      name: 'dashboardProductViews',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get dashboardMessages {
    return Intl.message(
      'Messages',
      name: 'dashboardMessages',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get dashboardNewFollowers {
    return Intl.message(
      'Followers',
      name: 'dashboardNewFollowers',
      desc: '',
      args: [],
    );
  }

  /// `Products sold`
  String get dashboardProductsSold {
    return Intl.message(
      'Products sold',
      name: 'dashboardProductsSold',
      desc: '',
      args: [],
    );
  }

  /// `Open analytics`
  String get openAnalytics {
    return Intl.message(
      'Open analytics',
      name: 'openAnalytics',
      desc: '',
      args: [],
    );
  }

  /// `Quick actions`
  String get quickActions {
    return Intl.message(
      'Quick actions',
      name: 'quickActions',
      desc: '',
      args: [],
    );
  }

  /// `Product management`
  String get productManagement {
    return Intl.message(
      'Product management',
      name: 'productManagement',
      desc: '',
      args: [],
    );
  }

  /// `Drafts`
  String get draftProducts {
    return Intl.message('Drafts', name: 'draftProducts', desc: '', args: []);
  }

  /// `Archived`
  String get archivedProducts {
    return Intl.message(
      'Archived',
      name: 'archivedProducts',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pendingModeration {
    return Intl.message(
      'Pending',
      name: 'pendingModeration',
      desc: '',
      args: [],
    );
  }

  /// `Store created`
  String get storeCreated {
    return Intl.message(
      'Store created',
      name: 'storeCreated',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get verificationStatus {
    return Intl.message(
      'Verification',
      name: 'verificationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Not verified`
  String get notVerified {
    return Intl.message(
      'Not verified',
      name: 'notVerified',
      desc: '',
      args: [],
    );
  }

  /// `Verified account`
  String get verifiedAccountTitle {
    return Intl.message(
      'Verified account',
      name: 'verifiedAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `AutoRin checked this seller and their store. The badge means a real, trusted seller you can buy from with more confidence.`
  String get verifiedAccountVisitorInfo {
    return Intl.message(
      'AutoRin checked this seller and their store. The badge means a real, trusted seller you can buy from with more confidence.',
      name: 'verifiedAccountVisitorInfo',
      desc: '',
      args: [],
    );
  }

  /// `Your store is verified by AutoRin. Buyers see the verified badge next to your name and trust your listings more.`
  String get verifiedAccountOwnerInfo {
    return Intl.message(
      'Your store is verified by AutoRin. Buyers see the verified badge next to your name and trust your listings more.',
      name: 'verifiedAccountOwnerInfo',
      desc: '',
      args: [],
    );
  }

  /// `Seller identity confirmed`
  String get verifiedAccountPointIdentity {
    return Intl.message(
      'Seller identity confirmed',
      name: 'verifiedAccountPointIdentity',
      desc: '',
      args: [],
    );
  }

  /// `Trusted store on AutoRin`
  String get verifiedAccountPointTrusted {
    return Intl.message(
      'Trusted store on AutoRin',
      name: 'verifiedAccountPointTrusted',
      desc: '',
      args: [],
    );
  }

  /// `Verification confirms your store is real. Verified sellers get a badge and more buyer trust.`
  String get verificationWhatIsIt {
    return Intl.message(
      'Verification confirms your store is real. Verified sellers get a badge and more buyer trust.',
      name: 'verificationWhatIsIt',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contactPreferences {
    return Intl.message(
      'Contact',
      name: 'contactPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Messages disabled`
  String get messagesDisabled {
    return Intl.message(
      'Messages disabled',
      name: 'messagesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `You have no products yet`
  String get ownerStoreEmpty {
    return Intl.message(
      'You have no products yet',
      name: 'ownerStoreEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Add first product`
  String get addFirstProduct {
    return Intl.message(
      'Add first product',
      name: 'addFirstProduct',
      desc: '',
      args: [],
    );
  }

  /// `Unfollow`
  String get unfollow {
    return Intl.message('Unfollow', name: 'unfollow', desc: '', args: []);
  }

  /// `Unfollow this seller?`
  String get unfollowConfirm {
    return Intl.message(
      'Unfollow this seller?',
      name: 'unfollowConfirm',
      desc: '',
      args: [],
    );
  }

  /// `7 days`
  String get range7Days {
    return Intl.message('7 days', name: 'range7Days', desc: '', args: []);
  }

  /// `30 days`
  String get range30Days {
    return Intl.message('30 days', name: 'range30Days', desc: '', args: []);
  }

  /// `90 days`
  String get range90Days {
    return Intl.message('90 days', name: 'range90Days', desc: '', args: []);
  }

  /// `Leads`
  String get dashboardLeads {
    return Intl.message('Leads', name: 'dashboardLeads', desc: '', args: []);
  }

  /// `Product clicks`
  String get productClicks {
    return Intl.message(
      'Product clicks',
      name: 'productClicks',
      desc: '',
      args: [],
    );
  }

  /// `Top products`
  String get topProducts {
    return Intl.message(
      'Top products',
      name: 'topProducts',
      desc: '',
      args: [],
    );
  }

  /// `Top categories`
  String get topCategories {
    return Intl.message(
      'Top categories',
      name: 'topCategories',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get chats {
    return Intl.message('Messages', name: 'chats', desc: '', args: []);
  }

  /// `My store`
  String get myStore {
    return Intl.message('My store', name: 'myStore', desc: '', args: []);
  }

  /// `My listings`
  String get ownerMyListings {
    return Intl.message(
      'My listings',
      name: 'ownerMyListings',
      desc: '',
      args: [],
    );
  }

  /// `Total listings`
  String get myListingsTotalLabel {
    return Intl.message(
      'Total listings',
      name: 'myListingsTotalLabel',
      desc: '',
      args: [],
    );
  }

  /// `{activeLabel} · {activeCount} · {inactiveLabel} · {inactiveCount}`
  String myListingsBreakdown(
    String activeLabel,
    int activeCount,
    String inactiveLabel,
    int inactiveCount,
  ) {
    return Intl.message(
      '$activeLabel · $activeCount · $inactiveLabel · $inactiveCount',
      name: 'myListingsBreakdown',
      desc: '',
      args: [activeLabel, activeCount, inactiveLabel, inactiveCount],
    );
  }

  /// `Untitled workshop`
  String get workshopUntitled {
    return Intl.message(
      'Untitled workshop',
      name: 'workshopUntitled',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get workshopStatusOpen {
    return Intl.message('Open', name: 'workshopStatusOpen', desc: '', args: []);
  }

  /// `Closed`
  String get workshopStatusClosed {
    return Intl.message(
      'Closed',
      name: 'workshopStatusClosed',
      desc: '',
      args: [],
    );
  }

  /// `Promote listing`
  String get promoteListingTitle {
    return Intl.message(
      'Promote listing',
      name: 'promoteListingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Promote product`
  String get promoteProductTitle {
    return Intl.message(
      'Promote product',
      name: 'promoteProductTitle',
      desc: '',
      args: [],
    );
  }

  /// `Promote workshop`
  String get promoteWorkshopTitle {
    return Intl.message(
      'Promote workshop',
      name: 'promoteWorkshopTitle',
      desc: '',
      args: [],
    );
  }

  /// `Promote service`
  String get promoteServiceTitle {
    return Intl.message(
      'Promote service',
      name: 'promoteServiceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Basic`
  String get promotePlanBasic {
    return Intl.message('Basic', name: 'promotePlanBasic', desc: '', args: []);
  }

  /// `Standard`
  String get promotePlanStandard {
    return Intl.message(
      'Standard',
      name: 'promotePlanStandard',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get promotePlanPremium {
    return Intl.message(
      'Premium',
      name: 'promotePlanPremium',
      desc: '',
      args: [],
    );
  }

  /// `VIP`
  String get promotePlanVip {
    return Intl.message('VIP', name: 'promotePlanVip', desc: '', args: []);
  }

  /// `{days} days · priority {priority}`
  String promotePlanDuration(int days, int priority) {
    return Intl.message(
      '$days days · priority $priority',
      name: 'promotePlanDuration',
      desc: '',
      args: [days, priority],
    );
  }

  /// `Activate promotion`
  String get activatePromotion {
    return Intl.message(
      'Activate promotion',
      name: 'activatePromotion',
      desc: '',
      args: [],
    );
  }

  /// `Promotion activated successfully`
  String get promotionActivatedSuccess {
    return Intl.message(
      'Promotion activated successfully',
      name: 'promotionActivatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `You are verified`
  String get notificationAccountVerifiedTitle {
    return Intl.message(
      'You are verified',
      name: 'notificationAccountVerifiedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your account is now verified by the AutoRin team.`
  String get notificationAccountVerifiedBody {
    return Intl.message(
      'Your account is now verified by the AutoRin team.',
      name: 'notificationAccountVerifiedBody',
      desc: '',
      args: [],
    );
  }

  /// `New follower`
  String get notificationNewFollowerTitle {
    return Intl.message(
      'New follower',
      name: 'notificationNewFollowerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Someone started following your store.`
  String get notificationNewFollowerBody {
    return Intl.message(
      'Someone started following your store.',
      name: 'notificationNewFollowerBody',
      desc: '',
      args: [],
    );
  }

  /// `Order update`
  String get notificationOrderReplyTitle {
    return Intl.message(
      'Order update',
      name: 'notificationOrderReplyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Promotion ended`
  String get notificationPromotedExpiredTitle {
    return Intl.message(
      'Promotion ended',
      name: 'notificationPromotedExpiredTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your listing is no longer promoted. Renew to stay on top.`
  String get notificationPromotedExpiredBody {
    return Intl.message(
      'Your listing is no longer promoted. Renew to stay on top.',
      name: 'notificationPromotedExpiredBody',
      desc: '',
      args: [],
    );
  }

  /// `Price match`
  String get notificationFavoriteMatchedTitle {
    return Intl.message(
      'Price match',
      name: 'notificationFavoriteMatchedTitle',
      desc: '',
      args: [],
    );
  }

  /// `A saved listing matches what you were looking for.`
  String get notificationFavoriteMatchedBody {
    return Intl.message(
      'A saved listing matches what you were looking for.',
      name: 'notificationFavoriteMatchedBody',
      desc: '',
      args: [],
    );
  }

  /// `Seller replied`
  String get notificationSellerResponseTitle {
    return Intl.message(
      'Seller replied',
      name: 'notificationSellerResponseTitle',
      desc: '',
      args: [],
    );
  }

  /// `New message`
  String get notificationNewMessageTitle {
    return Intl.message(
      'New message',
      name: 'notificationNewMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tap to open the conversation.`
  String get notificationNewMessageBody {
    return Intl.message(
      'Tap to open the conversation.',
      name: 'notificationNewMessageBody',
      desc: '',
      args: [],
    );
  }

  /// `There is an update on your order.`
  String get notificationOrderReplyBody {
    return Intl.message(
      'There is an update on your order.',
      name: 'notificationOrderReplyBody',
      desc: '',
      args: [],
    );
  }

  /// `Workshop booking`
  String get notificationWorkshopBookingTitle {
    return Intl.message(
      'Workshop booking',
      name: 'notificationWorkshopBookingTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have a new booking or service reply.`
  String get notificationWorkshopBookingBody {
    return Intl.message(
      'You have a new booking or service reply.',
      name: 'notificationWorkshopBookingBody',
      desc: '',
      args: [],
    );
  }

  /// `Garage`
  String get notificationGenericAlertTitle {
    return Intl.message(
      'Garage',
      name: 'notificationGenericAlertTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have a new alert.`
  String get notificationGenericAlertBody {
    return Intl.message(
      'You have a new alert.',
      name: 'notificationGenericAlertBody',
      desc: '',
      args: [],
    );
  }

  /// `Garage alerts`
  String get pushChannelName {
    return Intl.message(
      'Garage alerts',
      name: 'pushChannelName',
      desc: '',
      args: [],
    );
  }

  /// `Chat messages, orders, workshops and deals.`
  String get pushChannelDescription {
    return Intl.message(
      'Chat messages, orders, workshops and deals.',
      name: 'pushChannelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get notificationOpenAction {
    return Intl.message(
      'Open',
      name: 'notificationOpenAction',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'uz'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
