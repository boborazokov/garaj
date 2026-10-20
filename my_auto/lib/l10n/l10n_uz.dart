// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class SUz extends S {
  SUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Garage';

  @override
  String homeGreeting(String name) {
    return 'Salom, $name';
  }

  @override
  String get appMarketplaceTagline => 'Garage bozori';

  @override
  String get fieldRequired => 'Maydon majburiy';

  @override
  String get password => 'Parol';

  @override
  String get passwordLength =>
      'Parol kamida 6 ta belgidan iborat bo‘lishi kerak';

  @override
  String get phone => 'Telefon';

  @override
  String get signIn => 'Tizimga kirish';

  @override
  String get signInToContinue => 'Davom etish uchun kiring';

  @override
  String get signInToContinueHint =>
      'Sotuvchilarga yozish, sevimlilarni saqlash va e\'lon joylash uchun akkaunt yarating.';

  @override
  String get continueBrowsing => 'Ko\'rishni davom etish';

  @override
  String get browseAsGuest => 'Mehmon sifatida';

  @override
  String get skip => 'O\'tkazib yuborish';

  @override
  String get guest => 'Mehmon';

  @override
  String get noAccount => 'Hisobingiz yo‘qmi?';

  @override
  String get signUp => 'Ro‘yxatdan o‘tish';

  @override
  String get createAccount => 'Hisob yaratish';

  @override
  String get name => 'Ism';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String get passwordsDoNotMatch => 'Parollar mos kelmayapti';

  @override
  String get alreadyHaveAccount => 'Allaqachon hisobingiz bormi?';

  @override
  String get done => 'Tayyor';

  @override
  String get selectBirthDay => 'Tug‘ilgan kunni tanlang';

  @override
  String get logIn => 'Hisobingizga kiring';

  @override
  String get home => 'Bosh sahifa';

  @override
  String get profile => 'Profil';

  @override
  String get services => 'Avtoservis';

  @override
  String get add => 'Qo‘shish';

  @override
  String get order => 'Buyurtma';

  @override
  String get search => 'Qidiruv';

  @override
  String get favorites => 'Saqlanganlar';

  @override
  String get favoritesEmpty => 'Hali saqlangan e\'lonlar yo\'q';

  @override
  String get update => 'Yangilash';

  @override
  String get orders => 'Buyurtmalar';

  @override
  String get navWantToBuy => 'Menga kerak';

  @override
  String get wantToBuySubtitle =>
      'Kerakli ehtiyot qismni topa olmasangiz buyurtma qoldiring, sotuvchilar o‘zlari sizga aloqaga chiqishadi.';

  @override
  String get wantToBuySearchHint => 'Qism, mashina yoki shahar…';

  @override
  String get wantToBuyCreateCta => 'So‘rov qoldirish';

  @override
  String wantToBuyRequestsCount(int count) {
    return '$count ta ochiq';
  }

  @override
  String get wantToBuyRequestBadge => 'So‘rov';

  @override
  String get wantToBuyBudget => 'Byudjet';

  @override
  String wantToBuyOffers(int count) {
    return '$count ta taklif';
  }

  @override
  String get wantToBuyStep1 => 'So‘rov';

  @override
  String get wantToBuyStep2 => 'Taklif';

  @override
  String get wantToBuyStep3 => 'Kelishuv';

  @override
  String get wantToBuyFeedTitle => 'Xaridor so‘rovlari';

  @override
  String get wantToBuyRespond => 'Taklif berish';

  @override
  String get wantToBuyEmptyTitle => 'Hali so‘rovlar yo‘q';

  @override
  String get wantToBuyEmptyHint =>
      'Nima kerakligini yozing — do‘kon va sotuvchilar taklif yuboradi.';

  @override
  String get morning => 'Xayrli tong';

  @override
  String get afternoon => 'Xayrli kun';

  @override
  String get night => 'Xayrli tun';

  @override
  String get specialOffers => 'Maxsus takliflar';

  @override
  String get seeAll => 'Hammasi';

  @override
  String get topDeals => 'Zapchasti va hammasi';

  @override
  String get whatDoYouWantSell => 'Nima sotmoqchisiz?';

  @override
  String get passengerCars => 'Yengil avtomobillar';

  @override
  String get service => 'Xizmat';

  @override
  String get parts => 'Ehtiyot qismlar';

  @override
  String get announcements => 'E’lonlar';

  @override
  String get tuning => 'Tuning';

  @override
  String get accountDetails => 'Hisob ma’lumotlari';

  @override
  String get notification => 'Bildirishnomalar';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get myOrders => 'Mening buyurtmalarim';

  @override
  String get messages => 'Xabarlar';

  @override
  String get writeSeller => 'Sotuvchiga yozish';

  @override
  String get callSeller => 'Sotuvchiga qo\'ng\'iroq qilish';

  @override
  String get myServices => 'Mening xizmatlarim';

  @override
  String get myProducts => 'Mening mahsulotlarim';

  @override
  String get profileSectionMyActivity => 'Mening faoliyatim';

  @override
  String get profileSubtitleMyStore => 'Do‘kon, banner va e’lonlar';

  @override
  String get profileSubtitleMyProducts => 'E’lonlar va ehtiyot qismlar';

  @override
  String get profileSubtitleMyServices => 'Boshqariladigan ustaxonalar';

  @override
  String get profileSubtitleMyOrders => 'So‘nggi buyurtmalar';

  @override
  String get sellerMatchingOrdersTitle => 'Reklamalar';

  @override
  String get sellerMatchingOrdersSubtitle =>
      'Tizimdagi mos xaridor e\'lonlari va statusi';

  @override
  String get sellerMatchingOrdersAll => 'Barcha mos reklamalar';

  @override
  String get sellerMatchingOrdersByCategory => 'Kategoriyalar bo‘yicha';

  @override
  String sellerMatchingOrdersTotalHint(int count) {
    return 'Siz uchun $count ta faol reklama';
  }

  @override
  String sellerMatchingOrdersListingsHint(int count) {
    return '$count ta mahsulotingiz';
  }

  @override
  String get sellerMatchingOrdersEmptyListings => 'Hali mahsulot yo‘q';

  @override
  String get sellerMatchingOrdersEmptyListingsHint =>
      'Sotadigan kategoriyalarga mahsulot qo\'shing — mos reklamalar shu yerda chiqadi.';

  @override
  String get sellerMatchingOrdersStatusActive => 'Faol';

  @override
  String get sellerMatchingOrdersStatusClosed => 'Yopiq';

  @override
  String sellerMatchingOrdersOpenCount(int count) {
    return '$count ta ochiq';
  }

  @override
  String get notificationOrderMatchedTitle => 'Yangi mos e’lon';

  @override
  String get notificationOrderMatchedBody =>
      'Xaridor sizning kategoriyangizda e’lon yaratdi.';

  @override
  String get profileSubtitleMessages => 'Sotuvchilar bilan chatlar';

  @override
  String get profileSectionPreferences => 'Sozlamalar';

  @override
  String get profileSectionSupport => 'Yordam';

  @override
  String get contactUs => 'Biz bilan bog‘laning';

  @override
  String get termsAndConditions => 'Foydalanish shartlari';

  @override
  String get helpAndSupport => 'Yordam va qo‘llab-quvvatlash';

  @override
  String get logout => 'Chiqish';

  @override
  String get editProfile => 'Profilni tahrirlash';

  @override
  String get gallery => 'Galereya';

  @override
  String get camera => 'Kamera';

  @override
  String get language => 'Til';

  @override
  String get logoutDescription => 'Chiqmoqchimisiz?';

  @override
  String get logoutSubtitle => 'Siz tizimga kirish sahifasiga yo‘naltirilasiz.';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get email => 'Elektron pochta';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get privacyPolicyIntro =>
      'Biz sizning maxfiyligingizni himoya qilishga intilamiz. Ushbu siyosat qanday ma’lumotlar yig‘ilishini, qanday ishlatilishini va qanday himoyalanishini tushuntiradi.';

  @override
  String get dataCollection => '1. Ma’lumotlarni yig‘ish';

  @override
  String get dataCollectionText =>
      'Siz hisob yaratayotganda yoki xizmatlardan foydalanganda ism, elektron pochta manzili va telefon raqami kabi shaxsiy ma’lumotlarni to‘playmiz.';

  @override
  String get dataUsage => '2. Ma’lumotlardan foydalanish';

  @override
  String get dataUsageText =>
      'Sizning ma’lumotlaringiz xizmatlarimizni taqdim etish va takomillashtirish, tajribani shaxsiylashtirish va siz bilan aloqa qilish uchun ishlatiladi.';

  @override
  String get thirdPartySharing => '3. Uchinchi tomonlarga ulashish';

  @override
  String get thirdPartySharingText =>
      'Biz ma’lumotlaringizni sotmaymiz. Faqat xizmatlarni ko‘rsatish (masalan, hosting, tahlil) uchun uchinchi tomonlar bilan ulashishimiz mumkin.';

  @override
  String get contactInformation => 'Aloqa';

  @override
  String get contactInformationText =>
      'Maxfiylik va ma’lumotlar bo‘yicha savollar: support@myauto.uz yoki +998 95 384 10 00.';

  @override
  String get privacyPolicyLastUpdated => 'Oxirgi yangilanish: 2026-yil iyun';

  @override
  String get privacyAccountData => '2. Hisob va e’lonlar';

  @override
  String get privacyAccountDataText =>
      'Profil (ism, telefon, rasm), e’lonlar (ehtiyot qismlar, ustaxona), xabarlar, buyurtmalar va push-bildirishnomalar uchun qurilma tokenlarini saqlaymiz. Joylashuv faqat siz berganingizda ishlatiladi.';

  @override
  String get privacyDataRetention => '5. Ma’lumotlarni saqlash';

  @override
  String get privacyDataRetentionText =>
      'Ma’lumotlar hisob faol bo‘lguncha saqlanadi. Hisobni o‘chirsangiz, shaxsiy ma’lumotlar o‘chiriladi, e’lonlar arxivlanadi.';

  @override
  String get privacyAccountDeletion => '6. Hisobni o‘chirish';

  @override
  String get privacyAccountDeletionText =>
      'Hisobni Profil → Hisobni o‘chirish orqali istalgan vaqtda o‘chirishingiz mumkin. Shaxsiy ma’lumotlar o‘chiriladi, e’lonlar arxivlanadi. Buni qaytarib bo‘lmaydi.';

  @override
  String get privacyChildren => '7. Bolalar';

  @override
  String get privacyChildrenText =>
      'My Auto 16 yoshdan kichik foydalanuvchilar uchun mo‘ljallanmagan. Biz ataylab bolalar ma’lumotlarini yig‘maymiz.';

  @override
  String get privacySecurity => '4. Xavfsizlik';

  @override
  String get privacySecurityText =>
      'Ma’lumot uzatishda shifrlash (HTTPS), xavfsiz autentifikatsiya va kirish nazoratidan foydalanamiz. Mutlaq himoya yo‘q, lekin ma’lumotlaringizni himoya qilishga harakat qilamiz.';

  @override
  String get privacyPolicyChanges => '9. Siyosat o‘zgarishlari';

  @override
  String get privacyPolicyChangesText =>
      'Ushbu siyosatni yangilashimiz mumkin. Ilovadan foydalanishni davom ettirsangiz, yangilangan siyosatni qabul qilgan hisoblanasiz.';

  @override
  String get contactUsIntro =>
      'E’lonlar, buyurtmalar va hisob bo‘yicha yordam beramiz.';

  @override
  String get contactUsEmailSubtitle => 'Odatda 1 ish kuni ichida javob beramiz';

  @override
  String get contactUsPhoneSubtitle => 'Dush–Shan, 9:00–18:00 (Toshkent vaqti)';

  @override
  String get supportEmail => 'support@myauto.uz';

  @override
  String get supportPhone => '+998 95 384 10 00';

  @override
  String get deleteAccount => 'Hisobni o‘chirish';

  @override
  String get deleteAccountDescription => 'Hisobni butunlay o‘chirasizmi?';

  @override
  String get deleteAccountSubtitle =>
      'Profil va shaxsiy ma’lumotlar o‘chiriladi. E’lonlar arxivlanadi. Buni qaytarib bo‘lmaydi.';

  @override
  String get deleteAccountConfirm => 'Butunlay o‘chirish';

  @override
  String get deleteAccountSuccess => 'Hisobingiz o‘chirildi';

  @override
  String get deleteAccountFailed =>
      'Hisobni o‘chirib bo‘lmadi. Qayta urinib ko‘ring yoki qo‘llab-quvvatlashga yozing.';

  @override
  String get profileSectionAccount => 'Hisob';

  @override
  String get myListingsEmptyActive => 'Hali faol e’lonlar yo‘q';

  @override
  String get myListingsEmptyInactive => 'Arxivlangan e’lonlar yo‘q';

  @override
  String get sessionExpired => 'Sessiya tugadi. Iltimos, qayta kiring.';

  @override
  String get noInternetConnection =>
      'Internet ulanmagan. Tarmoqlar sozlamalarini tekshiring.';

  @override
  String get serverNotWorking =>
      'Server hozirda ishlamayapti. Iltimos, keyinroq urinib ko‘ring.';

  @override
  String get errorOccurred =>
      'Xato yuz berdi. Iltimos, keyinroq urinib ko‘ring.';

  @override
  String get success => 'Muvaffaqiyatli';

  @override
  String get error => 'Xato';

  @override
  String get info => 'Ma’lumot';

  @override
  String get select => 'Tanlash';

  @override
  String get enterCodeMessage =>
      'Sizga 5 xonali kod yuborildi — davom etish uchun ushbu kodni kiriting';

  @override
  String get confirmationCodeNeedsToBe5Symbols =>
      'Tasdiqlash kodi 5 ta belgidan iborat bo‘lishi kerak';

  @override
  String get invalidOtpCode => 'Noto‘g‘ri kod';

  @override
  String get userAlreadyExists => 'Foydalanuvchi allaqachon mavjud';

  @override
  String get titleOfParts => 'Ehtiyot qism nomi';

  @override
  String get descriptionOfParts => 'Ehtiyot qism tavsifi';

  @override
  String get price => 'Narx';

  @override
  String get priceDescription => 'Narx tavsifi';

  @override
  String get priceDescriptionPlaceholder =>
      'Narx tavsifini bu yerga kiriting...';

  @override
  String get maxFiveImages => 'Maksimal 5 ta rasm';

  @override
  String get fillAllFields => 'Barcha maydonlarni to‘ldiring';

  @override
  String get addProduct => 'Mahsulot qo‘shish';

  @override
  String get requiredField => 'Majburiy maydon';

  @override
  String get enterDescription => 'Tavsifni bu yerga kiriting...';

  @override
  String get quantity => 'Miqdor';

  @override
  String get discount => 'Chegirma';

  @override
  String get chooseCategory => 'Kategoriyani tanlang';

  @override
  String get required => 'Majburiy';

  @override
  String get exampleTittleParts => 'Misol: Piston';

  @override
  String get category => 'Kategoriya';

  @override
  String get chooseLocation => 'Joylashuvni tanlang';

  @override
  String get regionAndijan => 'Andijon';

  @override
  String get regionBukhara => 'Buxoro';

  @override
  String get regionJizzakh => 'Jizzax';

  @override
  String get regionKashkadarya => 'Qashqadaryo';

  @override
  String get regionNavoi => 'Navoiy';

  @override
  String get regionNamangan => 'Namangan';

  @override
  String get regionSamarkand => 'Samarqand';

  @override
  String get regionSurkhandarya => 'Surxondaryo';

  @override
  String get regionSyrdarya => 'Sirdaryo';

  @override
  String get regionTashkentRegion => 'Toshkent viloyati';

  @override
  String get regionFergana => 'Farg‘ona';

  @override
  String get regionKhorezm => 'Xorazm';

  @override
  String get regionKarakalpakstan => 'Qoraqalpog‘iston Respublikasi';

  @override
  String get regionTashkentCity => 'Toshkent shahri';

  @override
  String get location => 'Joylashuv';

  @override
  String get partCreated => 'Ehtiyot qism muvaffaqiyatli yaratildi';

  @override
  String get forbiddenResource => 'Ruxsat berilmagan resurs';

  @override
  String get description => 'Tavsif';

  @override
  String get images => 'Rasmlar';

  @override
  String get user => 'Foydalanuvchi';

  @override
  String get relatedProducts => 'O‘xshash mahsulotlar';

  @override
  String get noImages => 'Rasmlar yo‘q';

  @override
  String sellerSince(Object date) {
    return 'Sotuvchi Garage\'da $date dan beri';
  }

  @override
  String get sellerSinceDescription =>
      'Sotuvchining ro‘yxatdan o‘tgan oyini va yilini ko‘rsatadi';

  @override
  String get allSellerProducts => 'Sotuvchining barcha e’lonlari >';

  @override
  String get otherListingsBySeller => 'Ushbu sotuvchining boshqa e’lonlari';

  @override
  String get noProducts => 'Mahsulotlar yo‘q';

  @override
  String get delete => 'O‘chirish';

  @override
  String get areYouSureToDelete => 'O‘chirmoqchimisiz?';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get productDeleted => 'Mahsulot muvaffaqiyatli o‘chirildi';

  @override
  String get productUpdated => 'Mahsulot yangilandi';

  @override
  String get save => 'Saqlash';

  @override
  String get more => 'Ko‘proq';

  @override
  String availableUntil(Object date) {
    return '$date gacha mavjud';
  }

  @override
  String get views => 'Ko‘rishlar';

  @override
  String get viewsOfPhone => 'Telefon ko‘rishlari';

  @override
  String get active => 'Faol';

  @override
  String get inactive => 'Faol emas';

  @override
  String get depleted => 'Tugagan';

  @override
  String get confirmReturnToSale =>
      'Ushbu mahsulotni yana savdoga chiqarishni xohlaysizmi?';

  @override
  String get relist => 'Qayta chiqarish';

  @override
  String get relistTitle => 'Savdoga qaytarish';

  @override
  String get yes => 'Ha';

  @override
  String get no => 'Yo‘q';

  @override
  String get deleteProductTitle => 'Mahsulotni o‘chirish';

  @override
  String get areYouSureToDeleteProduct => 'Ushbu mahsulotni o‘chirmoqchimisiz?';

  @override
  String postedOn(Object date) {
    return '$date da e’lon qilingan';
  }

  @override
  String get address => 'Manzil';

  @override
  String get addService => 'Xizmat qo‘shish';

  @override
  String get chooseLocationOnMap => 'Xaritadan joylashuvni tanlang';

  @override
  String get workingTime => 'Ish vaqti';

  @override
  String get timeExample => 'Misol: 9:00 - 18:00';

  @override
  String get titleOfServices => 'Xizmat nomi';

  @override
  String get editService => 'Xizmatni tahrirlash';

  @override
  String get upload => 'Yuklash';

  @override
  String get allProducts => 'Barcha mahsulotlar';

  @override
  String get noWorkshopsFound => 'Usta joylari topilmadi';

  @override
  String get openFrom => 'Ochiq vaqti';

  @override
  String get deleteWorkshopTitle => 'Usta joyini o‘chirish';

  @override
  String get areYouSureToDeleteWorkshop =>
      'Ushbu usta joyini o‘chirmoqchimisiz?';

  @override
  String get workshopDeleted => 'Usta joyi muvaffaqiyatli o‘chirildi';

  @override
  String get noServices => 'Hozircha xizmatlar yo‘q';

  @override
  String get noWorkshops => 'Hozircha Avto Xizmatlar yo‘q';

  @override
  String get noDiscount => 'Chegirma yo‘q';

  @override
  String get withDiscount => 'Chegirmali';

  @override
  String get condition => 'Holat';

  @override
  String get newPart => 'Yangi';

  @override
  String get used => 'Ishlatilgan';

  @override
  String get delivery => 'Yetkazib berish';

  @override
  String get available => 'Mavjud';

  @override
  String get noAvailable => 'Mavjud emas';

  @override
  String get modelOfCar => 'Avtomobil modeli';

  @override
  String get negotiable => 'Narxi kelishiladi';

  @override
  String get byAgreement => 'Kelishuvga ko‘ra';

  @override
  String get back => 'Orqaga';

  @override
  String get next => 'Keyingi';

  @override
  String get details => 'Tafsilotlar';

  @override
  String get photos => 'Suratlar';

  @override
  String get enterPrice => 'Narxni kiriting';

  @override
  String get addPhoto => 'Rasm qo‘shish';

  @override
  String get continueWithoutPhotos => 'Fotosiz davom etish';

  @override
  String get youCanUploadUpTo5Photos =>
      'Siz 5 tagacha rasm yuklashingiz mumkin';

  @override
  String get publishProduct => 'Mahsulotni e’lon etish';

  @override
  String get publish => 'E’lon qilish';

  @override
  String get productSuccessfullyPublished =>
      'Mahsulot muvaffaqiyatli nashr etildi';

  @override
  String get productDetails => 'Mahsulot tafsilotlari';

  @override
  String get enterTitleOfPart => 'Enter part name';

  @override
  String get chooseCondition => 'Please select the condition';

  @override
  String get chooseDeliveryMethod => 'Please select the delivery method';

  @override
  String get enterDescriptionPart => 'Enter a detailed description of the part';

  @override
  String get darkTheme => 'Qorong‘u rejim';

  @override
  String get included => 'Included';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get viewDetails => 'View details';

  @override
  String get close => 'Close';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully';

  @override
  String get sellerProfile => 'Sotuvchi profili';

  @override
  String get didntFindWhatYouNeed => 'Kerakli narsani topa olmadingizmi?';

  @override
  String get createRequestSubtitle =>
      'Buyurtma joylang — sotuvchilar siz bilan bog‘lanadi.';

  @override
  String get createRequest => 'Buyurtma yaratish';

  @override
  String get createOrder => 'Buyurtma yaratish';

  @override
  String get myRequests => 'Mening buyurtmalarim';

  @override
  String get title => 'Sarlavha';

  @override
  String get phoneNumber => 'Telefon raqami';

  @override
  String get brand => 'Brend';

  @override
  String get carModel => 'Model';

  @override
  String get partCategory => 'Ehtiyot qism toifasi';

  @override
  String get selectBrand => 'Brendni tanlang';

  @override
  String get selectModel => 'Modelni tanlang';

  @override
  String get selectPartCategory => 'Toifani tanlang';

  @override
  String get budgetOptional => 'Byudjet (ixtiyoriy)';

  @override
  String get orderUrgencyTitle => 'Qanchalik shoshilinch?';

  @override
  String get orderUrgencyHint => 'Sotuvchilar buni buyurtma kartasida ko‘radi.';

  @override
  String get orderUrgencyLow => 'Shoshilinch emas';

  @override
  String get orderUrgencyNormal => 'Oddiy';

  @override
  String get orderUrgencyUrgent => 'Juda shoshilinch';

  @override
  String get submit => 'Yuborish';

  @override
  String get orderCreated => 'Buyurtma muvaffaqiyatli yaratildi';

  @override
  String get callAuthor => 'Qo‘ng‘iroq qilish';

  @override
  String get noOrders => 'Hozircha buyurtmalar yo‘q';

  @override
  String get noOrdersHint =>
      'Xaridorlar buyurtma joylaganda shu yerda paydo bo‘ladi.';

  @override
  String get closeOrder => 'Buyurtmani yopish';

  @override
  String get closeOrderConfirm =>
      'Buyurtmani yopilgan deb belgilashni xohlaysizmi?';

  @override
  String get reopenOrder => 'Qayta ochish';

  @override
  String get reopenOrderConfirm =>
      'Buyurtmani sotuvchilarga yana ko\'rsatilsinmi?';

  @override
  String get orderStatusActive => 'Faol';

  @override
  String get orderStatusClosed => 'Yopilgan';

  @override
  String get orderDetailLookingFor => 'Kerakli ehtiyot qism';

  @override
  String get orderDetailOffersTitle => 'Sotuvchi takliflari';

  @override
  String orderDetailOffersCount(int count) {
    return '$count ta taklif';
  }

  @override
  String get orderDetailNoOffers =>
      'Hali taklif yo‘q. Sotuvchilar arizangiz bo‘yicha narx va qism taklif qiladi.';

  @override
  String get orderDetailSendOffer => 'Taklif yuborish';

  @override
  String get orderDetailMessageBuyer => 'Xaridorga yozish';

  @override
  String get orderDetailYourOffer => 'Sizning taklifingiz';

  @override
  String get orderDetailOfferMessageHint =>
      'Ushbu ariza uchun qaysi ehtiyot qismni bera olishingizni yozing…';

  @override
  String get orderDetailOfferPriceHint => 'Narxingiz (ixtiyoriy)';

  @override
  String get orderDetailSubmitOffer => 'Yuborish';

  @override
  String get orderDetailChatSeller => 'Chat';

  @override
  String get orderDetailSellerListing => 'Sotuvchi e’loni';

  @override
  String get orderDetailAlternativeListing =>
      'Boshqa ehtiyot qism (sotuvchi e’loni)';

  @override
  String orderDetailDeliveryDays(int days) {
    return 'Yetkazib berish ~$days kun';
  }

  @override
  String get orderDetailBudgetNegotiable => 'Byudjet kelishiladi';

  @override
  String get orderDetailPosted => 'Joylangan';

  @override
  String get orderDetailAcceptedOffer => 'Qabul qilindi';

  @override
  String get orderDetailViewListing => 'E’lonni ko‘rish';

  @override
  String orderDetailOfferPrice(String amount) {
    return 'Narx: $amount';
  }

  @override
  String get writeReview => 'Sharh yozish';

  @override
  String get reviewCommentHint => 'Tajribangizni yozing (ixtiyoriy)';

  @override
  String get submitReview => 'Sharh yuborish';

  @override
  String get reviewsTitle => 'Sharhlar';

  @override
  String get noReviewsYet => 'Hali sharh yo\'q';

  @override
  String get reviewSubmitted => 'Sharhingiz uchun rahmat';

  @override
  String get editReview => 'Sharhni tahrirlash';

  @override
  String get reviewUpdated => 'Sharh yangilandi';

  @override
  String get deleteReview => 'Sharhni o‘chirish';

  @override
  String get deleteReviewConfirm => 'Sharhingiz butunlay o‘chirilsinmi?';

  @override
  String get loadMoreReviews => 'Yana ko‘rsatish';

  @override
  String get reviewDeleted => 'Sharh o‘chirildi';

  @override
  String get promotedTop => 'Targ\'ib qilingan';

  @override
  String get promoteToTop => 'Topga chiqarish';

  @override
  String get promotedBadge => 'Targ\'ib';

  @override
  String get featured => 'Tavsiya';

  @override
  String get featuredSubtitle => 'Reklama qilingan e’lonlar';

  @override
  String get filters => 'Filtrlar';

  @override
  String get applyFilters => 'Qo‘llash';

  @override
  String get resetFilters => 'Tozalash';

  @override
  String get priceFrom => 'Narx, dan';

  @override
  String get priceTo => 'Narx, gacha';

  @override
  String get currency => 'Valyuta';

  @override
  String get region => 'Viloyat';

  @override
  String get anyRegion => 'Har qanday hudud';

  @override
  String get sortBy => 'Saralash';

  @override
  String get sortRecommended => 'Tavsiya';

  @override
  String get recommendedForYou => 'Siz uchun tavsiya';

  @override
  String get recommendedForYouSubtitle => 'Faoliyatingiz asosida';

  @override
  String get trendingNow => 'Trendda';

  @override
  String get trendingNowSubtitle => 'Bu hafta mashhur';

  @override
  String get nearYou => 'Yoningizda';

  @override
  String get nearYouSubtitle => 'Hududingizdagi e’lonlar';

  @override
  String get recentlyViewed => 'Yaqinda ko‘rilgan';

  @override
  String get recentlyViewedSubtitle => 'Qayerda qolganingizdan';

  @override
  String get newArrivals => 'Yangi kelganlar';

  @override
  String get newArrivalsSubtitle => 'Bugungi yangi e’lonlar';

  @override
  String get similarProducts => 'O‘xshash mahsulotlar';

  @override
  String get peopleAlsoViewed => 'Boshqalar ham ko‘rdi';

  @override
  String get sortNewest => 'Avval yangilari';

  @override
  String get sortPriceAsc => 'Arzonidan qimmatigacha';

  @override
  String get sortPriceDesc => 'Qimmatidan arzoniga';

  @override
  String get tryAnotherSearch =>
      'Boshqa so‘rov bilan urinib ko‘ring yoki buyurtma joylang';

  @override
  String get createProductUnfinishedTitle => 'E\'lonni tugatmagansiz';

  @override
  String get createProductUnfinishedHint =>
      'Davom ettirasizmi yoki yangisini yaratasizmi?';

  @override
  String get createProductContinueDraft => 'Davom etish';

  @override
  String get createProductStartNew => 'Yangi e\'lon';

  @override
  String get createProductUntitled => 'Nomsiz';

  @override
  String get createProductExitTitle => 'Chop etmasdan chiqasizmi?';

  @override
  String get createProductExitHint =>
      'Qoralamani saqlab, keyinroq davom ettirishingiz mumkin.';

  @override
  String get createProductKeepEditing => 'Tahrirlashni davom etish';

  @override
  String get createProductSaveAndExit => 'Saqlab chiqish';

  @override
  String get createProductDiscardDraft => 'Qoralamani o\'chirish';

  @override
  String get createProductStepPhotos => 'Rasmlar';

  @override
  String get createProductStepVehicle => 'Avto';

  @override
  String get createProductStepInfo => 'Tavsif';

  @override
  String get createProductStepPrice => 'Narx';

  @override
  String get createProductStepLocation => 'Joy';

  @override
  String get createProductStepPreview => 'Ko\'rish';

  @override
  String get createProductPreviewTitle => 'Oldindan ko\'rish';

  @override
  String get createProductPreviewSubtitle =>
      'Xaridorlar e\'loningizni shunday ko\'radi.';

  @override
  String get createProductLocationTitle => 'Qayerda joylashgan?';

  @override
  String get createProductLocationHint =>
      'Xaritada nuqta tanlang — yaqin atrofdagi xaridorlar tezroq topadi.';

  @override
  String get createProductUseMyLocation => 'Joylashuvim';

  @override
  String get createProductConditionNewHint => 'Yangi, ishlatilmagan';

  @override
  String get createProductConditionUsedHint => 'Ishlatilgan, ishlaydi';

  @override
  String get createProductContinue => 'Davom etish';

  @override
  String get createProductPublishNow => 'E\'lon qilish';

  @override
  String get createProductUpdateListing => 'E\'lonni yangilash';

  @override
  String createProductStepProgress(int current, int total) {
    return '$total dan $current-qadam';
  }

  @override
  String get createProductDraftSaved => 'Qoralama saqlandi';

  @override
  String get createProductPhotosTitle => 'Rasmlar sotuvni tezlashtiradi';

  @override
  String get createProductPhotosHint =>
      'Birinchi rasm — muqova. 8 tagacha rasm.';

  @override
  String get createProductTapAddPhotos => 'Rasm qo\'sish uchun bosing';

  @override
  String get createProductGallery => 'Galereya';

  @override
  String get createProductCamera => 'Kamera';

  @override
  String get createProductAddMorePhotos => 'Yana rasm qo\'shish';

  @override
  String get createProductCover => 'Muqova';

  @override
  String get createProductDragReorder => 'Tartiblash uchun sudrab o\'ting';

  @override
  String get createProductTrustTitle => 'Yaxshi rasmlar tezroq sotadi';

  @override
  String get createProductTrustBody =>
      '3+ rasm, aniq sarlavha va adolatli narx — xaridorlar to\'liq e\'lonlarga ishonadi.';

  @override
  String get createProductInfoTitle => 'Ehtiyot qismini tasvirlang';

  @override
  String get createProductTitleHint =>
      'masalan, Toyota Camry tormoz kolodkalari — yangi';

  @override
  String get createProductVehicleTitle => 'Qaysi avtomobil uchun?';

  @override
  String get createProductVehicleHint =>
      'Xaridorlar ehtiyot qismini tezroq topadi.';

  @override
  String get createProductRecentlyUsed => 'Yaqinda ishlatilgan';

  @override
  String get createProductBrand => 'Brend';

  @override
  String get createProductPartCategory => 'Ehtiyot qism kategoriyasi';

  @override
  String get createProductYearOptional => 'Yil (ixtiyoriy)';

  @override
  String get createProductSelect => 'Tanlash';

  @override
  String get createProductNoModels =>
      'Bu brend uchun modellar yo\'q. Boshqa brendni tanlang.';

  @override
  String get createProductPriceTitle => 'Narxni belgilang';

  @override
  String createProductPriceSuggested(int price, String currency) {
    return 'Taxminiy: $price $currency atrofida';
  }

  @override
  String get createProductNegotiableTitle => 'Kelishiladi';

  @override
  String get createProductNegotiableSubtitle =>
      'Xaridor o\'z narxini taklif qilishi mumkin';

  @override
  String createProductPublishing(int percent) {
    return 'E\'lon qilinmoqda… $percent%';
  }

  @override
  String get createProductPublishedSuccess => 'E\'lon muvaffaqiyatli joylandi';

  @override
  String get createProductOfflineBanner =>
      'Internet yo\'q — formani to\'ldiring, keyinroq e\'lon qiling.';

  @override
  String get createProductWarnNoPhotos => 'Kamida bitta rasm qo\'shing';

  @override
  String get createProductWarnTitleShort => 'Sarlavha juda qisqa';

  @override
  String get createProductWarnNoCategory => 'Avto yoki kategoriyani tanlang';

  @override
  String get createProductWarnNoPrice => 'Narxni kiriting';

  @override
  String get createProductWarnNoCurrency => 'Valyutani tanlang';

  @override
  String get createProductDuplicateTitle =>
      'Yaqinda shu sarlavha bilan e\'lon qilgansiz';

  @override
  String get createProductQuickErrorPhoto => 'Rasm qo\'shing';

  @override
  String get createProductQuickErrorTitle => 'Sarlavha (3+ belgi)';

  @override
  String get createProductQuickErrorPrice => 'Narxni kiriting';

  @override
  String get createProductOfflinePublish =>
      'Internet yo\'q. Qoralama saqlandi — keyinroq urinib ko\'ring.';

  @override
  String get createProductErrorSignIn => 'E\'lon qilish uchun tizimga kiring.';

  @override
  String get createProductErrorServer =>
      'Serverga ulanib bo\'lmadi. Internet va backendni tekshiring.';

  @override
  String get createProductErrorCategory =>
      'Kategoriyani tanlang (Avto qadami).';

  @override
  String get createProductRetry => 'Qayta urinish';

  @override
  String get createProductOk => 'OK';

  @override
  String get chatConversationTitle => 'Chat';

  @override
  String get chatHeaderTyping => 'Yozmoqda…';

  @override
  String get chatPeerRecentlyActive => 'Yaqinda bu chatda aktiv edi';

  @override
  String chatPeerLastSeenInChat(Object time) {
    return 'So‘nggi javob · $time';
  }

  @override
  String get chatPeerNoMessagesYet => 'Hali xabar yoʻq';

  @override
  String get chatHeaderInChatOnlyHint => '(faqat shu chat bo‘yicha)';

  @override
  String get chatJustNow => 'hozirgina';

  @override
  String chatMinutesAgo(Object n) {
    return '$n daqiqa oldin';
  }

  @override
  String chatHoursAgo(Object n) {
    return '$n soat oldin';
  }

  @override
  String chatDaysAgo(Object n) {
    return '$n kun oldin';
  }

  @override
  String get chatReply => 'Javob berish';

  @override
  String get chatCopy => 'Nusxalash';

  @override
  String get chatCopied => 'Nusxalandi';

  @override
  String get chatOriginalMessageNotLoaded =>
      'Asl xabar hali yuklanmagan. Ko‘proq yuklash uchun yuqoriga suring.';

  @override
  String get chatSelectConversation => 'Suhbatni tanlang';

  @override
  String get chatSelectConversationHint =>
      'Xabar yozish uchun ro‘yxatdan chatni tanlang.';

  @override
  String get chatMessageHintDesktop =>
      'Xabar yozing… (Enter — yuborish, Shift+Enter — yangi qator)';

  @override
  String chatReplyingTo(String name) {
    return '$name ga javob';
  }

  @override
  String get chatMessageHint => 'Xabar…';

  @override
  String get chatAttach => 'Biriktirish';

  @override
  String get chatAttachPhotos => 'Galereyadan rasm';

  @override
  String get chatTakePhoto => 'Suratga olish';

  @override
  String get chatLastPhoto => 'Rasm';

  @override
  String get chatLastVoice => 'Ovozli xabar';

  @override
  String get chatMicPermissionRequired =>
      'Ovozli xabar yozish uchun mikrofon ruxsati kerak.';

  @override
  String get chatVoiceHoldHint => 'Yozish uchun ushlab turing';

  @override
  String get chatVoiceSlideToCancel => '← Bekor qilish uchun suring';

  @override
  String get chatVoiceReleaseToCancel => 'Bekor qilish uchun qoʻyib yuboring';

  @override
  String get searchHubUnifiedTitle => 'Kashfiyot';

  @override
  String get searchHubEverythingHint =>
      'Mahsulotlar, Avto Xizmatlar, buyurtmalar va sotuvchilar…';

  @override
  String get searchHubVoiceSoon => 'Ovozli qidiruv tez orada';

  @override
  String get searchHubOpenMap => 'Xarita';

  @override
  String get searchHubAdvancedProductFilters => 'Mahsulot filtrlari';

  @override
  String get searchHubRecent => 'So‘nggi qidiruvlar';

  @override
  String get searchHubClearRecent => 'Tozalash';

  @override
  String get searchHubTrending => 'Trendlar';

  @override
  String get searchHubCategoryIdeas => 'Mashhur turkumlar';

  @override
  String get searchHubExploreTitle => 'Kashfiyot';

  @override
  String get searchHubBrowseAllCategories => 'Barcha turkumlar';

  @override
  String get searchHubCarBrands => 'Avtomobil markalari';

  @override
  String get searchHubExploreHint => 'Nima qidiryapsiz?';

  @override
  String get searchHubQuickParts => 'Ehtiyot qismlar';

  @override
  String get searchHubQuickNearby => 'Yaqin atrofda';

  @override
  String get searchHubAwaitingTyping =>
      'Yozganingiz bilan qidiruvni birlashtirib, mahsulotlar, Avto Xizmatlar, xarita xizmatlari va buyurtmalarni ko‘rsatamiz.';

  @override
  String get searchHubSearching => 'Qidirilmoqda…';

  @override
  String get searchHubNoGroupedHits => 'Hozircha mos kelmaydi';

  @override
  String get searchHubSectionProducts => 'Mahsulotlar';

  @override
  String get searchHubSectionWorkshops => 'Avto Xizmatlar';

  @override
  String get searchHubSectionServices => 'Xizmatlar';

  @override
  String get searchHubSectionOrders => 'Buyurtmalar';

  @override
  String get searchHubSectionSellers => 'Sotuvchilar';

  @override
  String get homeStickyNearYou => 'Atrof';

  @override
  String get homeStickyChooseLocation => 'Joylashuv';

  @override
  String get homeExploreNearbyTitle => 'Jonli xarita';

  @override
  String get homeExploreNearbySubtitle =>
      'Avto Xizmatlar • mahsulotlar • aktiv so‘rovlar';

  @override
  String get homeQuickActionsRow => 'Tezkor boshlash';

  @override
  String get homeHotOrdersPreview => 'Faol buyurtmalar';

  @override
  String get homeNearbyWorkshopsPreview => 'Atrofda Avto Xizmatlar';

  @override
  String get homeTrendingServicesPreview => 'Mashhur xizmatlar';

  @override
  String get homeSellerSpotlight => 'Sara sotuvchilar';

  @override
  String get homeChatsPreviewSection => 'Suhbatlar';

  @override
  String get homeAlertsPreviewSection => 'Signal';

  @override
  String get homeOpenMessages => 'Xabarlar';

  @override
  String get homeOpenNotifications => 'Bildirishnomalar';

  @override
  String homeListingCountHint(Object n) {
    return '$n eʼlonlar';
  }

  @override
  String get notificationsCenterTitle => 'Bildirishnomalar';

  @override
  String get notificationsCenterEmptyBody =>
      'Yangi obunachilar, buyurtmalar, xizmat javoblari va aksiyalar shu yerda. Suhbatlar «Xabarlar» bo‘limida.';

  @override
  String get notificationsMarkAllRead => 'Hammasini o\'qilgan deb belgilash';

  @override
  String get notificationsRecent => 'So\'nggi bildirishnomalar';

  @override
  String get notificationsCenterFooterHint =>
      'Ushbu qurilmada buyurtma, Avto Xizmatlar va aksiya haqida xabar olasiz.';

  @override
  String get notificationsAlertsOn => 'Bildirishnomalar yoqilgan';

  @override
  String get notificationsAlertsOff => 'Bildirishnomalar o‘chirilgan';

  @override
  String get notificationsEnableHint =>
      'Buyurtma va chat yangilanishlarini o‘tkazib yubormaslik uchun bildirishnomalarni yoqing.';

  @override
  String get notificationsEnableButton => 'Bildirishnomalarni yoqish';

  @override
  String get notificationsWhatYouGet => 'Nimalar keladi';

  @override
  String get notificationsTopicMessages => 'Yangi xabarlar va chat javoblari';

  @override
  String get notificationsTopicOrders =>
      'Buyurtma holati va sotuvchi/xaridor yangilanishlari';

  @override
  String get notificationsTopicWorkshops =>
      'Avto Xizmatlar yozuvlari va javoblar';

  @override
  String get notificationsTopicPromos => 'Chegirmalar va TOP e’lonlar';

  @override
  String get notificationsTopicFollowers => 'Do\'konga yangi obunachilar';

  @override
  String get notificationsIosSettingsHint =>
      'Shuningdek Sozlamalar → Bildirishnomalar → Garage orqali yoqish mumkin.';

  @override
  String get homeNoChatsYet => 'Chatlar yo‘q';

  @override
  String get homeSeeCategoryServices => 'Xizmatlarga';

  @override
  String get homeQuickSellProduct => 'Sotish';

  @override
  String get homeQuickCreateOrder => 'Buyurtma';

  @override
  String get homeQuickAddWorkshop => 'Avto Xizmatlar';

  @override
  String get notificationsPermissionHintShort => 'Bildirishnomani yoqing';

  @override
  String get searchHubScopeCars => 'Avto';

  @override
  String get searchHubScopeParts => 'Ehtiyot';

  @override
  String get searchHubScopeServices => 'Xizmat';

  @override
  String get searchHubScopeWorkshops => 'Servis';

  @override
  String get searchHubScopeOrders => 'Buyurtma';

  @override
  String get searchHubScopeNearby => 'Atrof';

  @override
  String get searchHubScopeCarsSeed => 'avtomobil';

  @override
  String get searchHubScopePartsSeed => 'zapchast';

  @override
  String get searchHubScopeWorkshopsSeed => 'avto xizmatlar';

  @override
  String get errorGeneric => 'Xatolik yuz berdi. Qayta urinib ko‘ring.';

  @override
  String get errorAuthUnauthorized => 'Davom etish uchun tizimga kiring.';

  @override
  String get errorAuthForbidden => 'Bu amal uchun ruxsat yo‘q.';

  @override
  String get errorAuthUserExists =>
      'Bu telefon raqami allaqachon ro‘yxatdan o‘tgan.';

  @override
  String get errorAuthUserNotFound => 'Hisob topilmadi.';

  @override
  String get errorAuthInvalidCredentials => 'Telefon yoki parol noto‘g‘ri.';

  @override
  String get errorAuthInvalidOtp => 'Tasdiqlash kodi noto‘g‘ri.';

  @override
  String get errorAuthOtpExpired => 'Kod muddati tugagan. Yangisini so‘rang.';

  @override
  String get errorAuthConfirmationTokenMissing =>
      'Ro‘yxatdan o‘tish sessiyasi tugagan. Qayta ro‘yxatdan o‘ting.';

  @override
  String get errorAuthConfirmationTokenInvalid =>
      'Ro‘yxatdan o‘tish sessiyasi noto‘g‘ri.';

  @override
  String get errorAuthConfirmationTokenExpired =>
      'Tasdiqlash muddati tugagan. Yangi kod so‘rang.';

  @override
  String get errorAuthSubscriptionRequired =>
      'Jonli yangilanishlar uchun xavfsiz ulanish kerak.';

  @override
  String get errorValidationFailed =>
      'Ma’lumotlarni tekshirib, qayta urinib ko‘ring.';

  @override
  String get errorValidationFileTooLarge => 'Fayl juda katta.';

  @override
  String get errorValidationFileTypeInvalid =>
      'Bu fayl turi qo‘llab-quvvatlanmaydi.';

  @override
  String get errorValidationRequestTooLarge => 'So‘rov juda katta.';

  @override
  String get errorValidationRequestTooComplex =>
      'So‘rov juda murakkab. Soddalashtirib qayta urining.';

  @override
  String get errorResourceNotFound => 'Topilmadi.';

  @override
  String get errorOrderNotFound => 'Buyurtma topilmadi.';

  @override
  String get errorOrderNotClosed => 'Buyurtma yopilmagan.';

  @override
  String get errorPartNotFound => 'E’lon topilmadi.';

  @override
  String get errorWorkshopNotFound => 'Avto Xizmatlar topilmadi.';

  @override
  String get errorServiceNotFound => 'Xizmat topilmadi.';

  @override
  String get errorConversationNotFound => 'Chat topilmadi.';

  @override
  String get errorMessageNotFound => 'Xabar topilmadi.';

  @override
  String get errorBusinessNotParticipant =>
      'Siz bu chat ishtirokchisi emassiz.';

  @override
  String get errorBusinessNotAllowed => 'Bu amal ruxsat etilmagan.';

  @override
  String get errorBusinessCannotReviewOwn =>
      'O‘zingizga sharh qoldira olmaysiz.';

  @override
  String get errorBusinessAlreadyReviewed =>
      'Siz allaqachon sharh qoldirgansiz.';

  @override
  String get errorBusinessCannotBookOwn => 'O‘z xizmatingizga yozila olmaysiz.';

  @override
  String get errorBusinessCannotRespondOwnOrder =>
      'O‘z buyurtmangizga javob bera olmaysiz.';

  @override
  String get errorBusinessOrderWatchDenied => 'Bu buyurtmani kuzata olmaysiz.';

  @override
  String get errorBusinessMessageTooLong => 'Xabar juda uzun.';

  @override
  String get errorBusinessRateLimit =>
      'Juda ko‘p so‘rov. Biroz kutib qayta urining.';

  @override
  String get errorWsUnauthenticated => 'Ulanish autentifikatsiya qilinmagan.';

  @override
  String get errorWsTooManyConnections => 'Juda ko‘p faol ulanish.';

  @override
  String get errorWsHandshakeRateLimited => 'Juda ko‘p ulanish urinishi.';

  @override
  String get errorWsOriginNotAllowed => 'Xavfsizlik sababli ulanish bloklandi.';

  @override
  String get errorDeviceOffline =>
      'Qurilma oflayn. Yangilanishlar uchun ilovani oching.';

  @override
  String get errorCannotMessageSelf => 'O\'zingizga xabar yubora olmaysiz';

  @override
  String get errorSellerUnavailable => 'Sotuvchi mavjud emas';

  @override
  String get errorAuthorUnavailable => 'Muallif mavjud emas';

  @override
  String get errorNoListings => 'E\'lonlar yo\'q';

  @override
  String get workshopVerified => 'Tasdiqlangan';

  @override
  String get workshopOpenNow => 'Hozir ochiq';

  @override
  String get workshopFastResponse => 'Tez javob';

  @override
  String get workshopAbout => 'Avtoservis haqida';

  @override
  String get workshopServiceTypes => 'Xizmat turlari';

  @override
  String get similarWorkshops => 'O‘xshash avtoservislar';

  @override
  String get similarOrders => 'O‘xshash buyurtmalar';

  @override
  String viewsCountLabel(int count) {
    return '$count';
  }

  @override
  String get workshopOnRequest => 'So\'rov bo\'yicha';

  @override
  String workshopPriceFrom(String amount, String currency) {
    return '$amount $currency dan';
  }

  @override
  String workshopOwnerReply(String text) {
    return 'Egasi: $text';
  }

  @override
  String get bookNow => 'Yozilish';

  @override
  String get bookServiceTitle => 'Xizmatga yozilish';

  @override
  String get bookWorkshopRequestSent => 'Yozilish so\'rovi yuborildi';

  @override
  String get bookWorkshopCouldNotBook =>
      'Yozilib bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get bookDate => 'Sana';

  @override
  String get bookTime => 'Vaqt';

  @override
  String get bookDateTime => 'Sana va vaqt';

  @override
  String get bookNotesOptional => 'Usta uchun izoh (ixtiyoriy)';

  @override
  String get bookConfirmBooking => 'Yozilishni tasdiqlash';

  @override
  String get bookRequestBooking => 'So\'rov yuborish';

  @override
  String get bookServiceOptional => 'Xizmat (ixtiyoriy)';

  @override
  String get bookServiceHint => 'Moy almashtirish, diagnostika…';

  @override
  String get bookNotes => 'Izoh';

  @override
  String get chatNoConversationsYet => 'Hali suhbatlar yo\'q';

  @override
  String get chatSayHello => 'Salom yozing';

  @override
  String get chatReconnecting => 'Qayta ulanmoqda…';

  @override
  String get mapLayerWorkshops => 'Usta joylari';

  @override
  String get mapLayerRequests => 'So\'rovlar';

  @override
  String get mapFiltersTitle => 'Filtrlar va xarita';

  @override
  String get mapHeatmapTitle => 'Issiqlik xaritasi';

  @override
  String get mapHeatmapSubtitle => 'Ko\'proq e\'lon bo\'lgan hududlar';

  @override
  String get mapShownOnMap => 'Xaritada';

  @override
  String get mapQuickFilters => 'Tez filtrlar';

  @override
  String get mapAllWorkshops => 'Barcha usta joylari';

  @override
  String get mapSearchRadius => 'Qidiruv radiusi';

  @override
  String get mapOpenPin => 'Ochish';

  @override
  String get mapRouteTooltip => 'Marshrut';

  @override
  String get mapShareTooltip => 'Ulashish';

  @override
  String get mapLocationDefaultArea =>
      'Standart hudud — aniqroq natija uchun geolokatsiyani yoqing';

  @override
  String get mapLocationGpsDisabled => 'Qurilmada GPS ni yoqing';

  @override
  String get mapLocationPermissionRequired => 'Joylashuv ruxsati kerak';

  @override
  String get mapLocationPermissionForever =>
      'Ilova sozlamalarida geolokatsiyani ruxsat bering';

  @override
  String get mapLocationFailed => 'Joylashuv aniqlanmadi';

  @override
  String get mapFilterOpenNow => 'Hozir ochiq';

  @override
  String get mapFilterNearby => 'Yaqin atrofda';

  @override
  String get mapFilterVerified => 'Tasdiqlangan';

  @override
  String get mapFilterTopRated => 'Eng yaxshi';

  @override
  String get mapFilterPremium => 'Premium';

  @override
  String get workshopScreenTitle => 'Usta joylari';

  @override
  String get workshopScreenSubtitle =>
      'Yaqin atrofdagi ishonchli avtoservislar';

  @override
  String get servicesHubSubtitle =>
      'Tasdiqlangan servislarni toping va onlayn yoziling';

  @override
  String get servicesHubEmptyNearby =>
      'Hozircha yaqin atrofda joylashuvi bor servislar yo\'q. Xaritani oching yoki biznesingizni qo\'shing.';

  @override
  String get servicesHubEmptyTopRated => 'Hozircha eng yaxshi servislar yo\'q.';

  @override
  String get servicesHubOpenMapSubtitle =>
      'Usta joylari va xizmatlarni xaritada ko\'ring';

  @override
  String get workshopPopular => 'Mashhur';

  @override
  String get workshopNearbyTitle => 'Yaqin usta joylari';

  @override
  String get workshopSearchResults => 'Qidiruv natijalari';

  @override
  String get workshopsLiveMap => 'Xarita';

  @override
  String get trendingTires => 'Shinalar';

  @override
  String get trendingDiagnostics => 'Diagnostika';

  @override
  String get trendingEngineOil => 'Dvigatel moyi';

  @override
  String get trendingTowTruck => 'Evakuator';

  @override
  String get trendingDetailing => 'Deteyling';

  @override
  String get trendingAkp => 'Avtomat uzatma';

  @override
  String get trendingBattery => 'Akkumulyator';

  @override
  String get trendingBrakes => 'Tormozlar';

  @override
  String get orderPartEngine => 'Dvigatel';

  @override
  String get orderPartBumper => 'Bamper';

  @override
  String get orderPartHeadlights => 'Faralar';

  @override
  String get orderPartBrakes => 'Tormozlar';

  @override
  String get orderPartSuspension => 'Osma tizim';

  @override
  String orderDetailNeedsPart(String part) {
    return 'Kerak: $part';
  }

  @override
  String get serviceFeatures => 'Xususiyatlar';

  @override
  String get signInToBookService => 'Yozilish uchun tizimga kiring';

  @override
  String get signInToMessageBuyer => 'Xaridor bilan yozishish uchun kiring';

  @override
  String get badgeVerified => 'TASDIQLANGAN';

  @override
  String get badgePremium => 'PREMIUM';

  @override
  String get badgeFast => 'TEZ';

  @override
  String get badgeTopRated => 'Eng yuqori';

  @override
  String get createWorkshopServicesTitle =>
      'Taklif qiladigan xizmatlarni tanlang';

  @override
  String get createWorkshopPopular => 'Mashhur';

  @override
  String get createWorkshopAllServices => 'Barcha xizmatlar';

  @override
  String createWorkshopServicesHint(int count) {
    return 'Xizmat turlari ($count). Biznesingizga moslarini tanlang.';
  }

  @override
  String get saveChanges => 'O\'zgarishlarni saqlash';

  @override
  String get comingSoon => 'Tez orada';

  @override
  String get follow => 'Obuna bo\'lish';

  @override
  String get following => 'Obuna';

  @override
  String get shareProfile => 'Profilni ulashish';

  @override
  String sellerFollowersProducts(
      String followers, String products, String date) {
    return '$followers obunachi • $products mahsulot • $date dan';
  }

  @override
  String get sellerStatProducts => 'Mahsulotlar';

  @override
  String get sellerStatCategories => 'Kategoriyalar';

  @override
  String get sellerStatFollowers => 'Obunachilar';

  @override
  String get noFollowersYet => 'Hali obunachilar yo\'q';

  @override
  String followedOn(String date) {
    return 'Obuna bo\'lgan sana: $date';
  }

  @override
  String get sellerStatProfileViews => 'Profil ko\'rishlar';

  @override
  String get sellerStatActiveProducts => 'Faol';

  @override
  String get sellerCategories => 'Sotuvchi kategoriyalari';

  @override
  String get sellerBioSection => 'Haqida';

  @override
  String get sellerDescriptionSection => 'Tavsif';

  @override
  String get sellerSocialLinks => 'Ijtimoiy tarmoqlar';

  @override
  String get sellerInformation => 'Sotuvchi haqida';

  @override
  String get latestProducts => 'Yangi';

  @override
  String get popularProducts => 'Mashhur';

  @override
  String get searchSellerProducts => 'Do\'konda qidirish';

  @override
  String get sortPriceLowHigh => 'Narx: arzon → qimmat';

  @override
  String get sortPriceHighLow => 'Narx: qimmat → arzon';

  @override
  String get viewProfile => 'Profilni ko\'rish';

  @override
  String get moreFromSeller => 'Bu sotuvchidan yana';

  @override
  String get sellerStoreEmpty => 'Sotuvchida hali mahsulot yo\'q';

  @override
  String get sellerStoreEmptyHint => 'Hali e\'lonlar yo\'q.';

  @override
  String get username => 'Foydalanuvchi nomi';

  @override
  String get bio => 'Qisqa bio';

  @override
  String get emailAddress => 'Elektron pochta';

  @override
  String get country => 'Mamlakat';

  @override
  String get city => 'Shahar';

  @override
  String get showLocationPublicly => 'Manzilni ko\'rsatish';

  @override
  String get privacySettings => 'Maxfiylik';

  @override
  String get showPhoneNumber => 'Telefonni ko\'rsatish';

  @override
  String get showEmail => 'Emailni ko\'rsatish';

  @override
  String get showFollowersCount => 'Obunachilarni ko\'rsatish';

  @override
  String get allowMessages => 'Xabarlarga ruxsat';

  @override
  String get sellerDashboardPreview => 'Do\'kon ko\'rinishi';

  @override
  String get aboutSection => 'Haqida';

  @override
  String get publicVisibility => 'Ochiq';

  @override
  String get privateVisibility => 'Yashirin';

  @override
  String get gridView => 'Panjara';

  @override
  String get listView => 'Ro\'yxat';

  @override
  String sellerAtUsername(String username) {
    return '@$username';
  }

  @override
  String get editStore => 'Do\'konni tahrirlash';

  @override
  String get manageProducts => 'Mahsulotlarni boshqarish';

  @override
  String get storeAnalytics => 'Do\'kon analitikasi';

  @override
  String get unableToLoadStore => 'Do\'konni yuklab bo\'lmadi';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get storeProfileCompletion => 'Profil to\'ldirilishi';

  @override
  String get missingFields => 'Yetishmayapti:';

  @override
  String get completeProfile => 'Profilni to\'ldirish';

  @override
  String get missingAvatar => 'Profil rasmi';

  @override
  String get missingStoreBanner => 'Do\'kon banneri';

  @override
  String get missingBio => 'Bio';

  @override
  String get missingDescription => 'Tavsif';

  @override
  String get missingSocialLinks => 'Ijtimoiy tarmoqlar';

  @override
  String get missingLocation => 'Manzil';

  @override
  String get missingUsername => 'Foydalanuvchi nomi';

  @override
  String get changeBanner => 'Bannerni o\'zgartirish';

  @override
  String get quickSellerDashboard => 'Tezkor panel';

  @override
  String get dashboardToday => 'Umumiy ko\'rinish';

  @override
  String get dashboardProductViews => 'Mahsulot ko\'rishlari';

  @override
  String get dashboardMessages => 'Xabarlar';

  @override
  String get dashboardNewFollowers => 'Obunachilar';

  @override
  String get dashboardProductsSold => 'Sotilgan';

  @override
  String get openAnalytics => 'Analitikani ochish';

  @override
  String get quickActions => 'Tezkor harakatlar';

  @override
  String get productManagement => 'Mahsulotlar boshqaruvi';

  @override
  String get draftProducts => 'Qoralamalar';

  @override
  String get archivedProducts => 'Arxiv';

  @override
  String get pendingModeration => 'Moderatsiyada';

  @override
  String get storeCreated => 'Do\'kon yaratilgan';

  @override
  String get verificationStatus => 'Tasdiqlash';

  @override
  String get notVerified => 'Tasdiqlanmagan';

  @override
  String get verifiedAccountTitle => 'Tasdiqlangan akkaunt';

  @override
  String get verifiedAccountVisitorInfo =>
      'AutoRin jamoasi bu sotuvchi va doʻkonini tekshirgan. Belgi haqiqiy va ishonchli sotuvchi ekanligini bildiradi — xavotirsiz xarid qilishingiz mumkin.';

  @override
  String get verifiedAccountOwnerInfo =>
      'Doʻkoningiz AutoRin tomonidan tasdiqlangan. Xaridorlar ismingiz yonida tasdiqlangan belgisini koʻradi va eʻlonlaringizga koʻproq ishonadi.';

  @override
  String get verifiedAccountPointIdentity => 'Sotuvchi shaxsi tasdiqlangan';

  @override
  String get verifiedAccountPointTrusted => 'AutoRinʼdagi ishonchli doʻkon';

  @override
  String get verificationWhatIsIt =>
      'Tasdiqlash doʻkoningiz haqiqiy ekanini bildiradi. Tasdiqlangan sotuvchilar belgi oladi va xaridorlar koʻproq ishonadi.';

  @override
  String get contactPreferences => 'Aloqa';

  @override
  String get messagesDisabled => 'Xabarlar o\'chirilgan';

  @override
  String get ownerStoreEmpty => 'Hali mahsulotingiz yo\'q';

  @override
  String get addFirstProduct => 'Birinchi mahsulotni qo\'shing';

  @override
  String get unfollow => 'Obunadan chiqish';

  @override
  String get unfollowConfirm => 'Sotuvchidan obunadan chiqasizmi?';

  @override
  String get range7Days => '7 kun';

  @override
  String get range30Days => '30 kun';

  @override
  String get range90Days => '90 kun';

  @override
  String get dashboardLeads => 'Murojaatlar';

  @override
  String get productClicks => 'Mahsulot bosishlari';

  @override
  String get topProducts => 'Top mahsulotlar';

  @override
  String get topCategories => 'Top kategoriyalar';

  @override
  String get chats => 'Xabarlar';

  @override
  String get myStore => 'Mening do\'konim';

  @override
  String get ownerMyListings => 'Mening e\'lonlarim';

  @override
  String get myListingsTotalLabel => 'Jami e\'lonlar';

  @override
  String myListingsBreakdown(String activeLabel, int activeCount,
      String inactiveLabel, int inactiveCount) {
    return '$activeLabel · $activeCount · $inactiveLabel · $inactiveCount';
  }

  @override
  String get workshopUntitled => 'Nomsiz ustaxona';

  @override
  String get workshopStatusOpen => 'Ochiq';

  @override
  String get workshopStatusClosed => 'Yopiq';

  @override
  String get promoteListingTitle => 'E\'lonni targ\'ib qilish';

  @override
  String get promoteProductTitle => 'Mahsulotni targ\'ib qilish';

  @override
  String get promoteWorkshopTitle => 'Ustaxonani targ\'ib qilish';

  @override
  String get promoteServiceTitle => 'Xizmatni targ\'ib qilish';

  @override
  String get promotePlanBasic => 'Asosiy';

  @override
  String get promotePlanStandard => 'Standart';

  @override
  String get promotePlanPremium => 'Premium';

  @override
  String get promotePlanVip => 'VIP';

  @override
  String promotePlanDuration(int days, int priority) {
    return '$days kun · ustuvorlik $priority';
  }

  @override
  String get activatePromotion => 'Targ\'ibni yoqish';

  @override
  String get promotionActivatedSuccess => 'Targ\'ib muvaffaqiyatli yoqildi';

  @override
  String get notificationAccountVerifiedTitle => 'Siz tasdiqlandingiz';

  @override
  String get notificationAccountVerifiedBody =>
      'AutoRin jamoasi akkauntingizni tasdiqladi.';

  @override
  String get notificationNewFollowerTitle => 'Yangi obunachi';

  @override
  String get notificationNewFollowerBody =>
      'Kimdir doʻkoningizga obuna boʻldi.';

  @override
  String get notificationOrderReplyTitle => 'Buyurtma yangilandi';

  @override
  String get notificationPromotedExpiredTitle => 'Targ\'ib tugadi';

  @override
  String get notificationPromotedExpiredBody =>
      'E\'lon endi targ\'ib qilinmaydi. Yuqorida qolish uchun yangilang.';

  @override
  String get notificationFavoriteMatchedTitle => 'Saqlanganlarga mos e\'lon';

  @override
  String get notificationFavoriteMatchedBody =>
      'Qidirganingizga o\'xshash e\'lon paydo bo\'ldi.';

  @override
  String get notificationSellerResponseTitle => 'Sotuvchi javob berdi';

  @override
  String get notificationNewMessageTitle => 'Yangi xabar';

  @override
  String get notificationNewMessageBody => 'Suhbatni ochish uchun bosing.';

  @override
  String get notificationOrderReplyBody =>
      'Buyurtmangiz bo\'yicha yangilanish bor.';

  @override
  String get notificationWorkshopBookingTitle => 'Ustaxona yozuvi';

  @override
  String get notificationWorkshopBookingBody =>
      'Yangi so\'rov yoki xizmat javobi.';

  @override
  String get notificationGenericAlertTitle => 'Garage';

  @override
  String get notificationGenericAlertBody => 'Sizda yangi bildirishnoma bor.';

  @override
  String get pushChannelName => 'Garage bildirishnomalari';

  @override
  String get pushChannelDescription =>
      'Xabarlar, buyurtmalar, xizmatlar va aksiyalar.';

  @override
  String get notificationOpenAction => 'Ochish';
}
