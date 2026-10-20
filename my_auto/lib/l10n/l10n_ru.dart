// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Garage';

  @override
  String homeGreeting(String name) {
    return 'Привет, $name';
  }

  @override
  String get appMarketplaceTagline => 'Маркетплейс Garage';

  @override
  String get fieldRequired => 'Поле обязательно';

  @override
  String get password => 'Пароль';

  @override
  String get passwordLength => 'Пароль должен содержать не менее 6 символов';

  @override
  String get phone => 'Телефон';

  @override
  String get signIn => 'Войти';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String get signInToContinueHint =>
      'Создайте аккаунт, чтобы писать продавцам, сохранять избранное и публиковать объявления.';

  @override
  String get continueBrowsing => 'Продолжить просмотр';

  @override
  String get browseAsGuest => 'Смотреть без входа';

  @override
  String get skip => 'Пропустить';

  @override
  String get guest => 'Гость';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get name => 'Имя';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get done => 'Готово';

  @override
  String get selectBirthDay => 'Выберите дату рождения';

  @override
  String get logIn => 'Войдите в свой аккаунт';

  @override
  String get home => 'Главная';

  @override
  String get profile => 'Профиль';

  @override
  String get services => 'Автосервис';

  @override
  String get add => 'Добавить';

  @override
  String get order => 'Заказ';

  @override
  String get search => 'Поиск';

  @override
  String get favorites => 'Избранное';

  @override
  String get favoritesEmpty => 'Пока нет сохранённых объявлений';

  @override
  String get update => 'Обновить';

  @override
  String get orders => 'Заказы';

  @override
  String get navWantToBuy => 'Мне нужно';

  @override
  String get wantToBuySubtitle =>
      'Не можете найти нужную деталь? Оставьте заявку — продавцы сами свяжутся с вами.';

  @override
  String get wantToBuySearchHint => 'Деталь, авто или город…';

  @override
  String get wantToBuyCreateCta => 'Оставить заявку';

  @override
  String wantToBuyRequestsCount(int count) {
    return '$count открыто';
  }

  @override
  String get wantToBuyRequestBadge => 'Заявка';

  @override
  String get wantToBuyBudget => 'Бюджет';

  @override
  String wantToBuyOffers(int count) {
    return '$count предложений';
  }

  @override
  String get wantToBuyStep1 => 'Заявка';

  @override
  String get wantToBuyStep2 => 'Цены';

  @override
  String get wantToBuyStep3 => 'Сделка';

  @override
  String get wantToBuyFeedTitle => 'Заявки покупателей';

  @override
  String get wantToBuyRespond => 'Предложить';

  @override
  String get wantToBuyEmptyTitle => 'Заявок пока нет';

  @override
  String get wantToBuyEmptyHint =>
      'Напишите, что нужно — магазины и продавцы пришлют предложения.';

  @override
  String get morning => 'Доброе утро';

  @override
  String get afternoon => 'Добрый день';

  @override
  String get night => 'Доброй ночи';

  @override
  String get specialOffers => 'Специальные предложения';

  @override
  String get seeAll => 'Все';

  @override
  String get topDeals => 'Запчасти и всё';

  @override
  String get whatDoYouWantSell => 'Что вы хотите продать?';

  @override
  String get passengerCars => 'Легковые автомобили';

  @override
  String get service => 'Сервис';

  @override
  String get parts => 'Запчасти';

  @override
  String get announcements => 'Объявления';

  @override
  String get tuning => 'Тюнинг';

  @override
  String get accountDetails => 'Данные аккаунта';

  @override
  String get notification => 'Уведомления';

  @override
  String get settings => 'Настройки';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get messages => 'Сообщения';

  @override
  String get writeSeller => 'Написать продавцу';

  @override
  String get callSeller => 'Позвонить продавцу';

  @override
  String get myServices => 'Мои услуги';

  @override
  String get myProducts => 'Мои товары';

  @override
  String get profileSectionMyActivity => 'Моя активность';

  @override
  String get profileSubtitleMyStore => 'Магазин, баннер и объявления';

  @override
  String get profileSubtitleMyProducts => 'Объявления и запчасти';

  @override
  String get profileSubtitleMyServices => 'Ваши мастерские';

  @override
  String get profileSubtitleMyOrders => 'Недавние заказы';

  @override
  String get sellerMatchingOrdersTitle => 'Реклама';

  @override
  String get sellerMatchingOrdersSubtitle =>
      'Подходящие заявки покупателей и их статус';

  @override
  String get sellerMatchingOrdersAll => 'Все подходящие заявки';

  @override
  String get sellerMatchingOrdersByCategory => 'По вашим категориям';

  @override
  String sellerMatchingOrdersTotalHint(int count) {
    return '$count активных заявок для вас';
  }

  @override
  String sellerMatchingOrdersListingsHint(int count) {
    return '$count ваших объявлений';
  }

  @override
  String get sellerMatchingOrdersEmptyListings => 'Пока нет товаров';

  @override
  String get sellerMatchingOrdersEmptyListingsHint =>
      'Добавьте товары в категориях, которыми торгуете — подходящие заявки появятся здесь.';

  @override
  String get sellerMatchingOrdersStatusActive => 'Активна';

  @override
  String get sellerMatchingOrdersStatusClosed => 'Закрыта';

  @override
  String sellerMatchingOrdersOpenCount(int count) {
    return '$count открытых';
  }

  @override
  String get notificationOrderMatchedTitle => 'Новая подходящая заявка';

  @override
  String get notificationOrderMatchedBody =>
      'Покупатель создал заявку в вашей категории.';

  @override
  String get profileSubtitleMessages => 'Чаты с продавцами';

  @override
  String get profileSectionPreferences => 'Настройки';

  @override
  String get profileSectionSupport => 'Поддержка';

  @override
  String get contactUs => 'Свяжитесь с нами';

  @override
  String get termsAndConditions => 'Условия использования';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get logout => 'Выйти';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get language => 'Язык';

  @override
  String get logoutDescription => 'Вы уверены, что хотите выйти?';

  @override
  String get logoutSubtitle => 'Вы будете перенаправлены на экран входа.';

  @override
  String get cancel => 'Отмена';

  @override
  String get email => 'Эл. почта';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicyIntro =>
      'Мы обязуемся защищать вашу конфиденциальность. Эта политика объясняет, как мы собираем, используем и защищаем ваши данные.';

  @override
  String get dataCollection => '1. Сбор данных';

  @override
  String get dataCollectionText =>
      'Мы собираем личную информацию, такую как имя, адрес электронной почты и номер телефона, когда вы создаете аккаунт или пользуетесь нашими услугами.';

  @override
  String get dataUsage => '2. Использование данных';

  @override
  String get dataUsageText =>
      'Ваши данные используются для предоставления и улучшения наших услуг, персонализации опыта и связи с вами.';

  @override
  String get thirdPartySharing => '3. Передача третьим лицам';

  @override
  String get thirdPartySharingText =>
      'Мы не продаем ваши данные. Мы можем делиться ими с третьими сторонами только для предоставления наших услуг (например, хостинг, аналитика).';

  @override
  String get contactInformation => 'Контакты';

  @override
  String get contactInformationText =>
      'Вопросы о конфиденциальности и данных: support@myauto.uz или +998 95 384 10 00.';

  @override
  String get privacyPolicyLastUpdated => 'Последнее обновление: июнь 2026';

  @override
  String get privacyAccountData => '2. Аккаунт и объявления';

  @override
  String get privacyAccountDataText =>
      'Мы храним профиль (имя, телефон, фото), объявления (запчасти, сервисы), сообщения, заказы и токены устройств для push-уведомлений. Геолокация используется только по вашему желанию.';

  @override
  String get privacyDataRetention => '5. Хранение данных';

  @override
  String get privacyDataRetentionText =>
      'Данные хранятся, пока аккаунт активен. При удалении аккаунта личные данные удаляются, объявления архивируются.';

  @override
  String get privacyAccountDeletion => '6. Удаление аккаунта';

  @override
  String get privacyAccountDeletionText =>
      'Удалить аккаунт можно в Профиль → Удалить аккаунт. Личные данные будут удалены, объявления архивированы. Отменить действие нельзя.';

  @override
  String get privacyChildren => '7. Дети';

  @override
  String get privacyChildrenText =>
      'My Auto не предназначен для пользователей младше 16 лет. Мы сознательно не собираем данные детей.';

  @override
  String get privacySecurity => '4. Безопасность';

  @override
  String get privacySecurityText =>
      'Мы используем шифрование (HTTPS), безопасную авторизацию и контроль доступа. Абсолютной защиты не существует, но мы стараемся обезопасить ваши данные.';

  @override
  String get privacyPolicyChanges => '9. Изменения политики';

  @override
  String get privacyPolicyChangesText =>
      'Мы можем обновлять эту политику. Продолжая пользоваться приложением, вы принимаете обновлённую версию.';

  @override
  String get contactUsIntro =>
      'Мы поможем с объявлениями, заказами и аккаунтом.';

  @override
  String get contactUsEmailSubtitle =>
      'Обычно отвечаем в течение 1 рабочего дня';

  @override
  String get contactUsPhoneSubtitle => 'Пн–Сб, 9:00–18:00 (время Ташкента)';

  @override
  String get supportEmail => 'support@myauto.uz';

  @override
  String get supportPhone => '+998 95 384 10 00';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountDescription => 'Удалить аккаунт навсегда?';

  @override
  String get deleteAccountSubtitle =>
      'Профиль и личные данные будут удалены. Объявления архивируются. Отменить нельзя.';

  @override
  String get deleteAccountConfirm => 'Удалить навсегда';

  @override
  String get deleteAccountSuccess => 'Ваш аккаунт удалён';

  @override
  String get deleteAccountFailed =>
      'Не удалось удалить аккаунт. Попробуйте снова или напишите в поддержку.';

  @override
  String get profileSectionAccount => 'Аккаунт';

  @override
  String get myListingsEmptyActive => 'Пока нет активных объявлений';

  @override
  String get myListingsEmptyInactive => 'Нет архивных объявлений';

  @override
  String get sessionExpired =>
      'Ваша сессия истекла. Пожалуйста, войдите снова.';

  @override
  String get noInternetConnection =>
      'Нет соединения с интернетом. Проверьте настройки сети.';

  @override
  String get serverNotWorking =>
      'Сервер в настоящее время не работает. Пожалуйста, попробуйте позже.';

  @override
  String get errorOccurred => 'Произошла ошибка. Пожалуйста, попробуйте позже.';

  @override
  String get success => 'Успешно';

  @override
  String get error => 'Ошибка';

  @override
  String get info => 'Информация';

  @override
  String get select => 'Выбрать';

  @override
  String get enterCodeMessage =>
      'Мы отправили вам 5-значный код — введите его здесь, чтобы продолжить';

  @override
  String get confirmationCodeNeedsToBe5Symbols =>
      'Код подтверждения должен содержать 5 символов';

  @override
  String get invalidOtpCode => 'Неверный код';

  @override
  String get userAlreadyExists => 'Пользователь уже существует';

  @override
  String get titleOfParts => 'Название запчастей';

  @override
  String get descriptionOfParts => 'Описание запчастей';

  @override
  String get price => 'Цена';

  @override
  String get priceDescription => 'Описание цены';

  @override
  String get priceDescriptionPlaceholder => 'Введите описание цены здесь...';

  @override
  String get maxFiveImages => 'Максимум 5 изображений';

  @override
  String get fillAllFields => 'Заполните все поля';

  @override
  String get addProduct => 'Добавить товар';

  @override
  String get requiredField => 'Обязательное поле';

  @override
  String get enterDescription => 'Введите описание здесь...';

  @override
  String get quantity => 'Количество';

  @override
  String get discount => 'Скидка';

  @override
  String get chooseCategory => 'Выберите категорию';

  @override
  String get required => 'Обязательно';

  @override
  String get exampleTittleParts => 'Пример: Поршень';

  @override
  String get category => 'Категория';

  @override
  String get chooseLocation => 'Выберите местоположение';

  @override
  String get regionAndijan => 'Андижан';

  @override
  String get regionBukhara => 'Бухара';

  @override
  String get regionJizzakh => 'Жиззах';

  @override
  String get regionKashkadarya => 'Кашкадарья';

  @override
  String get regionNavoi => 'Навои';

  @override
  String get regionNamangan => 'Наманган';

  @override
  String get regionSamarkand => 'Самарканд';

  @override
  String get regionSurkhandarya => 'Сурхандарья';

  @override
  String get regionSyrdarya => 'Сырдарья';

  @override
  String get regionTashkentRegion => 'Ташкентская область';

  @override
  String get regionFergana => 'Фергана';

  @override
  String get regionKhorezm => 'Хорезм';

  @override
  String get regionKarakalpakstan => 'Республика Каракалпакстан';

  @override
  String get regionTashkentCity => 'Город Ташкент';

  @override
  String get location => 'Местоположение';

  @override
  String get partCreated => 'Запчасть успешно создана';

  @override
  String get forbiddenResource => 'Доступ запрещен';

  @override
  String get description => 'Описание';

  @override
  String get images => 'Изображения';

  @override
  String get user => 'Пользователь';

  @override
  String get relatedProducts => 'Похожие товары';

  @override
  String get noImages => 'Нет изображений';

  @override
  String sellerSince(Object date) {
    return 'Продавец на Garage с $date';
  }

  @override
  String get sellerSinceDescription =>
      'Показывает месяц и год регистрации продавца';

  @override
  String get allSellerProducts => 'Все товары продавца >';

  @override
  String get otherListingsBySeller => 'Другие объявления этого продавца';

  @override
  String get noProducts => 'Нет товаров';

  @override
  String get delete => 'Удалить';

  @override
  String get areYouSureToDelete => 'Вы уверены, что хотите удалить?';

  @override
  String get edit => 'Редактировать';

  @override
  String get productDeleted => 'Товар успешно удален';

  @override
  String get productUpdated => 'Товар обновлен';

  @override
  String get save => 'Сохранить';

  @override
  String get more => 'Еще';

  @override
  String availableUntil(Object date) {
    return 'Доступен до $date';
  }

  @override
  String get views => 'Просмотры';

  @override
  String get viewsOfPhone => 'Просмотры телефона';

  @override
  String get active => 'Активен';

  @override
  String get inactive => 'Неактивен';

  @override
  String get depleted => 'Распродано';

  @override
  String get confirmReturnToSale =>
      'Вы уверены, что хотите снова сделать этот товар доступным для продажи?';

  @override
  String get relist => 'Вернуть в продажу';

  @override
  String get relistTitle => 'Возврат в продажу';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get deleteProductTitle => 'Удаление товара';

  @override
  String get areYouSureToDeleteProduct =>
      'Вы уверены, что хотите удалить этот товар?';

  @override
  String postedOn(Object date) {
    return 'Опубликовано $date';
  }

  @override
  String get address => 'Адрес';

  @override
  String get addService => 'Добавить услугу';

  @override
  String get chooseLocationOnMap => 'Выберите местоположение на карте';

  @override
  String get workingTime => 'Время работы';

  @override
  String get timeExample => 'Пример: 9:00 - 18:00';

  @override
  String get titleOfServices => 'Название услуги';

  @override
  String get editService => 'Редактировать услугу';

  @override
  String get upload => 'Загрузить';

  @override
  String get allProducts => 'Все товары';

  @override
  String get noWorkshopsFound => 'Мастерские не найдены';

  @override
  String get openFrom => 'Открыто с';

  @override
  String get deleteWorkshopTitle => 'Удаление мастерской';

  @override
  String get areYouSureToDeleteWorkshop =>
      'Вы уверены, что хотите удалить эту мастерскую?';

  @override
  String get workshopDeleted => 'Мастерская успешно удалена';

  @override
  String get noServices => 'Пока нет услуг';

  @override
  String get noWorkshops => 'Пока нет мастерских';

  @override
  String get noDiscount => 'Без скидки';

  @override
  String get withDiscount => 'Со скидкой';

  @override
  String get condition => 'Состояние';

  @override
  String get newPart => 'Новый';

  @override
  String get used => 'Б/у';

  @override
  String get delivery => 'Доставка';

  @override
  String get available => 'С доставкой';

  @override
  String get noAvailable => 'Без доставки';

  @override
  String get modelOfCar => 'Модель автомобиля';

  @override
  String get negotiable => 'Договорная';

  @override
  String get byAgreement => 'По договоренности';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get details => 'Детали';

  @override
  String get photos => 'Фотографии';

  @override
  String get enterPrice => 'Введите цену';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get continueWithoutPhotos => 'Продолжить без фото';

  @override
  String get youCanUploadUpTo5Photos => 'Вы можете загрузить до 5 фото';

  @override
  String get publishProduct => 'Опубликовать товар';

  @override
  String get publish => 'Опубликовать';

  @override
  String get productSuccessfullyPublished => 'Товар успешно опубликован';

  @override
  String get productDetails => 'Детали товара';

  @override
  String get enterTitleOfPart => 'Enter part name';

  @override
  String get chooseCondition => 'Please select the condition';

  @override
  String get chooseDeliveryMethod => 'Please select the delivery method';

  @override
  String get enterDescriptionPart => 'Enter a detailed description of the part';

  @override
  String get darkTheme => 'Тёмная тема';

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
  String get sellerProfile => 'Профиль продавца';

  @override
  String get didntFindWhatYouNeed => 'Не нашли что искали?';

  @override
  String get createRequestSubtitle =>
      'Опубликуйте заявку — продавцы свяжутся с вами.';

  @override
  String get createRequest => 'Создать заявку';

  @override
  String get createOrder => 'Создать заявку';

  @override
  String get myRequests => 'Мои заявки';

  @override
  String get title => 'Заголовок';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get brand => 'Марка';

  @override
  String get carModel => 'Модель';

  @override
  String get partCategory => 'Категория запчасти';

  @override
  String get selectBrand => 'Выберите марку';

  @override
  String get selectModel => 'Выберите модель';

  @override
  String get selectPartCategory => 'Выберите категорию';

  @override
  String get budgetOptional => 'Бюджет (необязательно)';

  @override
  String get orderUrgencyTitle => 'Насколько срочно?';

  @override
  String get orderUrgencyHint => 'Продавцы увидят это на карточке заявки.';

  @override
  String get orderUrgencyLow => 'Не срочно';

  @override
  String get orderUrgencyNormal => 'Обычно';

  @override
  String get orderUrgencyUrgent => 'Срочно нужно';

  @override
  String get submit => 'Отправить';

  @override
  String get orderCreated => 'Заявка успешно создана';

  @override
  String get callAuthor => 'Позвонить';

  @override
  String get noOrders => 'Заявок пока нет';

  @override
  String get noOrdersHint => 'Здесь будут появляться заявки покупателей.';

  @override
  String get closeOrder => 'Закрыть заявку';

  @override
  String get closeOrderConfirm => 'Отметить заявку как закрытую?';

  @override
  String get reopenOrder => 'Открыть снова';

  @override
  String get reopenOrderConfirm => 'Снова показать заявку продавцам?';

  @override
  String get orderStatusActive => 'Активна';

  @override
  String get orderStatusClosed => 'Закрыта';

  @override
  String get orderDetailLookingFor => 'Нужна запчасть';

  @override
  String get orderDetailOffersTitle => 'Предложения продавцов';

  @override
  String orderDetailOffersCount(int count) {
    return '$count предложений';
  }

  @override
  String get orderDetailNoOffers =>
      'Пока нет предложений. Продавцы укажут запчасть и цену по вашей заявке.';

  @override
  String get orderDetailSendOffer => 'Отправить предложение';

  @override
  String get orderDetailMessageBuyer => 'Написать покупателю';

  @override
  String get orderDetailYourOffer => 'Ваше предложение';

  @override
  String get orderDetailOfferMessageHint =>
      'Опишите, какую запчасть можете поставить по этой заявке…';

  @override
  String get orderDetailOfferPriceHint => 'Ваша цена (необязательно)';

  @override
  String get orderDetailSubmitOffer => 'Отправить';

  @override
  String get orderDetailChatSeller => 'Чат';

  @override
  String get orderDetailSellerListing => 'Объявление продавца';

  @override
  String get orderDetailAlternativeListing =>
      'Другая запчасть (объявление продавца)';

  @override
  String orderDetailDeliveryDays(int days) {
    return 'Доставка ~$days дн.';
  }

  @override
  String get orderDetailBudgetNegotiable => 'Бюджет договорной';

  @override
  String get orderDetailPosted => 'Опубликовано';

  @override
  String get orderDetailAcceptedOffer => 'Принято';

  @override
  String get orderDetailViewListing => 'Открыть объявление';

  @override
  String orderDetailOfferPrice(String amount) {
    return 'Цена: $amount';
  }

  @override
  String get writeReview => 'Оставить отзыв';

  @override
  String get reviewCommentHint => 'Расскажите о вашем опыте (необязательно)';

  @override
  String get submitReview => 'Отправить отзыв';

  @override
  String get reviewsTitle => 'Отзывы';

  @override
  String get noReviewsYet => 'Пока нет отзывов';

  @override
  String get reviewSubmitted => 'Спасибо за отзыв';

  @override
  String get editReview => 'Изменить отзыв';

  @override
  String get reviewUpdated => 'Отзыв обновлён';

  @override
  String get deleteReview => 'Удалить отзыв';

  @override
  String get deleteReviewConfirm => 'Удалить ваш отзыв безвозвратно?';

  @override
  String get loadMoreReviews => 'Показать ещё';

  @override
  String get reviewDeleted => 'Отзыв удалён';

  @override
  String get promotedTop => 'В топе';

  @override
  String get promoteToTop => 'Продвинуть / в топ';

  @override
  String get promotedBadge => 'ТОП';

  @override
  String get featured => 'Рекомендуем';

  @override
  String get featuredSubtitle => 'Продвигаемые объявления';

  @override
  String get filters => 'Фильтры';

  @override
  String get applyFilters => 'Применить';

  @override
  String get resetFilters => 'Сбросить';

  @override
  String get priceFrom => 'Цена от';

  @override
  String get priceTo => 'Цена до';

  @override
  String get currency => 'Валюта';

  @override
  String get region => 'Регион';

  @override
  String get anyRegion => 'Любой регион';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortRecommended => 'Рекомендуем';

  @override
  String get recommendedForYou => 'Рекомендуем вам';

  @override
  String get recommendedForYouSubtitle => 'На основе вашей активности';

  @override
  String get trendingNow => 'В тренде';

  @override
  String get trendingNowSubtitle => 'Популярное на этой неделе';

  @override
  String get nearYou => 'Рядом с вами';

  @override
  String get nearYouSubtitle => 'Объявления в вашем регионе';

  @override
  String get recentlyViewed => 'Недавно просмотренные';

  @override
  String get recentlyViewedSubtitle => 'Продолжите с того места';

  @override
  String get newArrivals => 'Новинки';

  @override
  String get newArrivalsSubtitle => 'Свежие объявления';

  @override
  String get similarProducts => 'Похожие товары';

  @override
  String get peopleAlsoViewed => 'Смотрели также';

  @override
  String get sortNewest => 'Сначала новые';

  @override
  String get sortPriceAsc => 'Сначала дешёвые';

  @override
  String get sortPriceDesc => 'Сначала дорогие';

  @override
  String get tryAnotherSearch => 'Попробуйте другой поиск или создайте заявку';

  @override
  String get createProductUnfinishedTitle => 'Вы не закончили объявление';

  @override
  String get createProductUnfinishedHint =>
      'Хотите продолжить или создать новое?';

  @override
  String get createProductContinueDraft => 'Продолжить';

  @override
  String get createProductStartNew => 'Новое объявление';

  @override
  String get createProductUntitled => 'Без названия';

  @override
  String get createProductExitTitle => 'Выйти без публикации?';

  @override
  String get createProductExitHint =>
      'Черновик можно сохранить и продолжить позже.';

  @override
  String get createProductKeepEditing => 'Продолжить редактирование';

  @override
  String get createProductSaveAndExit => 'Сохранить и выйти';

  @override
  String get createProductDiscardDraft => 'Удалить черновик';

  @override
  String get createProductStepPhotos => 'Фото';

  @override
  String get createProductStepVehicle => 'Авто';

  @override
  String get createProductStepInfo => 'Описание';

  @override
  String get createProductStepPrice => 'Цена';

  @override
  String get createProductStepLocation => 'Место';

  @override
  String get createProductStepPreview => 'Просмотр';

  @override
  String get createProductPreviewTitle => 'Предпросмотр';

  @override
  String get createProductPreviewSubtitle =>
      'Так покупатели увидят ваше объявление.';

  @override
  String get createProductLocationTitle => 'Где находится запчасть?';

  @override
  String get createProductLocationHint =>
      'Укажите точку на карте — объявление увидят покупатели рядом.';

  @override
  String get createProductUseMyLocation => 'Моё местоположение';

  @override
  String get createProductConditionNewHint => 'Новая, не использовалась';

  @override
  String get createProductConditionUsedHint => 'Б/у, в рабочем состоянии';

  @override
  String get createProductContinue => 'Далее';

  @override
  String get createProductPublishNow => 'Опубликовать';

  @override
  String get createProductUpdateListing => 'Обновить объявление';

  @override
  String createProductStepProgress(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get createProductDraftSaved => 'Черновик сохранён';

  @override
  String get createProductPhotosTitle => 'Фото продают запчасть';

  @override
  String get createProductPhotosHint =>
      'Первое фото — обложка. До 8 изображений.';

  @override
  String get createProductTapAddPhotos => 'Нажмите, чтобы добавить фото';

  @override
  String get createProductGallery => 'Галерея';

  @override
  String get createProductCamera => 'Камера';

  @override
  String get createProductAddMorePhotos => 'Добавить ещё фото';

  @override
  String get createProductCover => 'Обложка';

  @override
  String get createProductDragReorder => 'Перетащите для сортировки';

  @override
  String get createProductTrustTitle => 'Продавайте быстрее с хорошими фото';

  @override
  String get createProductTrustBody =>
      '3+ фото, понятный заголовок и честная цена — покупатели доверяют полным объявлениям.';

  @override
  String get createProductInfoTitle => 'Опишите запчасть';

  @override
  String get createProductTitleHint =>
      'напр. Тормозные колодки Toyota Camry — новые';

  @override
  String get createProductVehicleTitle => 'Для какого авто?';

  @override
  String get createProductVehicleHint =>
      'Покупатели быстрее найдут вашу запчасть.';

  @override
  String get createProductRecentlyUsed => 'Недавние';

  @override
  String get createProductBrand => 'Марка';

  @override
  String get createProductPartCategory => 'Категория запчасти';

  @override
  String get createProductYearOptional => 'Год (необязательно)';

  @override
  String get createProductSelect => 'Выбрать';

  @override
  String get createProductNoModels =>
      'Нет моделей для этой марки. Выберите другую марку.';

  @override
  String get createProductPriceTitle => 'Укажите цену';

  @override
  String createProductPriceSuggested(int price, String currency) {
    return 'Ориентир: около $price $currency';
  }

  @override
  String get createProductNegotiableTitle => 'Договорная цена';

  @override
  String get createProductNegotiableSubtitle =>
      'Покупатель может предложить свою цену';

  @override
  String createProductPublishing(int percent) {
    return 'Публикация… $percent%';
  }

  @override
  String get createProductPublishedSuccess => 'Объявление опубликовано';

  @override
  String get createProductOfflineBanner =>
      'Нет интернета — можно заполнить форму и опубликовать позже.';

  @override
  String get createProductWarnNoPhotos => 'Добавьте хотя бы одно фото';

  @override
  String get createProductWarnTitleShort => 'Слишком короткий заголовок';

  @override
  String get createProductWarnNoCategory => 'Выберите авто или категорию';

  @override
  String get createProductWarnNoPrice => 'Укажите цену';

  @override
  String get createProductWarnNoCurrency => 'Выберите валюту';

  @override
  String get createProductDuplicateTitle =>
      'Недавно вы уже публиковали объявление с таким заголовком';

  @override
  String get createProductQuickErrorPhoto => 'Добавьте фото';

  @override
  String get createProductQuickErrorTitle => 'Заголовок (от 3 символов)';

  @override
  String get createProductQuickErrorPrice => 'Укажите цену';

  @override
  String get createProductOfflinePublish =>
      'Нет интернета. Черновик сохранён — попробуйте позже.';

  @override
  String get createProductErrorSignIn =>
      'Войдите, чтобы публиковать объявления.';

  @override
  String get createProductErrorServer =>
      'Не удаётся связаться с сервером. Проверьте интернет и backend.';

  @override
  String get createProductErrorCategory => 'Выберите категорию (шаг «Авто»).';

  @override
  String get createProductRetry => 'Повторить';

  @override
  String get createProductOk => 'ОК';

  @override
  String get chatConversationTitle => 'Чат';

  @override
  String get chatHeaderTyping => 'Печатает…';

  @override
  String get chatPeerRecentlyActive => 'Недавно был в этом чате';

  @override
  String chatPeerLastSeenInChat(Object time) {
    return 'Последний ответ · $time';
  }

  @override
  String get chatPeerNoMessagesYet => 'Пока нет сообщений собеседника';

  @override
  String get chatHeaderInChatOnlyHint => '(только активность в этом чате)';

  @override
  String get chatJustNow => 'только что';

  @override
  String chatMinutesAgo(Object n) {
    return '$n мин назад';
  }

  @override
  String chatHoursAgo(Object n) {
    return '$n ч назад';
  }

  @override
  String chatDaysAgo(Object n) {
    return '$n д назад';
  }

  @override
  String get chatReply => 'Ответить';

  @override
  String get chatCopy => 'Копировать';

  @override
  String get chatCopied => 'Скопировано';

  @override
  String get chatOriginalMessageNotLoaded =>
      'Исходное сообщение ещё не загружено. Прокрутите вверх, чтобы загрузить больше.';

  @override
  String get chatSelectConversation => 'Выберите диалог';

  @override
  String get chatSelectConversationHint =>
      'Выберите чат из списка, чтобы начать переписку.';

  @override
  String get chatMessageHintDesktop =>
      'Напишите сообщение… (Enter — отправить, Shift+Enter — новая строка)';

  @override
  String chatReplyingTo(String name) {
    return 'Ответ $name';
  }

  @override
  String get chatMessageHint => 'Сообщение…';

  @override
  String get chatAttach => 'Прикрепить';

  @override
  String get chatAttachPhotos => 'Фото из галереи';

  @override
  String get chatTakePhoto => 'Сделать фото';

  @override
  String get chatLastPhoto => 'Фото';

  @override
  String get chatLastVoice => 'Голосовое сообщение';

  @override
  String get chatMicPermissionRequired =>
      'Требуется доступ к микрофону для записи голосовых сообщений.';

  @override
  String get chatVoiceHoldHint => 'Удерживайте для записи';

  @override
  String get chatVoiceSlideToCancel => '← Свайп для отмены';

  @override
  String get chatVoiceReleaseToCancel => 'Отпустите для отмены';

  @override
  String get searchHubUnifiedTitle => 'Обзор';

  @override
  String get searchHubEverythingHint =>
      'Поиск запчастей, сервисов, заявок и продавцов…';

  @override
  String get searchHubVoiceSoon => 'Голосовой поиск скоро появится';

  @override
  String get searchHubOpenMap => 'Карта';

  @override
  String get searchHubAdvancedProductFilters => 'Фильтры товаров';

  @override
  String get searchHubRecent => 'Недавние запросы';

  @override
  String get searchHubClearRecent => 'Очистить';

  @override
  String get searchHubTrending => 'В тренде';

  @override
  String get searchHubCategoryIdeas => 'Популярные категории';

  @override
  String get searchHubExploreTitle => 'Обзор';

  @override
  String get searchHubBrowseAllCategories => 'Все категории';

  @override
  String get searchHubCarBrands => 'Марки автомобилей';

  @override
  String get searchHubExploreHint => 'Что вы ищете?';

  @override
  String get searchHubQuickParts => 'Каталог запчастей';

  @override
  String get searchHubQuickNearby => 'Рядом на карте';

  @override
  String get searchHubAwaitingTyping =>
      'Продолжайте ввод — мы собираем товары, мастерские, услуги на карте и заявки в одном ответе.';

  @override
  String get searchHubSearching => 'Ищем…';

  @override
  String get searchHubNoGroupedHits => 'Пока ничего не нашли';

  @override
  String get searchHubSectionProducts => 'Товары';

  @override
  String get searchHubSectionWorkshops => 'Авто услуги';

  @override
  String get searchHubSectionServices => 'Услуги';

  @override
  String get searchHubSectionOrders => 'Заявки';

  @override
  String get searchHubSectionSellers => 'Продавцы';

  @override
  String get homeStickyNearYou => 'Рядом с вами';

  @override
  String get homeStickyChooseLocation => 'Локация';

  @override
  String get homeExploreNearbyTitle => 'Карта рядом';

  @override
  String get homeExploreNearbySubtitle =>
      'Сервисы • объявления • заявки на карте';

  @override
  String get homeQuickActionsRow => 'Быстро';

  @override
  String get homeHotOrdersPreview => 'Актуальные заявки';

  @override
  String get homeNearbyWorkshopsPreview => 'Ближайшие мастерские';

  @override
  String get homeTrendingServicesPreview => 'Популярные услуги';

  @override
  String get homeSellerSpotlight => 'Продавцы недели';

  @override
  String get homeChatsPreviewSection => 'Сообщения';

  @override
  String get homeAlertsPreviewSection => 'Уведомления';

  @override
  String get homeOpenMessages => 'Чаты';

  @override
  String get homeOpenNotifications => 'Колокольчик';

  @override
  String homeListingCountHint(Object n) {
    return '$n объявлений';
  }

  @override
  String get notificationsCenterTitle => 'Уведомления';

  @override
  String get notificationsCenterEmptyBody =>
      'Здесь появятся новые подписчики, заказы, ответы сервисов и акции. Переписка — в разделе «Сообщения».';

  @override
  String get notificationsMarkAllRead => 'Отметить все прочитанными';

  @override
  String get notificationsRecent => 'Недавние уведомления';

  @override
  String get notificationsCenterFooterHint =>
      'Вы будете получать уведомления о заказах, сервисах и акциях на этом устройстве.';

  @override
  String get notificationsAlertsOn => 'Уведомления включены';

  @override
  String get notificationsAlertsOff => 'Уведомления выключены';

  @override
  String get notificationsEnableHint =>
      'Включите уведомления, чтобы не пропустить заказы и ответы в чате.';

  @override
  String get notificationsEnableButton => 'Включить уведомления';

  @override
  String get notificationsWhatYouGet => 'Что вы будете получать';

  @override
  String get notificationsTopicMessages => 'Новые сообщения и ответы в чате';

  @override
  String get notificationsTopicOrders =>
      'Статус заказов и обновления для покупателя/продавца';

  @override
  String get notificationsTopicWorkshops =>
      'Запись в сервис и ответы мастерских';

  @override
  String get notificationsTopicPromos => 'Акции и выделенные объявления';

  @override
  String get notificationsTopicFollowers => 'Новые подписчики магазина';

  @override
  String get notificationsIosSettingsHint =>
      'Также можно включить в Настройки → Уведомления → Garage.';

  @override
  String get homeNoChatsYet => 'Чатов пока нет';

  @override
  String get homeSeeCategoryServices => 'К услугам';

  @override
  String get homeQuickSellProduct => 'Продать';

  @override
  String get homeQuickCreateOrder => 'Заявка';

  @override
  String get homeQuickAddWorkshop => 'Сервис';

  @override
  String get notificationsPermissionHintShort => 'Включите уведомления';

  @override
  String get searchHubScopeCars => 'Авто';

  @override
  String get searchHubScopeParts => 'Запчасти';

  @override
  String get searchHubScopeServices => 'Услуги';

  @override
  String get searchHubScopeWorkshops => 'Авто услуги';

  @override
  String get searchHubScopeOrders => 'Заявки';

  @override
  String get searchHubScopeNearby => 'Рядом';

  @override
  String get searchHubScopeCarsSeed => 'автомобиль';

  @override
  String get searchHubScopePartsSeed => 'запчасти';

  @override
  String get searchHubScopeWorkshopsSeed => 'авто услуги';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorAuthUnauthorized => 'Войдите в аккаунт, чтобы продолжить.';

  @override
  String get errorAuthForbidden => 'У вас нет прав для этого действия.';

  @override
  String get errorAuthUserExists => 'Этот номер уже зарегистрирован.';

  @override
  String get errorAuthUserNotFound => 'Аккаунт не найден.';

  @override
  String get errorAuthInvalidCredentials => 'Неверный телефон или пароль.';

  @override
  String get errorAuthInvalidOtp => 'Неверный код подтверждения.';

  @override
  String get errorAuthOtpExpired => 'Код истёк. Запросите новый.';

  @override
  String get errorAuthConfirmationTokenMissing =>
      'Сессия регистрации истекла. Зарегистрируйтесь снова.';

  @override
  String get errorAuthConfirmationTokenInvalid =>
      'Недействительная сессия регистрации.';

  @override
  String get errorAuthConfirmationTokenExpired =>
      'Срок подтверждения истёк. Запросите новый код.';

  @override
  String get errorAuthSubscriptionRequired =>
      'Для обновлений в реальном времени нужна защищённая сессия.';

  @override
  String get errorValidationFailed => 'Проверьте данные и попробуйте снова.';

  @override
  String get errorValidationFileTooLarge => 'Файл слишком большой.';

  @override
  String get errorValidationFileTypeInvalid =>
      'Этот тип файла не поддерживается.';

  @override
  String get errorValidationRequestTooLarge => 'Запрос слишком большой.';

  @override
  String get errorValidationRequestTooComplex =>
      'Запрос слишком сложный. Упростите и повторите.';

  @override
  String get errorResourceNotFound => 'Объект не найден.';

  @override
  String get errorOrderNotFound => 'Заявка не найдена.';

  @override
  String get errorOrderNotClosed => 'Заявка не закрыта.';

  @override
  String get errorPartNotFound => 'Объявление не найдено.';

  @override
  String get errorWorkshopNotFound => 'Авто услуга не найдена.';

  @override
  String get errorServiceNotFound => 'Услуга не найдена.';

  @override
  String get errorConversationNotFound => 'Чат не найден.';

  @override
  String get errorMessageNotFound => 'Сообщение не найдено.';

  @override
  String get errorBusinessNotParticipant => 'Вы не участник этого чата.';

  @override
  String get errorBusinessNotAllowed => 'Действие недоступно.';

  @override
  String get errorBusinessCannotReviewOwn =>
      'Нельзя оставить отзыв на свой объект.';

  @override
  String get errorBusinessAlreadyReviewed => 'Вы уже оставили отзыв.';

  @override
  String get errorBusinessCannotBookOwn => 'Нельзя записаться к себе.';

  @override
  String get errorBusinessCannotRespondOwnOrder =>
      'Нельзя откликнуться на свою заявку.';

  @override
  String get errorBusinessOrderWatchDenied => 'Нет доступа к этой заявке.';

  @override
  String get errorBusinessMessageTooLong => 'Сообщение слишком длинное.';

  @override
  String get errorBusinessRateLimit =>
      'Слишком много запросов. Подождите и повторите.';

  @override
  String get errorWsUnauthenticated => 'Соединение не авторизовано.';

  @override
  String get errorWsTooManyConnections => 'Слишком много активных соединений.';

  @override
  String get errorWsHandshakeRateLimited =>
      'Слишком много попыток подключения.';

  @override
  String get errorWsOriginNotAllowed =>
      'Подключение заблокировано по соображениям безопасности.';

  @override
  String get errorDeviceOffline =>
      'Устройство офлайн. Откройте приложение для обновлений.';

  @override
  String get errorCannotMessageSelf => 'Нельзя написать самому себе';

  @override
  String get errorSellerUnavailable => 'Продавец недоступен';

  @override
  String get errorAuthorUnavailable => 'Автор недоступен';

  @override
  String get errorNoListings => 'Нет объявлений';

  @override
  String get workshopVerified => 'Проверен';

  @override
  String get workshopOpenNow => 'Открыто';

  @override
  String get workshopFastResponse => 'Быстрый ответ';

  @override
  String get workshopAbout => 'Об автосервисе';

  @override
  String get workshopServiceTypes => 'Виды услуг';

  @override
  String get similarWorkshops => 'Похожие автосервисы';

  @override
  String get similarOrders => 'Похожие заявки';

  @override
  String viewsCountLabel(int count) {
    return '$count';
  }

  @override
  String get workshopOnRequest => 'По запросу';

  @override
  String workshopPriceFrom(String amount, String currency) {
    return 'от $amount $currency';
  }

  @override
  String workshopOwnerReply(String text) {
    return 'Владелец: $text';
  }

  @override
  String get bookNow => 'Записаться';

  @override
  String get bookServiceTitle => 'Запись на услугу';

  @override
  String get bookWorkshopRequestSent => 'Заявка на запись отправлена';

  @override
  String get bookWorkshopCouldNotBook =>
      'Не удалось записаться. Попробуйте снова.';

  @override
  String get bookDate => 'Дата';

  @override
  String get bookTime => 'Время';

  @override
  String get bookDateTime => 'Дата и время';

  @override
  String get bookNotesOptional => 'Комментарий для сервиса (необязательно)';

  @override
  String get bookConfirmBooking => 'Подтвердить запись';

  @override
  String get bookRequestBooking => 'Отправить заявку';

  @override
  String get bookServiceOptional => 'Услуга (необязательно)';

  @override
  String get bookServiceHint => 'Замена масла, диагностика…';

  @override
  String get bookNotes => 'Комментарий';

  @override
  String get chatNoConversationsYet => 'Пока нет переписок';

  @override
  String get chatSayHello => 'Напишите первым';

  @override
  String get chatReconnecting => 'Переподключение…';

  @override
  String get mapLayerWorkshops => 'Мастерские';

  @override
  String get mapLayerRequests => 'Заявки';

  @override
  String get mapFiltersTitle => 'Фильтры и карта';

  @override
  String get mapHeatmapTitle => 'Тепловая карта';

  @override
  String get mapHeatmapSubtitle => 'Показать зоны с большим числом объявлений';

  @override
  String get mapShownOnMap => 'На карте';

  @override
  String get mapQuickFilters => 'Быстрые фильтры';

  @override
  String get mapAllWorkshops => 'Все мастерские';

  @override
  String get mapSearchRadius => 'Радиус поиска';

  @override
  String get mapOpenPin => 'Открыть';

  @override
  String get mapRouteTooltip => 'Маршрут';

  @override
  String get mapShareTooltip => 'Поделиться';

  @override
  String get mapLocationDefaultArea =>
      'Показана область по умолчанию — включите геолокацию';

  @override
  String get mapLocationGpsDisabled => 'Включите GPS в настройках устройства';

  @override
  String get mapLocationPermissionRequired => 'Нужен доступ к геолокации';

  @override
  String get mapLocationPermissionForever =>
      'Разрешите геолокацию в настройках приложения';

  @override
  String get mapLocationFailed => 'Не удалось определить местоположение';

  @override
  String get mapFilterOpenNow => 'Открыто сейчас';

  @override
  String get mapFilterNearby => 'Рядом';

  @override
  String get mapFilterVerified => 'Проверенные';

  @override
  String get mapFilterTopRated => 'Лучшие';

  @override
  String get mapFilterPremium => 'Премиум';

  @override
  String get workshopScreenTitle => 'Мастерские';

  @override
  String get workshopScreenSubtitle => 'Проверенные автосервисы рядом с вами';

  @override
  String get servicesHubSubtitle =>
      'Найдите проверенные сервисы и запишитесь онлайн';

  @override
  String get servicesHubEmptyNearby =>
      'Пока нет сервисов с геолокацией рядом. Откройте карту или добавьте свой бизнес.';

  @override
  String get servicesHubEmptyTopRated => 'Пока нет лучших сервисов.';

  @override
  String get servicesHubOpenMapSubtitle =>
      'Смотрите мастерские и услуги на карте';

  @override
  String get workshopPopular => 'Популярные';

  @override
  String get workshopNearbyTitle => 'Мастерские рядом';

  @override
  String get workshopSearchResults => 'Результаты поиска';

  @override
  String get workshopsLiveMap => 'Карта';

  @override
  String get trendingTires => 'Шины';

  @override
  String get trendingDiagnostics => 'Диагностика';

  @override
  String get trendingEngineOil => 'Масло двигателя';

  @override
  String get trendingTowTruck => 'Эвакуатор';

  @override
  String get trendingDetailing => 'Детейлинг';

  @override
  String get trendingAkp => 'АКПП';

  @override
  String get trendingBattery => 'Аккумулятор';

  @override
  String get trendingBrakes => 'Тормоза';

  @override
  String get orderPartEngine => 'Двигатель';

  @override
  String get orderPartBumper => 'Бампер';

  @override
  String get orderPartHeadlights => 'Фары';

  @override
  String get orderPartBrakes => 'Тормоза';

  @override
  String get orderPartSuspension => 'Подвеска';

  @override
  String orderDetailNeedsPart(String part) {
    return 'Нужна: $part';
  }

  @override
  String get serviceFeatures => 'Особенности';

  @override
  String get signInToBookService => 'Войдите, чтобы записаться';

  @override
  String get signInToMessageBuyer => 'Войдите, чтобы написать покупателю';

  @override
  String get badgeVerified => 'ПРОВЕРЕН';

  @override
  String get badgePremium => 'ПРЕМИУМ';

  @override
  String get badgeFast => 'БЫСТРО';

  @override
  String get badgeTopRated => 'ТОП';

  @override
  String get createWorkshopServicesTitle => 'Выберите услуги';

  @override
  String get createWorkshopPopular => 'Популярные';

  @override
  String get createWorkshopAllServices => 'Все услуги';

  @override
  String createWorkshopServicesHint(int count) {
    return 'Типы услуг ($count). Выберите всё, что подходит вашему сервису.';
  }

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get follow => 'Подписаться';

  @override
  String get following => 'Подписка оформлена';

  @override
  String get shareProfile => 'Поделиться профилем';

  @override
  String sellerFollowersProducts(
      String followers, String products, String date) {
    return '$followers подписчиков • $products товаров • С $date';
  }

  @override
  String get sellerStatProducts => 'Товары';

  @override
  String get sellerStatCategories => 'Категории';

  @override
  String get sellerStatFollowers => 'Подписчики';

  @override
  String get noFollowersYet => 'Пока нет подписчиков';

  @override
  String followedOn(String date) {
    return 'Подписался $date';
  }

  @override
  String get sellerStatProfileViews => 'Просмотры профиля';

  @override
  String get sellerStatActiveProducts => 'Активные';

  @override
  String get sellerCategories => 'Категории продавца';

  @override
  String get sellerBioSection => 'О продавце';

  @override
  String get sellerDescriptionSection => 'Описание';

  @override
  String get sellerSocialLinks => 'Соцсети';

  @override
  String get sellerInformation => 'Информация о продавце';

  @override
  String get latestProducts => 'Новинки';

  @override
  String get popularProducts => 'Популярные';

  @override
  String get searchSellerProducts => 'Поиск в магазине';

  @override
  String get sortPriceLowHigh => 'Цена: по возрастанию';

  @override
  String get sortPriceHighLow => 'Цена: по убыванию';

  @override
  String get viewProfile => 'Профиль';

  @override
  String get moreFromSeller => 'Ещё от этого продавца';

  @override
  String get sellerStoreEmpty => 'У продавца пока нет товаров';

  @override
  String get sellerStoreEmptyHint => 'Пока нет объявлений.';

  @override
  String get username => 'Имя пользователя';

  @override
  String get bio => 'Кратко о себе';

  @override
  String get emailAddress => 'Электронная почта';

  @override
  String get country => 'Страна';

  @override
  String get city => 'Город';

  @override
  String get showLocationPublicly => 'Показывать местоположение';

  @override
  String get privacySettings => 'Настройки приватности';

  @override
  String get showPhoneNumber => 'Показывать телефон';

  @override
  String get showEmail => 'Показывать email';

  @override
  String get showFollowersCount => 'Показывать подписчиков';

  @override
  String get allowMessages => 'Разрешить сообщения';

  @override
  String get sellerDashboardPreview => 'Превью магазина';

  @override
  String get aboutSection => 'О себе';

  @override
  String get publicVisibility => 'Публично';

  @override
  String get privateVisibility => 'Скрыто';

  @override
  String get gridView => 'Сетка';

  @override
  String get listView => 'Список';

  @override
  String sellerAtUsername(String username) {
    return '@$username';
  }

  @override
  String get editStore => 'Редактировать магазин';

  @override
  String get manageProducts => 'Управление товарами';

  @override
  String get storeAnalytics => 'Аналитика магазина';

  @override
  String get unableToLoadStore => 'Не удалось загрузить магазин';

  @override
  String get retry => 'Повторить';

  @override
  String get storeProfileCompletion => 'Заполненность профиля';

  @override
  String get missingFields => 'Не хватает:';

  @override
  String get completeProfile => 'Заполнить профиль';

  @override
  String get missingAvatar => 'Фото профиля';

  @override
  String get missingStoreBanner => 'Баннер магазина';

  @override
  String get missingBio => 'Краткое описание';

  @override
  String get missingDescription => 'Описание';

  @override
  String get missingSocialLinks => 'Соцсети';

  @override
  String get missingLocation => 'Местоположение';

  @override
  String get missingUsername => 'Имя пользователя';

  @override
  String get changeBanner => 'Сменить баннер';

  @override
  String get quickSellerDashboard => 'Быстрая сводка';

  @override
  String get dashboardToday => 'Обзор';

  @override
  String get dashboardProductViews => 'Просмотры товаров';

  @override
  String get dashboardMessages => 'Сообщения';

  @override
  String get dashboardNewFollowers => 'Подписчики';

  @override
  String get dashboardProductsSold => 'Продано';

  @override
  String get openAnalytics => 'Открыть аналитику';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get productManagement => 'Управление товарами';

  @override
  String get draftProducts => 'Черновики';

  @override
  String get archivedProducts => 'Архив';

  @override
  String get pendingModeration => 'На модерации';

  @override
  String get storeCreated => 'Магазин создан';

  @override
  String get verificationStatus => 'Верификация';

  @override
  String get notVerified => 'Не проверен';

  @override
  String get verifiedAccountTitle => 'Проверенный аккаунт';

  @override
  String get verifiedAccountVisitorInfo =>
      'Команда AutoRin проверила этого продавца и его магазин. Значок означает, что это реальный и надёжный продавец — можно покупать спокойнее.';

  @override
  String get verifiedAccountOwnerInfo =>
      'Ваш магазин проверен командой AutoRin. Покупатели видят значок «Проверен» рядом с вашим именем и больше доверяют объявлениям.';

  @override
  String get verifiedAccountPointIdentity => 'Личность продавца подтверждена';

  @override
  String get verifiedAccountPointTrusted => 'Надёжный магазин на AutoRin';

  @override
  String get verificationWhatIsIt =>
      'Верификация подтверждает, что ваш магазин настоящий. Проверенные продавцы получают значок и больше доверия от покупателей.';

  @override
  String get contactPreferences => 'Контакты';

  @override
  String get messagesDisabled => 'Сообщения отключены';

  @override
  String get ownerStoreEmpty => 'У вас пока нет товаров';

  @override
  String get addFirstProduct => 'Добавить первый товар';

  @override
  String get unfollow => 'Отписаться';

  @override
  String get unfollowConfirm => 'Отписаться от продавца?';

  @override
  String get range7Days => '7 дней';

  @override
  String get range30Days => '30 дней';

  @override
  String get range90Days => '90 дней';

  @override
  String get dashboardLeads => 'Заявки';

  @override
  String get productClicks => 'Клики по товарам';

  @override
  String get topProducts => 'Топ товары';

  @override
  String get topCategories => 'Топ категории';

  @override
  String get chats => 'Сообщения';

  @override
  String get myStore => 'Мой магазин';

  @override
  String get ownerMyListings => 'Мои объявления';

  @override
  String get myListingsTotalLabel => 'Всего объявлений';

  @override
  String myListingsBreakdown(String activeLabel, int activeCount,
      String inactiveLabel, int inactiveCount) {
    return '$activeLabel · $activeCount · $inactiveLabel · $inactiveCount';
  }

  @override
  String get workshopUntitled => 'Мастерская без названия';

  @override
  String get workshopStatusOpen => 'Открыто';

  @override
  String get workshopStatusClosed => 'Закрыто';

  @override
  String get promoteListingTitle => 'Продвижение объявления';

  @override
  String get promoteProductTitle => 'Продвижение товара';

  @override
  String get promoteWorkshopTitle => 'Продвижение мастерской';

  @override
  String get promoteServiceTitle => 'Продвижение услуги';

  @override
  String get promotePlanBasic => 'Базовый';

  @override
  String get promotePlanStandard => 'Стандарт';

  @override
  String get promotePlanPremium => 'Премиум';

  @override
  String get promotePlanVip => 'VIP';

  @override
  String promotePlanDuration(int days, int priority) {
    return '$days дн. · приоритет $priority';
  }

  @override
  String get activatePromotion => 'Активировать продвижение';

  @override
  String get promotionActivatedSuccess => 'Продвижение успешно активировано';

  @override
  String get notificationAccountVerifiedTitle => 'Вы прошли проверку';

  @override
  String get notificationAccountVerifiedBody =>
      'Ваш аккаунт подтверждён командой AutoRin.';

  @override
  String get notificationNewFollowerTitle => 'Новый подписчик';

  @override
  String get notificationNewFollowerBody => 'Кто-то подписался на ваш магазин.';

  @override
  String get notificationOrderReplyTitle => 'Обновление заказа';

  @override
  String get notificationPromotedExpiredTitle => 'Продвижение завершено';

  @override
  String get notificationPromotedExpiredBody =>
      'Объявление больше не продвигается. Продлите, чтобы оставаться в топе.';

  @override
  String get notificationFavoriteMatchedTitle => 'Совпадение по избранному';

  @override
  String get notificationFavoriteMatchedBody =>
      'Появилось объявление, похожее на сохранённое.';

  @override
  String get notificationSellerResponseTitle => 'Ответ продавца';

  @override
  String get notificationNewMessageTitle => 'Новое сообщение';

  @override
  String get notificationNewMessageBody => 'Нажмите, чтобы открыть чат.';

  @override
  String get notificationOrderReplyBody => 'Есть обновление по вашему заказу.';

  @override
  String get notificationWorkshopBookingTitle => 'Запись в сервис';

  @override
  String get notificationWorkshopBookingBody =>
      'Новая заявка или ответ от мастерской.';

  @override
  String get notificationGenericAlertTitle => 'Garage';

  @override
  String get notificationGenericAlertBody => 'У вас новое уведомление.';

  @override
  String get pushChannelName => 'Уведомления Garage';

  @override
  String get pushChannelDescription => 'Сообщения, заказы, сервисы и акции.';

  @override
  String get notificationOpenAction => 'Открыть';
}
