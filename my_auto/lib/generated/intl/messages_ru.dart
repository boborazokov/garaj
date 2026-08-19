// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(date) => "Доступен до ${date}";

  static String m1(n) => "${n} д назад";

  static String m2(n) => "${n} ч назад";

  static String m3(n) => "${n} мин назад";

  static String m4(time) => "Последний ответ · ${time}";

  static String m5(name) => "Ответ ${name}";

  static String m6(price, currency) => "Ориентир: около ${price} ${currency}";

  static String m7(percent) => "Публикация… ${percent}%";

  static String m8(current, total) => "Шаг ${current} из ${total}";

  static String m9(count) =>
      "Типы услуг (${count}). Выберите всё, что подходит вашему сервису.";

  static String m10(date) => "Подписался ${date}";

  static String m11(name) => "Привет, ${name}";

  static String m12(n) => "${n} объявлений";

  static String m13(activeLabel, activeCount, inactiveLabel, inactiveCount) =>
      "${activeLabel} · ${activeCount} · ${inactiveLabel} · ${inactiveCount}";

  static String m14(days) => "Доставка ~${days} дн.";

  static String m15(part) => "Нужна: ${part}";

  static String m16(amount) => "Цена: ${amount}";

  static String m17(count) => "${count} предложений";

  static String m18(date) => "Опубликовано ${date}";

  static String m19(days, priority) => "${days} дн. · приоритет ${priority}";

  static String m20(username) => "@${username}";

  static String m21(followers, products, date) =>
      "${followers} подписчиков • ${products} товаров • С ${date}";

  static String m22(date) => "Продавец на Garage с ${date}";

  static String m23(text) => "Владелец: ${text}";

  static String m24(amount, currency) => "от ${amount} ${currency}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutSection": MessageLookupByLibrary.simpleMessage("О себе"),
    "accountDetails": MessageLookupByLibrary.simpleMessage("Данные аккаунта"),
    "activatePromotion": MessageLookupByLibrary.simpleMessage(
      "Активировать продвижение",
    ),
    "active": MessageLookupByLibrary.simpleMessage("Активен"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addFirstProduct": MessageLookupByLibrary.simpleMessage(
      "Добавить первый товар",
    ),
    "addPhoto": MessageLookupByLibrary.simpleMessage("Добавить фото"),
    "addProduct": MessageLookupByLibrary.simpleMessage("Добавить товар"),
    "addService": MessageLookupByLibrary.simpleMessage("Добавить услугу"),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "afternoon": MessageLookupByLibrary.simpleMessage("Добрый день"),
    "allProducts": MessageLookupByLibrary.simpleMessage("Все товары"),
    "allSellerProducts": MessageLookupByLibrary.simpleMessage(
      "Все товары продавца >",
    ),
    "allowMessages": MessageLookupByLibrary.simpleMessage(
      "Разрешить сообщения",
    ),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Уже есть аккаунт?",
    ),
    "announcements": MessageLookupByLibrary.simpleMessage("Объявления"),
    "anyRegion": MessageLookupByLibrary.simpleMessage("Любой регион"),
    "appMarketplaceTagline": MessageLookupByLibrary.simpleMessage(
      "Маркетплейс Garage",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("Garage"),
    "applyFilters": MessageLookupByLibrary.simpleMessage("Применить"),
    "archivedProducts": MessageLookupByLibrary.simpleMessage("Архив"),
    "areYouSureToDelete": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить?",
    ),
    "areYouSureToDeleteProduct": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить этот товар?",
    ),
    "areYouSureToDeleteWorkshop": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить эту мастерскую?",
    ),
    "available": MessageLookupByLibrary.simpleMessage("С доставкой"),
    "availableUntil": m0,
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "badgeFast": MessageLookupByLibrary.simpleMessage("БЫСТРО"),
    "badgePremium": MessageLookupByLibrary.simpleMessage("ПРЕМИУМ"),
    "badgeTopRated": MessageLookupByLibrary.simpleMessage("ТОП"),
    "badgeVerified": MessageLookupByLibrary.simpleMessage("ПРОВЕРЕН"),
    "bio": MessageLookupByLibrary.simpleMessage("Кратко о себе"),
    "bookConfirmBooking": MessageLookupByLibrary.simpleMessage(
      "Подтвердить запись",
    ),
    "bookDate": MessageLookupByLibrary.simpleMessage("Дата"),
    "bookDateTime": MessageLookupByLibrary.simpleMessage("Дата и время"),
    "bookNotes": MessageLookupByLibrary.simpleMessage("Комментарий"),
    "bookNotesOptional": MessageLookupByLibrary.simpleMessage(
      "Комментарий для сервиса (необязательно)",
    ),
    "bookNow": MessageLookupByLibrary.simpleMessage("Записаться"),
    "bookRequestBooking": MessageLookupByLibrary.simpleMessage(
      "Отправить заявку",
    ),
    "bookServiceHint": MessageLookupByLibrary.simpleMessage(
      "Замена масла, диагностика…",
    ),
    "bookServiceOptional": MessageLookupByLibrary.simpleMessage(
      "Услуга (необязательно)",
    ),
    "bookServiceTitle": MessageLookupByLibrary.simpleMessage(
      "Запись на услугу",
    ),
    "bookTime": MessageLookupByLibrary.simpleMessage("Время"),
    "bookWorkshopCouldNotBook": MessageLookupByLibrary.simpleMessage(
      "Не удалось записаться. Попробуйте снова.",
    ),
    "bookWorkshopRequestSent": MessageLookupByLibrary.simpleMessage(
      "Заявка на запись отправлена",
    ),
    "brand": MessageLookupByLibrary.simpleMessage("Марка"),
    "browseAsGuest": MessageLookupByLibrary.simpleMessage("Смотреть без входа"),
    "budgetOptional": MessageLookupByLibrary.simpleMessage(
      "Бюджет (необязательно)",
    ),
    "byAgreement": MessageLookupByLibrary.simpleMessage("По договоренности"),
    "callAuthor": MessageLookupByLibrary.simpleMessage("Позвонить"),
    "callSeller": MessageLookupByLibrary.simpleMessage("Позвонить продавцу"),
    "camera": MessageLookupByLibrary.simpleMessage("Камера"),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "carModel": MessageLookupByLibrary.simpleMessage("Модель"),
    "category": MessageLookupByLibrary.simpleMessage("Категория"),
    "changeBanner": MessageLookupByLibrary.simpleMessage("Сменить баннер"),
    "chatAttach": MessageLookupByLibrary.simpleMessage("Прикрепить"),
    "chatAttachPhotos": MessageLookupByLibrary.simpleMessage("Фото из галереи"),
    "chatConversationTitle": MessageLookupByLibrary.simpleMessage("Чат"),
    "chatCopied": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "chatCopy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "chatDaysAgo": m1,
    "chatHeaderInChatOnlyHint": MessageLookupByLibrary.simpleMessage(
      "(только активность в этом чате)",
    ),
    "chatHeaderTyping": MessageLookupByLibrary.simpleMessage("Печатает…"),
    "chatHoursAgo": m2,
    "chatJustNow": MessageLookupByLibrary.simpleMessage("только что"),
    "chatLastPhoto": MessageLookupByLibrary.simpleMessage("Фото"),
    "chatLastVoice": MessageLookupByLibrary.simpleMessage(
      "Голосовое сообщение",
    ),
    "chatMessageHint": MessageLookupByLibrary.simpleMessage("Сообщение…"),
    "chatMessageHintDesktop": MessageLookupByLibrary.simpleMessage(
      "Напишите сообщение… (Enter — отправить, Shift+Enter — новая строка)",
    ),
    "chatMicPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется доступ к микрофону для записи голосовых сообщений.",
    ),
    "chatMinutesAgo": m3,
    "chatNoConversationsYet": MessageLookupByLibrary.simpleMessage(
      "Пока нет переписок",
    ),
    "chatOriginalMessageNotLoaded": MessageLookupByLibrary.simpleMessage(
      "Исходное сообщение ещё не загружено. Прокрутите вверх, чтобы загрузить больше.",
    ),
    "chatPeerLastSeenInChat": m4,
    "chatPeerNoMessagesYet": MessageLookupByLibrary.simpleMessage(
      "Пока нет сообщений собеседника",
    ),
    "chatPeerRecentlyActive": MessageLookupByLibrary.simpleMessage(
      "Недавно был в этом чате",
    ),
    "chatReconnecting": MessageLookupByLibrary.simpleMessage(
      "Переподключение…",
    ),
    "chatReply": MessageLookupByLibrary.simpleMessage("Ответить"),
    "chatReplyingTo": m5,
    "chatSayHello": MessageLookupByLibrary.simpleMessage("Напишите первым"),
    "chatSelectConversation": MessageLookupByLibrary.simpleMessage(
      "Выберите диалог",
    ),
    "chatSelectConversationHint": MessageLookupByLibrary.simpleMessage(
      "Выберите чат из списка, чтобы начать переписку.",
    ),
    "chatTakePhoto": MessageLookupByLibrary.simpleMessage("Сделать фото"),
    "chatVoiceHoldHint": MessageLookupByLibrary.simpleMessage(
      "Удерживайте для записи",
    ),
    "chatVoiceReleaseToCancel": MessageLookupByLibrary.simpleMessage(
      "Отпустите для отмены",
    ),
    "chatVoiceSlideToCancel": MessageLookupByLibrary.simpleMessage(
      "← Свайп для отмены",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Сообщения"),
    "chooseCategory": MessageLookupByLibrary.simpleMessage(
      "Выберите категорию",
    ),
    "chooseLocation": MessageLookupByLibrary.simpleMessage(
      "Выберите местоположение",
    ),
    "chooseLocationOnMap": MessageLookupByLibrary.simpleMessage(
      "Выберите местоположение на карте",
    ),
    "city": MessageLookupByLibrary.simpleMessage("Город"),
    "closeOrder": MessageLookupByLibrary.simpleMessage("Закрыть заявку"),
    "closeOrderConfirm": MessageLookupByLibrary.simpleMessage(
      "Отметить заявку как закрытую?",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро"),
    "completeProfile": MessageLookupByLibrary.simpleMessage(
      "Заполнить профиль",
    ),
    "condition": MessageLookupByLibrary.simpleMessage("Состояние"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmReturnToSale": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите снова сделать этот товар доступным для продажи?",
    ),
    "confirmationCodeNeedsToBe5Symbols": MessageLookupByLibrary.simpleMessage(
      "Код подтверждения должен содержать 5 символов",
    ),
    "contactInformation": MessageLookupByLibrary.simpleMessage("Контакты"),
    "contactInformationText": MessageLookupByLibrary.simpleMessage(
      "Вопросы о конфиденциальности и данных: support@myauto.uz или +998 95 384 10 00.",
    ),
    "contactPreferences": MessageLookupByLibrary.simpleMessage("Контакты"),
    "contactUs": MessageLookupByLibrary.simpleMessage("Свяжитесь с нами"),
    "contactUsEmailSubtitle": MessageLookupByLibrary.simpleMessage(
      "Обычно отвечаем в течение 1 рабочего дня",
    ),
    "contactUsIntro": MessageLookupByLibrary.simpleMessage(
      "Мы поможем с объявлениями, заказами и аккаунтом.",
    ),
    "contactUsPhoneSubtitle": MessageLookupByLibrary.simpleMessage(
      "Пн–Сб, 9:00–18:00 (время Ташкента)",
    ),
    "continueBrowsing": MessageLookupByLibrary.simpleMessage(
      "Продолжить просмотр",
    ),
    "continueWithoutPhotos": MessageLookupByLibrary.simpleMessage(
      "Продолжить без фото",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Страна"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Создать аккаунт"),
    "createOrder": MessageLookupByLibrary.simpleMessage("Создать заявку"),
    "createProductAddMorePhotos": MessageLookupByLibrary.simpleMessage(
      "Добавить ещё фото",
    ),
    "createProductBrand": MessageLookupByLibrary.simpleMessage("Марка"),
    "createProductCamera": MessageLookupByLibrary.simpleMessage("Камера"),
    "createProductConditionNewHint": MessageLookupByLibrary.simpleMessage(
      "Новая, не использовалась",
    ),
    "createProductConditionUsedHint": MessageLookupByLibrary.simpleMessage(
      "Б/у, в рабочем состоянии",
    ),
    "createProductContinue": MessageLookupByLibrary.simpleMessage("Далее"),
    "createProductContinueDraft": MessageLookupByLibrary.simpleMessage(
      "Продолжить",
    ),
    "createProductCover": MessageLookupByLibrary.simpleMessage("Обложка"),
    "createProductDiscardDraft": MessageLookupByLibrary.simpleMessage(
      "Удалить черновик",
    ),
    "createProductDraftSaved": MessageLookupByLibrary.simpleMessage(
      "Черновик сохранён",
    ),
    "createProductDragReorder": MessageLookupByLibrary.simpleMessage(
      "Перетащите для сортировки",
    ),
    "createProductDuplicateTitle": MessageLookupByLibrary.simpleMessage(
      "Недавно вы уже публиковали объявление с таким заголовком",
    ),
    "createProductErrorCategory": MessageLookupByLibrary.simpleMessage(
      "Выберите категорию (шаг «Авто»).",
    ),
    "createProductErrorServer": MessageLookupByLibrary.simpleMessage(
      "Не удаётся связаться с сервером. Проверьте интернет и backend.",
    ),
    "createProductErrorSignIn": MessageLookupByLibrary.simpleMessage(
      "Войдите, чтобы публиковать объявления.",
    ),
    "createProductExitHint": MessageLookupByLibrary.simpleMessage(
      "Черновик можно сохранить и продолжить позже.",
    ),
    "createProductExitTitle": MessageLookupByLibrary.simpleMessage(
      "Выйти без публикации?",
    ),
    "createProductGallery": MessageLookupByLibrary.simpleMessage("Галерея"),
    "createProductInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Опишите запчасть",
    ),
    "createProductKeepEditing": MessageLookupByLibrary.simpleMessage(
      "Продолжить редактирование",
    ),
    "createProductLocationHint": MessageLookupByLibrary.simpleMessage(
      "Укажите точку на карте — объявление увидят покупатели рядом.",
    ),
    "createProductLocationTitle": MessageLookupByLibrary.simpleMessage(
      "Где находится запчасть?",
    ),
    "createProductNegotiableSubtitle": MessageLookupByLibrary.simpleMessage(
      "Покупатель может предложить свою цену",
    ),
    "createProductNegotiableTitle": MessageLookupByLibrary.simpleMessage(
      "Договорная цена",
    ),
    "createProductNoModels": MessageLookupByLibrary.simpleMessage(
      "Нет моделей для этой марки. Выберите другую марку.",
    ),
    "createProductOfflineBanner": MessageLookupByLibrary.simpleMessage(
      "Нет интернета — можно заполнить форму и опубликовать позже.",
    ),
    "createProductOfflinePublish": MessageLookupByLibrary.simpleMessage(
      "Нет интернета. Черновик сохранён — попробуйте позже.",
    ),
    "createProductOk": MessageLookupByLibrary.simpleMessage("ОК"),
    "createProductPartCategory": MessageLookupByLibrary.simpleMessage(
      "Категория запчасти",
    ),
    "createProductPhotosHint": MessageLookupByLibrary.simpleMessage(
      "Первое фото — обложка. До 8 изображений.",
    ),
    "createProductPhotosTitle": MessageLookupByLibrary.simpleMessage(
      "Фото продают запчасть",
    ),
    "createProductPreviewSubtitle": MessageLookupByLibrary.simpleMessage(
      "Так покупатели увидят ваше объявление.",
    ),
    "createProductPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр",
    ),
    "createProductPriceSuggested": m6,
    "createProductPriceTitle": MessageLookupByLibrary.simpleMessage(
      "Укажите цену",
    ),
    "createProductPublishNow": MessageLookupByLibrary.simpleMessage(
      "Опубликовать",
    ),
    "createProductPublishedSuccess": MessageLookupByLibrary.simpleMessage(
      "Объявление опубликовано",
    ),
    "createProductPublishing": m7,
    "createProductQuickErrorPhoto": MessageLookupByLibrary.simpleMessage(
      "Добавьте фото",
    ),
    "createProductQuickErrorPrice": MessageLookupByLibrary.simpleMessage(
      "Укажите цену",
    ),
    "createProductQuickErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Заголовок (от 3 символов)",
    ),
    "createProductRecentlyUsed": MessageLookupByLibrary.simpleMessage(
      "Недавние",
    ),
    "createProductRetry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "createProductSaveAndExit": MessageLookupByLibrary.simpleMessage(
      "Сохранить и выйти",
    ),
    "createProductSelect": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "createProductStartNew": MessageLookupByLibrary.simpleMessage(
      "Новое объявление",
    ),
    "createProductStepInfo": MessageLookupByLibrary.simpleMessage("Описание"),
    "createProductStepLocation": MessageLookupByLibrary.simpleMessage("Место"),
    "createProductStepPhotos": MessageLookupByLibrary.simpleMessage("Фото"),
    "createProductStepPreview": MessageLookupByLibrary.simpleMessage(
      "Просмотр",
    ),
    "createProductStepPrice": MessageLookupByLibrary.simpleMessage("Цена"),
    "createProductStepProgress": m8,
    "createProductStepVehicle": MessageLookupByLibrary.simpleMessage("Авто"),
    "createProductTapAddPhotos": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы добавить фото",
    ),
    "createProductTitleHint": MessageLookupByLibrary.simpleMessage(
      "напр. Тормозные колодки Toyota Camry — новые",
    ),
    "createProductTrustBody": MessageLookupByLibrary.simpleMessage(
      "3+ фото, понятный заголовок и честная цена — покупатели доверяют полным объявлениям.",
    ),
    "createProductTrustTitle": MessageLookupByLibrary.simpleMessage(
      "Продавайте быстрее с хорошими фото",
    ),
    "createProductUnfinishedHint": MessageLookupByLibrary.simpleMessage(
      "Хотите продолжить или создать новое?",
    ),
    "createProductUnfinishedTitle": MessageLookupByLibrary.simpleMessage(
      "Вы не закончили объявление",
    ),
    "createProductUntitled": MessageLookupByLibrary.simpleMessage(
      "Без названия",
    ),
    "createProductUpdateListing": MessageLookupByLibrary.simpleMessage(
      "Обновить объявление",
    ),
    "createProductUseMyLocation": MessageLookupByLibrary.simpleMessage(
      "Моё местоположение",
    ),
    "createProductVehicleHint": MessageLookupByLibrary.simpleMessage(
      "Покупатели быстрее найдут вашу запчасть.",
    ),
    "createProductVehicleTitle": MessageLookupByLibrary.simpleMessage(
      "Для какого авто?",
    ),
    "createProductWarnNoCategory": MessageLookupByLibrary.simpleMessage(
      "Выберите авто или категорию",
    ),
    "createProductWarnNoCurrency": MessageLookupByLibrary.simpleMessage(
      "Выберите валюту",
    ),
    "createProductWarnNoPhotos": MessageLookupByLibrary.simpleMessage(
      "Добавьте хотя бы одно фото",
    ),
    "createProductWarnNoPrice": MessageLookupByLibrary.simpleMessage(
      "Укажите цену",
    ),
    "createProductWarnTitleShort": MessageLookupByLibrary.simpleMessage(
      "Слишком короткий заголовок",
    ),
    "createProductYearOptional": MessageLookupByLibrary.simpleMessage(
      "Год (необязательно)",
    ),
    "createRequest": MessageLookupByLibrary.simpleMessage("Создать заявку"),
    "createRequestSubtitle": MessageLookupByLibrary.simpleMessage(
      "Опубликуйте заявку — продавцы свяжутся с вами.",
    ),
    "createWorkshopAllServices": MessageLookupByLibrary.simpleMessage(
      "Все услуги",
    ),
    "createWorkshopPopular": MessageLookupByLibrary.simpleMessage("Популярные"),
    "createWorkshopServicesHint": m9,
    "createWorkshopServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Выберите услуги",
    ),
    "currency": MessageLookupByLibrary.simpleMessage("Валюта"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Тёмная тема"),
    "dashboardLeads": MessageLookupByLibrary.simpleMessage("Заявки"),
    "dashboardMessages": MessageLookupByLibrary.simpleMessage("Сообщения"),
    "dashboardNewFollowers": MessageLookupByLibrary.simpleMessage("Подписчики"),
    "dashboardProductViews": MessageLookupByLibrary.simpleMessage(
      "Просмотры товаров",
    ),
    "dashboardProductsSold": MessageLookupByLibrary.simpleMessage("Продано"),
    "dashboardToday": MessageLookupByLibrary.simpleMessage("Обзор"),
    "dataCollection": MessageLookupByLibrary.simpleMessage("1. Сбор данных"),
    "dataCollectionText": MessageLookupByLibrary.simpleMessage(
      "Мы собираем личную информацию, такую как имя, адрес электронной почты и номер телефона, когда вы создаете аккаунт или пользуетесь нашими услугами.",
    ),
    "dataUsage": MessageLookupByLibrary.simpleMessage(
      "2. Использование данных",
    ),
    "dataUsageText": MessageLookupByLibrary.simpleMessage(
      "Ваши данные используются для предоставления и улучшения наших услуг, персонализации опыта и связи с вами.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Удалить аккаунт"),
    "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
      "Удалить навсегда",
    ),
    "deleteAccountDescription": MessageLookupByLibrary.simpleMessage(
      "Удалить аккаунт навсегда?",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось удалить аккаунт. Попробуйте снова или напишите в поддержку.",
    ),
    "deleteAccountSubtitle": MessageLookupByLibrary.simpleMessage(
      "Профиль и личные данные будут удалены. Объявления архивируются. Отменить нельзя.",
    ),
    "deleteAccountSuccess": MessageLookupByLibrary.simpleMessage(
      "Ваш аккаунт удалён",
    ),
    "deleteProductTitle": MessageLookupByLibrary.simpleMessage(
      "Удаление товара",
    ),
    "deleteReview": MessageLookupByLibrary.simpleMessage("Удалить отзыв"),
    "deleteReviewConfirm": MessageLookupByLibrary.simpleMessage(
      "Удалить ваш отзыв безвозвратно?",
    ),
    "deleteWorkshopTitle": MessageLookupByLibrary.simpleMessage(
      "Удаление мастерской",
    ),
    "delivery": MessageLookupByLibrary.simpleMessage("Доставка"),
    "depleted": MessageLookupByLibrary.simpleMessage("Распродано"),
    "description": MessageLookupByLibrary.simpleMessage("Описание"),
    "descriptionOfParts": MessageLookupByLibrary.simpleMessage(
      "Описание запчастей",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Детали"),
    "didntFindWhatYouNeed": MessageLookupByLibrary.simpleMessage(
      "Не нашли что искали?",
    ),
    "discount": MessageLookupByLibrary.simpleMessage("Скидка"),
    "done": MessageLookupByLibrary.simpleMessage("Готово"),
    "draftProducts": MessageLookupByLibrary.simpleMessage("Черновики"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editProfile": MessageLookupByLibrary.simpleMessage(
      "Редактировать профиль",
    ),
    "editReview": MessageLookupByLibrary.simpleMessage("Изменить отзыв"),
    "editService": MessageLookupByLibrary.simpleMessage("Редактировать услугу"),
    "editStore": MessageLookupByLibrary.simpleMessage("Редактировать магазин"),
    "email": MessageLookupByLibrary.simpleMessage("Эл. почта"),
    "emailAddress": MessageLookupByLibrary.simpleMessage("Электронная почта"),
    "enterCodeMessage": MessageLookupByLibrary.simpleMessage(
      "Мы отправили вам 5-значный код — введите его здесь, чтобы продолжить",
    ),
    "enterDescription": MessageLookupByLibrary.simpleMessage(
      "Введите описание здесь...",
    ),
    "enterPrice": MessageLookupByLibrary.simpleMessage("Введите цену"),
    "error": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "errorAuthConfirmationTokenExpired": MessageLookupByLibrary.simpleMessage(
      "Срок подтверждения истёк. Запросите новый код.",
    ),
    "errorAuthConfirmationTokenInvalid": MessageLookupByLibrary.simpleMessage(
      "Недействительная сессия регистрации.",
    ),
    "errorAuthConfirmationTokenMissing": MessageLookupByLibrary.simpleMessage(
      "Сессия регистрации истекла. Зарегистрируйтесь снова.",
    ),
    "errorAuthForbidden": MessageLookupByLibrary.simpleMessage(
      "У вас нет прав для этого действия.",
    ),
    "errorAuthInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "Неверный телефон или пароль.",
    ),
    "errorAuthInvalidOtp": MessageLookupByLibrary.simpleMessage(
      "Неверный код подтверждения.",
    ),
    "errorAuthOtpExpired": MessageLookupByLibrary.simpleMessage(
      "Код истёк. Запросите новый.",
    ),
    "errorAuthSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Для обновлений в реальном времени нужна защищённая сессия.",
    ),
    "errorAuthUnauthorized": MessageLookupByLibrary.simpleMessage(
      "Войдите в аккаунт, чтобы продолжить.",
    ),
    "errorAuthUserExists": MessageLookupByLibrary.simpleMessage(
      "Этот номер уже зарегистрирован.",
    ),
    "errorAuthUserNotFound": MessageLookupByLibrary.simpleMessage(
      "Аккаунт не найден.",
    ),
    "errorAuthorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Автор недоступен",
    ),
    "errorBusinessAlreadyReviewed": MessageLookupByLibrary.simpleMessage(
      "Вы уже оставили отзыв.",
    ),
    "errorBusinessCannotBookOwn": MessageLookupByLibrary.simpleMessage(
      "Нельзя записаться к себе.",
    ),
    "errorBusinessCannotRespondOwnOrder": MessageLookupByLibrary.simpleMessage(
      "Нельзя откликнуться на свою заявку.",
    ),
    "errorBusinessCannotReviewOwn": MessageLookupByLibrary.simpleMessage(
      "Нельзя оставить отзыв на свой объект.",
    ),
    "errorBusinessMessageTooLong": MessageLookupByLibrary.simpleMessage(
      "Сообщение слишком длинное.",
    ),
    "errorBusinessNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Действие недоступно.",
    ),
    "errorBusinessNotParticipant": MessageLookupByLibrary.simpleMessage(
      "Вы не участник этого чата.",
    ),
    "errorBusinessOrderWatchDenied": MessageLookupByLibrary.simpleMessage(
      "Нет доступа к этой заявке.",
    ),
    "errorBusinessRateLimit": MessageLookupByLibrary.simpleMessage(
      "Слишком много запросов. Подождите и повторите.",
    ),
    "errorCannotMessageSelf": MessageLookupByLibrary.simpleMessage(
      "Нельзя написать самому себе",
    ),
    "errorConversationNotFound": MessageLookupByLibrary.simpleMessage(
      "Чат не найден.",
    ),
    "errorDeviceOffline": MessageLookupByLibrary.simpleMessage(
      "Устройство офлайн. Откройте приложение для обновлений.",
    ),
    "errorGeneric": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так. Попробуйте ещё раз.",
    ),
    "errorMessageNotFound": MessageLookupByLibrary.simpleMessage(
      "Сообщение не найдено.",
    ),
    "errorNoListings": MessageLookupByLibrary.simpleMessage("Нет объявлений"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка. Пожалуйста, попробуйте позже.",
    ),
    "errorOrderNotClosed": MessageLookupByLibrary.simpleMessage(
      "Заявка не закрыта.",
    ),
    "errorOrderNotFound": MessageLookupByLibrary.simpleMessage(
      "Заявка не найдена.",
    ),
    "errorPartNotFound": MessageLookupByLibrary.simpleMessage(
      "Объявление не найдено.",
    ),
    "errorResourceNotFound": MessageLookupByLibrary.simpleMessage(
      "Объект не найден.",
    ),
    "errorSellerUnavailable": MessageLookupByLibrary.simpleMessage(
      "Продавец недоступен",
    ),
    "errorServiceNotFound": MessageLookupByLibrary.simpleMessage(
      "Услуга не найдена.",
    ),
    "errorValidationFailed": MessageLookupByLibrary.simpleMessage(
      "Проверьте данные и попробуйте снова.",
    ),
    "errorValidationFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "Файл слишком большой.",
    ),
    "errorValidationFileTypeInvalid": MessageLookupByLibrary.simpleMessage(
      "Этот тип файла не поддерживается.",
    ),
    "errorValidationRequestTooComplex": MessageLookupByLibrary.simpleMessage(
      "Запрос слишком сложный. Упростите и повторите.",
    ),
    "errorValidationRequestTooLarge": MessageLookupByLibrary.simpleMessage(
      "Запрос слишком большой.",
    ),
    "errorWorkshopNotFound": MessageLookupByLibrary.simpleMessage(
      "Авто услуга не найдена.",
    ),
    "errorWsHandshakeRateLimited": MessageLookupByLibrary.simpleMessage(
      "Слишком много попыток подключения.",
    ),
    "errorWsOriginNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Подключение заблокировано по соображениям безопасности.",
    ),
    "errorWsTooManyConnections": MessageLookupByLibrary.simpleMessage(
      "Слишком много активных соединений.",
    ),
    "errorWsUnauthenticated": MessageLookupByLibrary.simpleMessage(
      "Соединение не авторизовано.",
    ),
    "exampleTittleParts": MessageLookupByLibrary.simpleMessage(
      "Пример: Поршень",
    ),
    "favorites": MessageLookupByLibrary.simpleMessage("Избранное"),
    "favoritesEmpty": MessageLookupByLibrary.simpleMessage(
      "Пока нет сохранённых объявлений",
    ),
    "featured": MessageLookupByLibrary.simpleMessage("Рекомендуем"),
    "featuredSubtitle": MessageLookupByLibrary.simpleMessage(
      "Продвигаемые объявления",
    ),
    "fieldRequired": MessageLookupByLibrary.simpleMessage("Поле обязательно"),
    "fillAllFields": MessageLookupByLibrary.simpleMessage("Заполните все поля"),
    "filters": MessageLookupByLibrary.simpleMessage("Фильтры"),
    "follow": MessageLookupByLibrary.simpleMessage("Подписаться"),
    "followedOn": m10,
    "following": MessageLookupByLibrary.simpleMessage("Подписка оформлена"),
    "forbiddenResource": MessageLookupByLibrary.simpleMessage(
      "Доступ запрещен",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Галерея"),
    "gridView": MessageLookupByLibrary.simpleMessage("Сетка"),
    "guest": MessageLookupByLibrary.simpleMessage("Гость"),
    "helpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Помощь и поддержка",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "homeAlertsPreviewSection": MessageLookupByLibrary.simpleMessage(
      "Уведомления",
    ),
    "homeChatsPreviewSection": MessageLookupByLibrary.simpleMessage(
      "Сообщения",
    ),
    "homeExploreNearbySubtitle": MessageLookupByLibrary.simpleMessage(
      "Сервисы • объявления • заявки на карте",
    ),
    "homeExploreNearbyTitle": MessageLookupByLibrary.simpleMessage(
      "Карта рядом",
    ),
    "homeGreeting": m11,
    "homeHotOrdersPreview": MessageLookupByLibrary.simpleMessage(
      "Актуальные заявки",
    ),
    "homeListingCountHint": m12,
    "homeNearbyWorkshopsPreview": MessageLookupByLibrary.simpleMessage(
      "Ближайшие мастерские",
    ),
    "homeNoChatsYet": MessageLookupByLibrary.simpleMessage("Чатов пока нет"),
    "homeOpenMessages": MessageLookupByLibrary.simpleMessage("Чаты"),
    "homeOpenNotifications": MessageLookupByLibrary.simpleMessage(
      "Колокольчик",
    ),
    "homeQuickActionsRow": MessageLookupByLibrary.simpleMessage("Быстро"),
    "homeQuickAddWorkshop": MessageLookupByLibrary.simpleMessage("Сервис"),
    "homeQuickCreateOrder": MessageLookupByLibrary.simpleMessage("Заявка"),
    "homeQuickSellProduct": MessageLookupByLibrary.simpleMessage("Продать"),
    "homeSeeCategoryServices": MessageLookupByLibrary.simpleMessage(
      "К услугам",
    ),
    "homeSellerSpotlight": MessageLookupByLibrary.simpleMessage(
      "Продавцы недели",
    ),
    "homeStickyChooseLocation": MessageLookupByLibrary.simpleMessage("Локация"),
    "homeStickyNearYou": MessageLookupByLibrary.simpleMessage("Рядом с вами"),
    "homeTrendingServicesPreview": MessageLookupByLibrary.simpleMessage(
      "Популярные услуги",
    ),
    "images": MessageLookupByLibrary.simpleMessage("Изображения"),
    "inactive": MessageLookupByLibrary.simpleMessage("Неактивен"),
    "info": MessageLookupByLibrary.simpleMessage("Информация"),
    "invalidOtpCode": MessageLookupByLibrary.simpleMessage("Неверный код"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "latestProducts": MessageLookupByLibrary.simpleMessage("Новинки"),
    "listView": MessageLookupByLibrary.simpleMessage("Список"),
    "loadMoreReviews": MessageLookupByLibrary.simpleMessage("Показать ещё"),
    "location": MessageLookupByLibrary.simpleMessage("Местоположение"),
    "logIn": MessageLookupByLibrary.simpleMessage("Войдите в свой аккаунт"),
    "logout": MessageLookupByLibrary.simpleMessage("Выйти"),
    "logoutDescription": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти?",
    ),
    "logoutSubtitle": MessageLookupByLibrary.simpleMessage(
      "Вы будете перенаправлены на экран входа.",
    ),
    "manageProducts": MessageLookupByLibrary.simpleMessage(
      "Управление товарами",
    ),
    "mapAllWorkshops": MessageLookupByLibrary.simpleMessage("Все мастерские"),
    "mapFilterNearby": MessageLookupByLibrary.simpleMessage("Рядом"),
    "mapFilterOpenNow": MessageLookupByLibrary.simpleMessage("Открыто сейчас"),
    "mapFilterPremium": MessageLookupByLibrary.simpleMessage("Премиум"),
    "mapFilterTopRated": MessageLookupByLibrary.simpleMessage("Лучшие"),
    "mapFilterVerified": MessageLookupByLibrary.simpleMessage("Проверенные"),
    "mapFiltersTitle": MessageLookupByLibrary.simpleMessage("Фильтры и карта"),
    "mapHeatmapSubtitle": MessageLookupByLibrary.simpleMessage(
      "Показать зоны с большим числом объявлений",
    ),
    "mapHeatmapTitle": MessageLookupByLibrary.simpleMessage("Тепловая карта"),
    "mapLayerRequests": MessageLookupByLibrary.simpleMessage("Заявки"),
    "mapLayerWorkshops": MessageLookupByLibrary.simpleMessage("Мастерские"),
    "mapLocationDefaultArea": MessageLookupByLibrary.simpleMessage(
      "Показана область по умолчанию — включите геолокацию",
    ),
    "mapLocationFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить местоположение",
    ),
    "mapLocationGpsDisabled": MessageLookupByLibrary.simpleMessage(
      "Включите GPS в настройках устройства",
    ),
    "mapLocationPermissionForever": MessageLookupByLibrary.simpleMessage(
      "Разрешите геолокацию в настройках приложения",
    ),
    "mapLocationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Нужен доступ к геолокации",
    ),
    "mapOpenPin": MessageLookupByLibrary.simpleMessage("Открыть"),
    "mapQuickFilters": MessageLookupByLibrary.simpleMessage("Быстрые фильтры"),
    "mapRouteTooltip": MessageLookupByLibrary.simpleMessage("Маршрут"),
    "mapSearchRadius": MessageLookupByLibrary.simpleMessage("Радиус поиска"),
    "mapShareTooltip": MessageLookupByLibrary.simpleMessage("Поделиться"),
    "mapShownOnMap": MessageLookupByLibrary.simpleMessage("На карте"),
    "maxFiveImages": MessageLookupByLibrary.simpleMessage(
      "Максимум 5 изображений",
    ),
    "messages": MessageLookupByLibrary.simpleMessage("Сообщения"),
    "messagesDisabled": MessageLookupByLibrary.simpleMessage(
      "Сообщения отключены",
    ),
    "missingAvatar": MessageLookupByLibrary.simpleMessage("Фото профиля"),
    "missingBio": MessageLookupByLibrary.simpleMessage("Краткое описание"),
    "missingDescription": MessageLookupByLibrary.simpleMessage("Описание"),
    "missingFields": MessageLookupByLibrary.simpleMessage("Не хватает:"),
    "missingLocation": MessageLookupByLibrary.simpleMessage("Местоположение"),
    "missingSocialLinks": MessageLookupByLibrary.simpleMessage("Соцсети"),
    "missingStoreBanner": MessageLookupByLibrary.simpleMessage(
      "Баннер магазина",
    ),
    "missingUsername": MessageLookupByLibrary.simpleMessage("Имя пользователя"),
    "modelOfCar": MessageLookupByLibrary.simpleMessage("Модель автомобиля"),
    "more": MessageLookupByLibrary.simpleMessage("Еще"),
    "moreFromSeller": MessageLookupByLibrary.simpleMessage(
      "Ещё от этого продавца",
    ),
    "morning": MessageLookupByLibrary.simpleMessage("Доброе утро"),
    "myListingsBreakdown": m13,
    "myListingsEmptyActive": MessageLookupByLibrary.simpleMessage(
      "Пока нет активных объявлений",
    ),
    "myListingsEmptyInactive": MessageLookupByLibrary.simpleMessage(
      "Нет архивных объявлений",
    ),
    "myListingsTotalLabel": MessageLookupByLibrary.simpleMessage(
      "Всего объявлений",
    ),
    "myOrders": MessageLookupByLibrary.simpleMessage("Мои заказы"),
    "myProducts": MessageLookupByLibrary.simpleMessage("Мои товары"),
    "myRequests": MessageLookupByLibrary.simpleMessage("Мои заявки"),
    "myServices": MessageLookupByLibrary.simpleMessage("Мои услуги"),
    "myStore": MessageLookupByLibrary.simpleMessage("Мой магазин"),
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nearYou": MessageLookupByLibrary.simpleMessage("Рядом с вами"),
    "nearYouSubtitle": MessageLookupByLibrary.simpleMessage(
      "Объявления в вашем регионе",
    ),
    "negotiable": MessageLookupByLibrary.simpleMessage("Договорная"),
    "newArrivals": MessageLookupByLibrary.simpleMessage("Новинки"),
    "newArrivalsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Свежие объявления",
    ),
    "newPart": MessageLookupByLibrary.simpleMessage("Новый"),
    "next": MessageLookupByLibrary.simpleMessage("Далее"),
    "night": MessageLookupByLibrary.simpleMessage("Доброй ночи"),
    "no": MessageLookupByLibrary.simpleMessage("Нет"),
    "noAccount": MessageLookupByLibrary.simpleMessage("Нет аккаунта?"),
    "noAvailable": MessageLookupByLibrary.simpleMessage("Без доставки"),
    "noDiscount": MessageLookupByLibrary.simpleMessage("Без скидки"),
    "noFollowersYet": MessageLookupByLibrary.simpleMessage(
      "Пока нет подписчиков",
    ),
    "noImages": MessageLookupByLibrary.simpleMessage("Нет изображений"),
    "noInternetConnection": MessageLookupByLibrary.simpleMessage(
      "Нет соединения с интернетом. Проверьте настройки сети.",
    ),
    "noOrders": MessageLookupByLibrary.simpleMessage("Заявок пока нет"),
    "noOrdersHint": MessageLookupByLibrary.simpleMessage(
      "Здесь будут появляться заявки покупателей.",
    ),
    "noProducts": MessageLookupByLibrary.simpleMessage("Нет товаров"),
    "noReviewsYet": MessageLookupByLibrary.simpleMessage("Пока нет отзывов"),
    "noServices": MessageLookupByLibrary.simpleMessage("Пока нет услуг"),
    "noWorkshops": MessageLookupByLibrary.simpleMessage("Пока нет мастерских"),
    "noWorkshopsFound": MessageLookupByLibrary.simpleMessage(
      "Мастерские не найдены",
    ),
    "notVerified": MessageLookupByLibrary.simpleMessage("Не проверен"),
    "notification": MessageLookupByLibrary.simpleMessage("Уведомления"),
    "notificationAccountVerifiedBody": MessageLookupByLibrary.simpleMessage(
      "Ваш аккаунт подтверждён командой AutoRin.",
    ),
    "notificationAccountVerifiedTitle": MessageLookupByLibrary.simpleMessage(
      "Вы прошли проверку",
    ),
    "notificationFavoriteMatchedBody": MessageLookupByLibrary.simpleMessage(
      "Появилось объявление, похожее на сохранённое.",
    ),
    "notificationFavoriteMatchedTitle": MessageLookupByLibrary.simpleMessage(
      "Совпадение по избранному",
    ),
    "notificationGenericAlertBody": MessageLookupByLibrary.simpleMessage(
      "У вас новое уведомление.",
    ),
    "notificationGenericAlertTitle": MessageLookupByLibrary.simpleMessage(
      "Garage",
    ),
    "notificationNewFollowerBody": MessageLookupByLibrary.simpleMessage(
      "Кто-то подписался на ваш магазин.",
    ),
    "notificationNewFollowerTitle": MessageLookupByLibrary.simpleMessage(
      "Новый подписчик",
    ),
    "notificationNewMessageBody": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы открыть чат.",
    ),
    "notificationNewMessageTitle": MessageLookupByLibrary.simpleMessage(
      "Новое сообщение",
    ),
    "notificationOpenAction": MessageLookupByLibrary.simpleMessage("Открыть"),
    "notificationOrderReplyBody": MessageLookupByLibrary.simpleMessage(
      "Есть обновление по вашему заказу.",
    ),
    "notificationOrderReplyTitle": MessageLookupByLibrary.simpleMessage(
      "Обновление заказа",
    ),
    "notificationPromotedExpiredBody": MessageLookupByLibrary.simpleMessage(
      "Объявление больше не продвигается. Продлите, чтобы оставаться в топе.",
    ),
    "notificationPromotedExpiredTitle": MessageLookupByLibrary.simpleMessage(
      "Продвижение завершено",
    ),
    "notificationSellerResponseTitle": MessageLookupByLibrary.simpleMessage(
      "Ответ продавца",
    ),
    "notificationWorkshopBookingBody": MessageLookupByLibrary.simpleMessage(
      "Новая заявка или ответ от мастерской.",
    ),
    "notificationWorkshopBookingTitle": MessageLookupByLibrary.simpleMessage(
      "Запись в сервис",
    ),
    "notificationsAlertsOff": MessageLookupByLibrary.simpleMessage(
      "Уведомления выключены",
    ),
    "notificationsAlertsOn": MessageLookupByLibrary.simpleMessage(
      "Уведомления включены",
    ),
    "notificationsCenterEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Здесь появятся новые подписчики, заказы, ответы сервисов и акции. Переписка — в разделе «Сообщения».",
    ),
    "notificationsCenterFooterHint": MessageLookupByLibrary.simpleMessage(
      "Вы будете получать уведомления о заказах, сервисах и акциях на этом устройстве.",
    ),
    "notificationsCenterTitle": MessageLookupByLibrary.simpleMessage(
      "Уведомления",
    ),
    "notificationsEnableButton": MessageLookupByLibrary.simpleMessage(
      "Включить уведомления",
    ),
    "notificationsEnableHint": MessageLookupByLibrary.simpleMessage(
      "Включите уведомления, чтобы не пропустить заказы и ответы в чате.",
    ),
    "notificationsIosSettingsHint": MessageLookupByLibrary.simpleMessage(
      "Также можно включить в Настройки → Уведомления → Garage.",
    ),
    "notificationsMarkAllRead": MessageLookupByLibrary.simpleMessage(
      "Отметить все прочитанными",
    ),
    "notificationsPermissionHintShort": MessageLookupByLibrary.simpleMessage(
      "Включите уведомления",
    ),
    "notificationsRecent": MessageLookupByLibrary.simpleMessage(
      "Недавние уведомления",
    ),
    "notificationsTopicFollowers": MessageLookupByLibrary.simpleMessage(
      "Новые подписчики магазина",
    ),
    "notificationsTopicMessages": MessageLookupByLibrary.simpleMessage(
      "Новые сообщения и ответы в чате",
    ),
    "notificationsTopicOrders": MessageLookupByLibrary.simpleMessage(
      "Статус заказов и обновления для покупателя/продавца",
    ),
    "notificationsTopicPromos": MessageLookupByLibrary.simpleMessage(
      "Акции и выделенные объявления",
    ),
    "notificationsTopicWorkshops": MessageLookupByLibrary.simpleMessage(
      "Запись в сервис и ответы мастерских",
    ),
    "notificationsWhatYouGet": MessageLookupByLibrary.simpleMessage(
      "Что вы будете получать",
    ),
    "openAnalytics": MessageLookupByLibrary.simpleMessage("Открыть аналитику"),
    "openFrom": MessageLookupByLibrary.simpleMessage("Открыто с"),
    "order": MessageLookupByLibrary.simpleMessage("Заказ"),
    "orderCreated": MessageLookupByLibrary.simpleMessage(
      "Заявка успешно создана",
    ),
    "orderDetailAcceptedOffer": MessageLookupByLibrary.simpleMessage("Принято"),
    "orderDetailAlternativeListing": MessageLookupByLibrary.simpleMessage(
      "Другая запчасть (объявление продавца)",
    ),
    "orderDetailBudgetNegotiable": MessageLookupByLibrary.simpleMessage(
      "Бюджет договорной",
    ),
    "orderDetailChatSeller": MessageLookupByLibrary.simpleMessage("Чат"),
    "orderDetailDeliveryDays": m14,
    "orderDetailLookingFor": MessageLookupByLibrary.simpleMessage(
      "Нужна запчасть",
    ),
    "orderDetailMessageBuyer": MessageLookupByLibrary.simpleMessage(
      "Написать покупателю",
    ),
    "orderDetailNeedsPart": m15,
    "orderDetailNoOffers": MessageLookupByLibrary.simpleMessage(
      "Пока нет предложений. Продавцы укажут запчасть и цену по вашей заявке.",
    ),
    "orderDetailOfferMessageHint": MessageLookupByLibrary.simpleMessage(
      "Опишите, какую запчасть можете поставить по этой заявке…",
    ),
    "orderDetailOfferPrice": m16,
    "orderDetailOfferPriceHint": MessageLookupByLibrary.simpleMessage(
      "Ваша цена (необязательно)",
    ),
    "orderDetailOffersCount": m17,
    "orderDetailOffersTitle": MessageLookupByLibrary.simpleMessage(
      "Предложения продавцов",
    ),
    "orderDetailPosted": MessageLookupByLibrary.simpleMessage("Опубликовано"),
    "orderDetailSellerListing": MessageLookupByLibrary.simpleMessage(
      "Объявление продавца",
    ),
    "orderDetailSendOffer": MessageLookupByLibrary.simpleMessage(
      "Отправить предложение",
    ),
    "orderDetailSubmitOffer": MessageLookupByLibrary.simpleMessage("Отправить"),
    "orderDetailViewListing": MessageLookupByLibrary.simpleMessage(
      "Открыть объявление",
    ),
    "orderDetailYourOffer": MessageLookupByLibrary.simpleMessage(
      "Ваше предложение",
    ),
    "orderPartBrakes": MessageLookupByLibrary.simpleMessage("Тормоза"),
    "orderPartBumper": MessageLookupByLibrary.simpleMessage("Бампер"),
    "orderPartEngine": MessageLookupByLibrary.simpleMessage("Двигатель"),
    "orderPartHeadlights": MessageLookupByLibrary.simpleMessage("Фары"),
    "orderPartSuspension": MessageLookupByLibrary.simpleMessage("Подвеска"),
    "orderStatusActive": MessageLookupByLibrary.simpleMessage("Активна"),
    "orderStatusClosed": MessageLookupByLibrary.simpleMessage("Закрыта"),
    "orderUrgencyHint": MessageLookupByLibrary.simpleMessage(
      "Продавцы увидят это на карточке заявки.",
    ),
    "orderUrgencyLow": MessageLookupByLibrary.simpleMessage("Не срочно"),
    "orderUrgencyNormal": MessageLookupByLibrary.simpleMessage("Обычно"),
    "orderUrgencyTitle": MessageLookupByLibrary.simpleMessage(
      "Насколько срочно?",
    ),
    "orderUrgencyUrgent": MessageLookupByLibrary.simpleMessage("Срочно нужно"),
    "orders": MessageLookupByLibrary.simpleMessage("Заказы"),
    "otherListingsBySeller": MessageLookupByLibrary.simpleMessage(
      "Другие объявления этого продавца",
    ),
    "ownerMyListings": MessageLookupByLibrary.simpleMessage("Мои объявления"),
    "ownerStoreEmpty": MessageLookupByLibrary.simpleMessage(
      "У вас пока нет товаров",
    ),
    "partCategory": MessageLookupByLibrary.simpleMessage("Категория запчасти"),
    "partCreated": MessageLookupByLibrary.simpleMessage(
      "Запчасть успешно создана",
    ),
    "parts": MessageLookupByLibrary.simpleMessage("Запчасти"),
    "passengerCars": MessageLookupByLibrary.simpleMessage(
      "Легковые автомобили",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "passwordLength": MessageLookupByLibrary.simpleMessage(
      "Пароль должен содержать не менее 6 символов",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают",
    ),
    "pendingModeration": MessageLookupByLibrary.simpleMessage("На модерации"),
    "peopleAlsoViewed": MessageLookupByLibrary.simpleMessage("Смотрели также"),
    "phone": MessageLookupByLibrary.simpleMessage("Телефон"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Номер телефона"),
    "photos": MessageLookupByLibrary.simpleMessage("Фотографии"),
    "popularProducts": MessageLookupByLibrary.simpleMessage("Популярные"),
    "postedOn": m18,
    "price": MessageLookupByLibrary.simpleMessage("Цена"),
    "priceDescription": MessageLookupByLibrary.simpleMessage("Описание цены"),
    "priceDescriptionPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Введите описание цены здесь...",
    ),
    "priceFrom": MessageLookupByLibrary.simpleMessage("Цена от"),
    "priceTo": MessageLookupByLibrary.simpleMessage("Цена до"),
    "privacyAccountData": MessageLookupByLibrary.simpleMessage(
      "2. Аккаунт и объявления",
    ),
    "privacyAccountDataText": MessageLookupByLibrary.simpleMessage(
      "Мы храним профиль (имя, телефон, фото), объявления (запчасти, сервисы), сообщения, заказы и токены устройств для push-уведомлений. Геолокация используется только по вашему желанию.",
    ),
    "privacyAccountDeletion": MessageLookupByLibrary.simpleMessage(
      "6. Удаление аккаунта",
    ),
    "privacyAccountDeletionText": MessageLookupByLibrary.simpleMessage(
      "Удалить аккаунт можно в Профиль → Удалить аккаунт. Личные данные будут удалены, объявления архивированы. Отменить действие нельзя.",
    ),
    "privacyChildren": MessageLookupByLibrary.simpleMessage("7. Дети"),
    "privacyChildrenText": MessageLookupByLibrary.simpleMessage(
      "My Auto не предназначен для пользователей младше 16 лет. Мы сознательно не собираем данные детей.",
    ),
    "privacyDataRetention": MessageLookupByLibrary.simpleMessage(
      "5. Хранение данных",
    ),
    "privacyDataRetentionText": MessageLookupByLibrary.simpleMessage(
      "Данные хранятся, пока аккаунт активен. При удалении аккаунта личные данные удаляются, объявления архивируются.",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "privacyPolicyChanges": MessageLookupByLibrary.simpleMessage(
      "9. Изменения политики",
    ),
    "privacyPolicyChangesText": MessageLookupByLibrary.simpleMessage(
      "Мы можем обновлять эту политику. Продолжая пользоваться приложением, вы принимаете обновлённую версию.",
    ),
    "privacyPolicyIntro": MessageLookupByLibrary.simpleMessage(
      "Мы обязуемся защищать вашу конфиденциальность. Эта политика объясняет, как мы собираем, используем и защищаем ваши данные.",
    ),
    "privacyPolicyLastUpdated": MessageLookupByLibrary.simpleMessage(
      "Последнее обновление: июнь 2026",
    ),
    "privacySecurity": MessageLookupByLibrary.simpleMessage("4. Безопасность"),
    "privacySecurityText": MessageLookupByLibrary.simpleMessage(
      "Мы используем шифрование (HTTPS), безопасную авторизацию и контроль доступа. Абсолютной защиты не существует, но мы стараемся обезопасить ваши данные.",
    ),
    "privacySettings": MessageLookupByLibrary.simpleMessage(
      "Настройки приватности",
    ),
    "privateVisibility": MessageLookupByLibrary.simpleMessage("Скрыто"),
    "productClicks": MessageLookupByLibrary.simpleMessage("Клики по товарам"),
    "productDeleted": MessageLookupByLibrary.simpleMessage(
      "Товар успешно удален",
    ),
    "productDetails": MessageLookupByLibrary.simpleMessage("Детали товара"),
    "productManagement": MessageLookupByLibrary.simpleMessage(
      "Управление товарами",
    ),
    "productSuccessfullyPublished": MessageLookupByLibrary.simpleMessage(
      "Товар успешно опубликован",
    ),
    "productUpdated": MessageLookupByLibrary.simpleMessage("Товар обновлен"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileSectionAccount": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "profileSectionMyActivity": MessageLookupByLibrary.simpleMessage(
      "Моя активность",
    ),
    "profileSectionPreferences": MessageLookupByLibrary.simpleMessage(
      "Настройки",
    ),
    "profileSectionSupport": MessageLookupByLibrary.simpleMessage("Поддержка"),
    "profileSubtitleMessages": MessageLookupByLibrary.simpleMessage(
      "Чаты с продавцами",
    ),
    "profileSubtitleMyOrders": MessageLookupByLibrary.simpleMessage(
      "Недавние заказы",
    ),
    "profileSubtitleMyProducts": MessageLookupByLibrary.simpleMessage(
      "Объявления и запчасти",
    ),
    "profileSubtitleMyServices": MessageLookupByLibrary.simpleMessage(
      "Ваши мастерские",
    ),
    "promoteListingTitle": MessageLookupByLibrary.simpleMessage(
      "Продвижение объявления",
    ),
    "promotePlanBasic": MessageLookupByLibrary.simpleMessage("Базовый"),
    "promotePlanDuration": m19,
    "promotePlanPremium": MessageLookupByLibrary.simpleMessage("Премиум"),
    "promotePlanStandard": MessageLookupByLibrary.simpleMessage("Стандарт"),
    "promotePlanVip": MessageLookupByLibrary.simpleMessage("VIP"),
    "promoteProductTitle": MessageLookupByLibrary.simpleMessage(
      "Продвижение товара",
    ),
    "promoteServiceTitle": MessageLookupByLibrary.simpleMessage(
      "Продвижение услуги",
    ),
    "promoteWorkshopTitle": MessageLookupByLibrary.simpleMessage(
      "Продвижение мастерской",
    ),
    "promotedBadge": MessageLookupByLibrary.simpleMessage("ТОП"),
    "promotedTop": MessageLookupByLibrary.simpleMessage("ТОП"),
    "promotionActivatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Продвижение успешно активировано",
    ),
    "publicVisibility": MessageLookupByLibrary.simpleMessage("Публично"),
    "publish": MessageLookupByLibrary.simpleMessage("Опубликовать"),
    "publishProduct": MessageLookupByLibrary.simpleMessage(
      "Опубликовать товар",
    ),
    "pushChannelDescription": MessageLookupByLibrary.simpleMessage(
      "Сообщения, заказы, сервисы и акции.",
    ),
    "pushChannelName": MessageLookupByLibrary.simpleMessage(
      "Уведомления Garage",
    ),
    "quantity": MessageLookupByLibrary.simpleMessage("Количество"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Быстрые действия"),
    "quickSellerDashboard": MessageLookupByLibrary.simpleMessage(
      "Быстрая сводка",
    ),
    "range30Days": MessageLookupByLibrary.simpleMessage("30 дней"),
    "range7Days": MessageLookupByLibrary.simpleMessage("7 дней"),
    "range90Days": MessageLookupByLibrary.simpleMessage("90 дней"),
    "recentlyViewed": MessageLookupByLibrary.simpleMessage(
      "Недавно просмотренные",
    ),
    "recentlyViewedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Продолжите с того места",
    ),
    "recommendedForYou": MessageLookupByLibrary.simpleMessage(
      "Рекомендуем вам",
    ),
    "recommendedForYouSubtitle": MessageLookupByLibrary.simpleMessage(
      "На основе вашей активности",
    ),
    "region": MessageLookupByLibrary.simpleMessage("Регион"),
    "regionAndijan": MessageLookupByLibrary.simpleMessage("Андижан"),
    "regionBukhara": MessageLookupByLibrary.simpleMessage("Бухара"),
    "regionFergana": MessageLookupByLibrary.simpleMessage("Фергана"),
    "regionJizzakh": MessageLookupByLibrary.simpleMessage("Жиззах"),
    "regionKarakalpakstan": MessageLookupByLibrary.simpleMessage(
      "Республика Каракалпакстан",
    ),
    "regionKashkadarya": MessageLookupByLibrary.simpleMessage("Кашкадарья"),
    "regionKhorezm": MessageLookupByLibrary.simpleMessage("Хорезм"),
    "regionNamangan": MessageLookupByLibrary.simpleMessage("Наманган"),
    "regionNavoi": MessageLookupByLibrary.simpleMessage("Навои"),
    "regionSamarkand": MessageLookupByLibrary.simpleMessage("Самарканд"),
    "regionSurkhandarya": MessageLookupByLibrary.simpleMessage("Сурхандарья"),
    "regionSyrdarya": MessageLookupByLibrary.simpleMessage("Сырдарья"),
    "regionTashkentCity": MessageLookupByLibrary.simpleMessage("Город Ташкент"),
    "regionTashkentRegion": MessageLookupByLibrary.simpleMessage(
      "Ташкентская область",
    ),
    "relatedProducts": MessageLookupByLibrary.simpleMessage("Похожие товары"),
    "relist": MessageLookupByLibrary.simpleMessage("Вернуть в продажу"),
    "relistTitle": MessageLookupByLibrary.simpleMessage("Возврат в продажу"),
    "reopenOrder": MessageLookupByLibrary.simpleMessage("Открыть снова"),
    "reopenOrderConfirm": MessageLookupByLibrary.simpleMessage(
      "Снова показать заявку продавцам?",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Обязательно"),
    "requiredField": MessageLookupByLibrary.simpleMessage("Обязательное поле"),
    "resetFilters": MessageLookupByLibrary.simpleMessage("Сбросить"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "reviewCommentHint": MessageLookupByLibrary.simpleMessage(
      "Расскажите о вашем опыте (необязательно)",
    ),
    "reviewDeleted": MessageLookupByLibrary.simpleMessage("Отзыв удалён"),
    "reviewSubmitted": MessageLookupByLibrary.simpleMessage("Спасибо за отзыв"),
    "reviewUpdated": MessageLookupByLibrary.simpleMessage("Отзыв обновлён"),
    "reviewsTitle": MessageLookupByLibrary.simpleMessage("Отзывы"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "searchHubAdvancedProductFilters": MessageLookupByLibrary.simpleMessage(
      "Фильтры товаров",
    ),
    "searchHubAwaitingTyping": MessageLookupByLibrary.simpleMessage(
      "Продолжайте ввод — мы собираем товары, мастерские, услуги на карте и заявки в одном ответе.",
    ),
    "searchHubCategoryIdeas": MessageLookupByLibrary.simpleMessage(
      "Популярные категории",
    ),
    "searchHubEverythingHint": MessageLookupByLibrary.simpleMessage(
      "Поиск запчастей, сервисов, заявок и продавцов…",
    ),
    "searchHubNoGroupedHits": MessageLookupByLibrary.simpleMessage(
      "Пока ничего не нашли",
    ),
    "searchHubOpenMap": MessageLookupByLibrary.simpleMessage("Карта"),
    "searchHubRecent": MessageLookupByLibrary.simpleMessage("Недавние запросы"),
    "searchHubScopeCars": MessageLookupByLibrary.simpleMessage("Авто"),
    "searchHubScopeCarsSeed": MessageLookupByLibrary.simpleMessage(
      "автомобиль",
    ),
    "searchHubScopeNearby": MessageLookupByLibrary.simpleMessage("Рядом"),
    "searchHubScopeOrders": MessageLookupByLibrary.simpleMessage("Заявки"),
    "searchHubScopeParts": MessageLookupByLibrary.simpleMessage("Запчасти"),
    "searchHubScopePartsSeed": MessageLookupByLibrary.simpleMessage("запчасти"),
    "searchHubScopeServices": MessageLookupByLibrary.simpleMessage("Услуги"),
    "searchHubScopeWorkshops": MessageLookupByLibrary.simpleMessage(
      "Авто услуги",
    ),
    "searchHubScopeWorkshopsSeed": MessageLookupByLibrary.simpleMessage(
      "авто услуги",
    ),
    "searchHubSectionOrders": MessageLookupByLibrary.simpleMessage("Заявки"),
    "searchHubSectionProducts": MessageLookupByLibrary.simpleMessage("Товары"),
    "searchHubSectionSellers": MessageLookupByLibrary.simpleMessage("Продавцы"),
    "searchHubSectionServices": MessageLookupByLibrary.simpleMessage("Услуги"),
    "searchHubSectionWorkshops": MessageLookupByLibrary.simpleMessage(
      "Авто услуги",
    ),
    "searchHubTrending": MessageLookupByLibrary.simpleMessage("В тренде"),
    "searchHubUnifiedTitle": MessageLookupByLibrary.simpleMessage("Обзор"),
    "searchHubVoiceSoon": MessageLookupByLibrary.simpleMessage(
      "Голосовой поиск скоро появится",
    ),
    "searchSellerProducts": MessageLookupByLibrary.simpleMessage(
      "Поиск в магазине",
    ),
    "seeAll": MessageLookupByLibrary.simpleMessage("Все"),
    "select": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "selectBirthDay": MessageLookupByLibrary.simpleMessage(
      "Выберите дату рождения",
    ),
    "selectBrand": MessageLookupByLibrary.simpleMessage("Выберите марку"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Выберите модель"),
    "selectPartCategory": MessageLookupByLibrary.simpleMessage(
      "Выберите категорию",
    ),
    "sellerAtUsername": m20,
    "sellerBioSection": MessageLookupByLibrary.simpleMessage("О продавце"),
    "sellerCategories": MessageLookupByLibrary.simpleMessage(
      "Категории продавца",
    ),
    "sellerDashboardPreview": MessageLookupByLibrary.simpleMessage(
      "Превью магазина",
    ),
    "sellerDescriptionSection": MessageLookupByLibrary.simpleMessage(
      "Описание",
    ),
    "sellerFollowersProducts": m21,
    "sellerInformation": MessageLookupByLibrary.simpleMessage(
      "Информация о продавце",
    ),
    "sellerProfile": MessageLookupByLibrary.simpleMessage("Профиль продавца"),
    "sellerSince": m22,
    "sellerSinceDescription": MessageLookupByLibrary.simpleMessage(
      "Показывает месяц и год регистрации продавца",
    ),
    "sellerSocialLinks": MessageLookupByLibrary.simpleMessage("Соцсети"),
    "sellerStatActiveProducts": MessageLookupByLibrary.simpleMessage(
      "Активные",
    ),
    "sellerStatCategories": MessageLookupByLibrary.simpleMessage("Категории"),
    "sellerStatFollowers": MessageLookupByLibrary.simpleMessage("Подписчики"),
    "sellerStatProducts": MessageLookupByLibrary.simpleMessage("Товары"),
    "sellerStatProfileViews": MessageLookupByLibrary.simpleMessage(
      "Просмотры профиля",
    ),
    "sellerStoreEmpty": MessageLookupByLibrary.simpleMessage(
      "У продавца пока нет товаров",
    ),
    "sellerStoreEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Подпишитесь, чтобы узнать о новых объявлениях.",
    ),
    "serverNotWorking": MessageLookupByLibrary.simpleMessage(
      "Сервер в настоящее время не работает. Пожалуйста, попробуйте позже.",
    ),
    "service": MessageLookupByLibrary.simpleMessage("Сервис"),
    "serviceFeatures": MessageLookupByLibrary.simpleMessage("Особенности"),
    "services": MessageLookupByLibrary.simpleMessage("Услуги"),
    "servicesHubEmptyNearby": MessageLookupByLibrary.simpleMessage(
      "Пока нет сервисов с геолокацией рядом. Откройте карту или добавьте свой бизнес.",
    ),
    "servicesHubEmptyTopRated": MessageLookupByLibrary.simpleMessage(
      "Пока нет лучших сервисов.",
    ),
    "servicesHubOpenMapSubtitle": MessageLookupByLibrary.simpleMessage(
      "Смотрите мастерские и услуги на карте",
    ),
    "servicesHubSubtitle": MessageLookupByLibrary.simpleMessage(
      "Найдите проверенные сервисы и запишитесь онлайн",
    ),
    "sessionExpired": MessageLookupByLibrary.simpleMessage(
      "Ваша сессия истекла. Пожалуйста, войдите снова.",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "shareProfile": MessageLookupByLibrary.simpleMessage("Поделиться профилем"),
    "showEmail": MessageLookupByLibrary.simpleMessage("Показывать email"),
    "showFollowersCount": MessageLookupByLibrary.simpleMessage(
      "Показывать подписчиков",
    ),
    "showLocationPublicly": MessageLookupByLibrary.simpleMessage(
      "Показывать местоположение",
    ),
    "showPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Показывать телефон",
    ),
    "signIn": MessageLookupByLibrary.simpleMessage("Войти"),
    "signInToBookService": MessageLookupByLibrary.simpleMessage(
      "Войдите, чтобы записаться",
    ),
    "signInToContinue": MessageLookupByLibrary.simpleMessage(
      "Войдите, чтобы продолжить",
    ),
    "signInToContinueHint": MessageLookupByLibrary.simpleMessage(
      "Создайте аккаунт, чтобы писать продавцам, сохранять избранное и публиковать объявления.",
    ),
    "signInToMessageBuyer": MessageLookupByLibrary.simpleMessage(
      "Войдите, чтобы написать покупателю",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("Зарегистрироваться"),
    "similarProducts": MessageLookupByLibrary.simpleMessage("Похожие товары"),
    "skip": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "sortBy": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "sortNewest": MessageLookupByLibrary.simpleMessage("Сначала новые"),
    "sortPriceAsc": MessageLookupByLibrary.simpleMessage("Сначала дешёвые"),
    "sortPriceDesc": MessageLookupByLibrary.simpleMessage("Сначала дорогие"),
    "sortPriceHighLow": MessageLookupByLibrary.simpleMessage(
      "Цена: по убыванию",
    ),
    "sortPriceLowHigh": MessageLookupByLibrary.simpleMessage(
      "Цена: по возрастанию",
    ),
    "sortRecommended": MessageLookupByLibrary.simpleMessage("Рекомендуем"),
    "specialOffers": MessageLookupByLibrary.simpleMessage(
      "Специальные предложения",
    ),
    "storeAnalytics": MessageLookupByLibrary.simpleMessage(
      "Аналитика магазина",
    ),
    "storeCreated": MessageLookupByLibrary.simpleMessage("Магазин создан"),
    "storeProfileCompletion": MessageLookupByLibrary.simpleMessage(
      "Заполненность профиля",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "submitReview": MessageLookupByLibrary.simpleMessage("Отправить отзыв"),
    "success": MessageLookupByLibrary.simpleMessage("Успешно"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("support@myauto.uz"),
    "supportPhone": MessageLookupByLibrary.simpleMessage("+998 95 384 10 00"),
    "termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Условия использования",
    ),
    "thirdPartySharing": MessageLookupByLibrary.simpleMessage(
      "3. Передача третьим лицам",
    ),
    "thirdPartySharingText": MessageLookupByLibrary.simpleMessage(
      "Мы не продаем ваши данные. Мы можем делиться ими с третьими сторонами только для предоставления наших услуг (например, хостинг, аналитика).",
    ),
    "timeExample": MessageLookupByLibrary.simpleMessage("Пример: 9:00 - 18:00"),
    "title": MessageLookupByLibrary.simpleMessage("Заголовок"),
    "titleOfParts": MessageLookupByLibrary.simpleMessage("Название запчастей"),
    "titleOfServices": MessageLookupByLibrary.simpleMessage("Название услуги"),
    "topCategories": MessageLookupByLibrary.simpleMessage("Топ категории"),
    "topDeals": MessageLookupByLibrary.simpleMessage("Лучшие предложения"),
    "topProducts": MessageLookupByLibrary.simpleMessage("Топ товары"),
    "trendingAkp": MessageLookupByLibrary.simpleMessage("АКПП"),
    "trendingBattery": MessageLookupByLibrary.simpleMessage("Аккумулятор"),
    "trendingBrakes": MessageLookupByLibrary.simpleMessage("Тормоза"),
    "trendingDetailing": MessageLookupByLibrary.simpleMessage("Детейлинг"),
    "trendingDiagnostics": MessageLookupByLibrary.simpleMessage("Диагностика"),
    "trendingEngineOil": MessageLookupByLibrary.simpleMessage(
      "Масло двигателя",
    ),
    "trendingNow": MessageLookupByLibrary.simpleMessage("В тренде"),
    "trendingNowSubtitle": MessageLookupByLibrary.simpleMessage(
      "Популярное на этой неделе",
    ),
    "trendingTires": MessageLookupByLibrary.simpleMessage("Шины"),
    "trendingTowTruck": MessageLookupByLibrary.simpleMessage("Эвакуатор"),
    "tryAnotherSearch": MessageLookupByLibrary.simpleMessage(
      "Попробуйте другой поиск или создайте заявку",
    ),
    "tuning": MessageLookupByLibrary.simpleMessage("Тюнинг"),
    "unableToLoadStore": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить магазин",
    ),
    "unfollow": MessageLookupByLibrary.simpleMessage("Отписаться"),
    "unfollowConfirm": MessageLookupByLibrary.simpleMessage(
      "Отписаться от продавца?",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "upload": MessageLookupByLibrary.simpleMessage("Загрузить"),
    "used": MessageLookupByLibrary.simpleMessage("Б/у"),
    "user": MessageLookupByLibrary.simpleMessage("Пользователь"),
    "userAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "Пользователь уже существует",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Имя пользователя"),
    "verificationStatus": MessageLookupByLibrary.simpleMessage("Верификация"),
    "verificationWhatIsIt": MessageLookupByLibrary.simpleMessage(
      "Верификация подтверждает, что ваш магазин настоящий. Проверенные продавцы получают значок и больше доверия от покупателей.",
    ),
    "verifiedAccountOwnerInfo": MessageLookupByLibrary.simpleMessage(
      "Ваш магазин проверен командой AutoRin. Покупатели видят значок «Проверен» рядом с вашим именем и больше доверяют объявлениям.",
    ),
    "verifiedAccountPointIdentity": MessageLookupByLibrary.simpleMessage(
      "Личность продавца подтверждена",
    ),
    "verifiedAccountPointTrusted": MessageLookupByLibrary.simpleMessage(
      "Надёжный магазин на AutoRin",
    ),
    "verifiedAccountTitle": MessageLookupByLibrary.simpleMessage(
      "Проверенный аккаунт",
    ),
    "verifiedAccountVisitorInfo": MessageLookupByLibrary.simpleMessage(
      "Команда AutoRin проверила этого продавца и его магазин. Значок означает, что это реальный и надёжный продавец — можно покупать спокойнее.",
    ),
    "viewProfile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "views": MessageLookupByLibrary.simpleMessage("Просмотры"),
    "viewsOfPhone": MessageLookupByLibrary.simpleMessage("Просмотры телефона"),
    "whatDoYouWantSell": MessageLookupByLibrary.simpleMessage(
      "Что вы хотите продать?",
    ),
    "withDiscount": MessageLookupByLibrary.simpleMessage("Со скидкой"),
    "workingTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "workshopAbout": MessageLookupByLibrary.simpleMessage("О сервисе"),
    "workshopDeleted": MessageLookupByLibrary.simpleMessage(
      "Мастерская успешно удалена",
    ),
    "workshopFastResponse": MessageLookupByLibrary.simpleMessage(
      "Быстрый ответ",
    ),
    "workshopNearbyTitle": MessageLookupByLibrary.simpleMessage(
      "Мастерские рядом",
    ),
    "workshopOnRequest": MessageLookupByLibrary.simpleMessage("По запросу"),
    "workshopOpenNow": MessageLookupByLibrary.simpleMessage("Открыто"),
    "workshopOwnerReply": m23,
    "workshopPopular": MessageLookupByLibrary.simpleMessage("Популярные"),
    "workshopPriceFrom": m24,
    "workshopScreenSubtitle": MessageLookupByLibrary.simpleMessage(
      "Проверенные автосервисы рядом с вами",
    ),
    "workshopScreenTitle": MessageLookupByLibrary.simpleMessage("Мастерские"),
    "workshopSearchResults": MessageLookupByLibrary.simpleMessage(
      "Результаты поиска",
    ),
    "workshopStatusClosed": MessageLookupByLibrary.simpleMessage("Закрыто"),
    "workshopStatusOpen": MessageLookupByLibrary.simpleMessage("Открыто"),
    "workshopUntitled": MessageLookupByLibrary.simpleMessage(
      "Мастерская без названия",
    ),
    "workshopVerified": MessageLookupByLibrary.simpleMessage("Проверен"),
    "workshopsLiveMap": MessageLookupByLibrary.simpleMessage("Карта"),
    "writeReview": MessageLookupByLibrary.simpleMessage("Оставить отзыв"),
    "writeSeller": MessageLookupByLibrary.simpleMessage("Написать продавцу"),
    "yes": MessageLookupByLibrary.simpleMessage("Да"),
    "youCanUploadUpTo5Photos": MessageLookupByLibrary.simpleMessage(
      "Вы можете загрузить до 5 фото",
    ),
  };
}
