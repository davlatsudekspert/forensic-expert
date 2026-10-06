// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'FORENSIC EXPERT';

  @override
  String get appTagline => 'Evidence · Science · Precision';

  @override
  String get languageNameNative => 'Русский';

  @override
  String get chooseLanguageTitle => 'Выберите язык';

  @override
  String languageOptionSemantics(String language, String state) {
    return '$language. $state';
  }

  @override
  String get stateSelected => 'Выбрано';

  @override
  String get stateNotSelected => 'Не выбрано';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionBack => 'Назад';

  @override
  String get disclaimerTitle => 'Научный дисклеймер';

  @override
  String get disclaimerBody =>
      'Forensic Expert предназначен для профессиональной справки, обучения и научных расчётов. Приложение не заменяет валидированные лабораторные методики, институциональные протоколы, применимое законодательство и квалифицированное профессиональное суждение.';

  @override
  String get disclaimerNoConclusions =>
      'Приложение никогда не формирует экспертных заключений. Измеренная концентрация сама по себе не устанавливает причину смерти. Окончательное профессиональное суждение принадлежит квалифицированному специалисту.';

  @override
  String get disclaimerConsult =>
      'За медицинской консультацией, диагностикой или лечением обращайтесь к квалифицированному медицинскому специалисту.';

  @override
  String get disclaimerAccept => 'Понятно';

  @override
  String get modeTitle => 'Как вы будете использовать FORENSIC EXPERT?';

  @override
  String get modeSubtitle =>
      'Главный экран подстроится под ваш выбор. Его можно изменить позже в профиле.';

  @override
  String get modeProfessional => 'Специалист';

  @override
  String get modeProfessionalDescription =>
      'Судебные эксперты, врачи, токсикологи, химики, специалисты лабораторий и других судебно-экспертных направлений';

  @override
  String get modeStudent => 'Студент';

  @override
  String get modeStudentDescription =>
      'Студенты, ординаторы и стажёры, исследователи и обучающиеся';

  @override
  String get modeResearch => 'Наука / преподавание';

  @override
  String get modeResearchDescription =>
      'Научная библиотека, источники и преподавание';

  @override
  String get navHome => 'Главная';

  @override
  String get navTools => 'Расчёты';

  @override
  String get navLibrary => 'Справка';

  @override
  String get navAi => 'ИИ';

  @override
  String get navProfile => 'Профиль';

  @override
  String get searchHint => 'Поиск веществ, методов, инструментов, источников…';

  @override
  String get searchUnavailable =>
      'Поиск станет доступен после установки проверенной научной базы данных.';

  @override
  String get moduleForensicMedicine => 'Судебная медицина';

  @override
  String get moduleToxicology => 'Судебная токсикология';

  @override
  String get moduleLaboratory => 'Лаборатория';

  @override
  String get moduleSubstances => 'Библиотека веществ';

  @override
  String get moduleLearn => 'Обучение';

  @override
  String get moduleAi => 'Forensic AI';

  @override
  String get homeModulesHeading => 'Модули';

  @override
  String get inDevelopmentTitle => 'Нет проверенного содержания';

  @override
  String get inDevelopmentBody =>
      'Содержание появляется здесь только при наличии проверяемого источника и после экспертной проверки. Экран не заполняется данными ради внешнего вида.';

  @override
  String get unverifiedBanner =>
      'ДАННЫЕ НЕ ПРОВЕРЕНЫ — ТРЕБУЕТСЯ ПОДТВЕРЖДЕНИЕ ЭКСПЕРТА';

  @override
  String get statusVerified => 'Подтверждено';

  @override
  String get statusReviewed => 'Проверено';

  @override
  String get statusNeedsReview => 'Требует проверки';

  @override
  String get statusOutdated => 'Устарело';

  @override
  String get aiNotConnectedTitle => 'Рабочий ИИ-сервис не подключён';

  @override
  String get aiNotConnectedBody =>
      'Forensic AI будет отвечать только на основе проверенной внутренней базы знаний, всегда показывать источники и никогда не формировать экспертных заключений. Основная библиотека и калькуляторы работают без ИИ.';

  @override
  String get aiPiiWarning =>
      'Не вводите ФИО, номера дел, паспортные данные, номера телефонов, адреса и другие персональные данные.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Оформление';

  @override
  String get themeSystem => 'Системное';

  @override
  String get themeLight => 'Светлое';

  @override
  String get themeDark => 'Тёмное';

  @override
  String get settingsMode => 'Режим использования';

  @override
  String get scientificDatabaseLabel => 'Научная база данных';

  @override
  String get scientificDatabaseNotInstalled => 'Ещё не установлена';

  @override
  String get appVersionLabel => 'Версия приложения';

  @override
  String get legalSection => 'Правовая информация и безопасность';

  @override
  String get scientificDisclaimerLink => 'Научный дисклеймер';

  @override
  String get diagnosticsSection => 'Диагностика';

  @override
  String diagnosticsStartup(int ms) {
    return 'Время до первого кадра: $ms мс';
  }

  @override
  String diagnosticsSettingsLoad(int ms) {
    return 'Загрузка настроек: $ms мс';
  }

  @override
  String get diagnosticsNotMeasured => 'Не измерено';

  @override
  String get toolsTitle => 'Инструменты';

  @override
  String get libraryTitle => 'Библиотека';

  @override
  String get homeQuickAccess => 'Быстрый доступ';

  @override
  String get homeRecentTools => 'Недавние инструменты';

  @override
  String get homeFavorites => 'Избранное';

  @override
  String get homeRecentSearches => 'Недавние запросы';

  @override
  String get homeEmptyRecentTools =>
      'Здесь появятся открытые вами инструменты.';

  @override
  String get homeEmptyFavorites =>
      'Добавляйте инструменты и записи библиотеки в избранное — они появятся здесь.';

  @override
  String get homeEmptyRecentSearches =>
      'Ваши запросы хранятся только на этом устройстве.';

  @override
  String get homeContinueLearning => 'Продолжить обучение';

  @override
  String get homeStudyHubBody => 'Курсы, тесты, карточки и разбор случаев.';

  @override
  String get homePrototypeNotice =>
      'Демонстрационная сборка: записи с пометкой ОБРАЗЕЦ носят иллюстративный характер и не являются научным содержанием.';

  @override
  String get testDataBadge => 'ОБРАЗЕЦ';

  @override
  String get seeAll => 'Все';

  @override
  String get openAction => 'Открыть';

  @override
  String get toolsSubtitle =>
      'Калькуляторы и пересчёты с формулой, допущениями и ограничениями.';

  @override
  String get toolCategoryToxicology => 'Токсикология';

  @override
  String get toolCategoryConversions => 'Пересчёт единиц';

  @override
  String get toolDilutionName => 'Разведение (C₁V₁ = C₂V₂)';

  @override
  String get toolDilutionDesc =>
      'Расчёт любого из четырёх параметров разведения.';

  @override
  String get toolWidmarkName => 'Алкоголь в крови (Видмарк)';

  @override
  String get toolWidmarkDesc =>
      'Оценка с указанием допущений, неопределённости и ограничений.';

  @override
  String get toolBackCalcName => 'Обратный расчёт этанола';

  @override
  String get toolBackCalcDesc =>
      'Оценка диапазона на более ранний момент времени.';

  @override
  String get toolPmiName => 'Давность смерти (Хенссге)';

  @override
  String get toolPmiDesc =>
      'Номограмма ректальной температуры (Henssge): оценка с 95 % границами.';

  @override
  String get toolMolarityName => 'Молярность и массовая концентрация';

  @override
  String get toolMolarityDesc =>
      'Молярная концентрация по навеске, молярной массе и объёму.';

  @override
  String get toolCalibrationName => 'Калибровка и линейная регрессия';

  @override
  String get toolCalibrationDesc =>
      'Градуировочная зависимость, остатки и статистика аппроксимации.';

  @override
  String get toolLodName => 'LOD / LOQ';

  @override
  String get toolLodDesc =>
      'Пределы обнаружения и количественного определения по градуировке.';

  @override
  String get toolStatsName => 'Описательная статистика';

  @override
  String get toolStatsDesc => 'Среднее, медиана, СО и КВ.';

  @override
  String get toolUnitsName => 'Пересчёт единиц концентрации';

  @override
  String get toolUnitsDesc =>
      'мг/л, мкг/мл, нг/мл, ммоль/л; массовая ↔ молярная при заданной молярной массе.';

  @override
  String get toolEthanolUnitsName => 'Пересчёт единиц этанола';

  @override
  String get toolEthanolUnitsDesc => 'г/л, ‰, мг/дл и г/100 мл.';

  @override
  String get toolStatusAvailable => 'Доступно';

  @override
  String get toolStatusPlanned => 'Запланировано';

  @override
  String get toolPlannedBody =>
      'Инструмент запланирован. Он будет добавлен только после экспертной проверки метода, формулы и источников.';

  @override
  String get favoriteAdd => 'Добавить в избранное';

  @override
  String get favoriteRemove => 'Удалить из избранного';

  @override
  String get calcInput => 'Входные данные';

  @override
  String get calcMethod => 'Метод';

  @override
  String get calcFormula => 'Формула';

  @override
  String get calcResult => 'Результат';

  @override
  String get calcAssumptions => 'Допущения';

  @override
  String get calcLimitations => 'Ограничения';

  @override
  String get calcReferences => 'Источники';

  @override
  String get calcSolveFor => 'Найти';

  @override
  String get calcStockConc => 'Исходная концентрация (C₁)';

  @override
  String get calcStockVol => 'Объём исходного раствора (V₁)';

  @override
  String get calcFinalConc => 'Конечная концентрация (C₂)';

  @override
  String get calcFinalVol => 'Конечный объём (V₂)';

  @override
  String get calcUnit => 'Единица';

  @override
  String get calcCalculate => 'Рассчитать';

  @override
  String get calcEnterValues => 'Введите три значения, чтобы найти четвёртое.';

  @override
  String get calcErrorPositive => 'Введите положительное число.';

  @override
  String get calcErrorUnits =>
      'Обе концентрации должны быть в совместимых единицах (массовых или молярных).';

  @override
  String get calcWarnExceeds =>
      'Конечная концентрация выше исходной — проверьте данные.';

  @override
  String get calcDilutionAssumptionConservation =>
      'При разведении количество вещества сохраняется.';

  @override
  String get calcDilutionAssumptionMixing =>
      'Объёмы аддитивны, смешивание полное.';

  @override
  String get calcDilutionLimitationContraction =>
      'Не подходит при заметном уменьшении объёма при смешивании (например, концентрированный этанол и вода).';

  @override
  String get calcDefinitional =>
      'Определяющее соотношение (сохранение количества вещества); литературные значения не используются.';

  @override
  String get calcNeedsReviewNotice =>
      'Калькулятор ещё не проверен лабораторным рецензентом.';

  @override
  String calcResultSemantics(String value) {
    return 'Результат: $value';
  }

  @override
  String get librarySubstances => 'Вещества';

  @override
  String get libraryMethods => 'Аналитические методы';

  @override
  String get librarySpecimens => 'Образцы';

  @override
  String get libraryReferences => 'Источники';

  @override
  String get libraryGlossary => 'Глоссарий';

  @override
  String get libraryFilterHint => 'Фильтр раздела…';

  @override
  String get filterAll => 'Все';

  @override
  String get libraryEmptyFiltered => 'Нет записей, соответствующих фильтру.';

  @override
  String get detailNames => 'Названия и синонимы';

  @override
  String get detailClass => 'Класс';

  @override
  String get detailMetabolites => 'Метаболиты';

  @override
  String get detailSpecimens => 'Образцы';

  @override
  String get detailMethods => 'Аналитические методы';

  @override
  String get detailConcentrations => 'Референтные концентрации';

  @override
  String get detailInterpretation => 'Интерпретация';

  @override
  String get detailStability => 'Стабильность и хранение';

  @override
  String get detailInterferences => 'Интерференции';

  @override
  String get detailReferences => 'Источники';

  @override
  String get detailEvidenceStatus => 'Статус доказательности';

  @override
  String get detailLastReviewed => 'Последняя проверка';

  @override
  String get detailNotReviewed => 'Не проверено';

  @override
  String get detailPlaceholder =>
      'Проверенные научные сведения для этой записи пока отсутствуют.';

  @override
  String get detailConcentrationsNote =>
      'Концентрация сама по себе не устанавливает причину смерти. Значения будут показаны только с указанием матрицы, популяции и источников.';

  @override
  String get sourcesButton => 'Источники';

  @override
  String get sourcesNone => 'К этой записи не привязаны источники.';

  @override
  String get searchGroupTools => 'Инструменты';

  @override
  String get searchGroupLearning => 'Обучение';

  @override
  String get searchClearHistory => 'Очистить историю';

  @override
  String get searchClearQuery => 'Очистить';

  @override
  String searchNoResultsTitle(String query) {
    return 'Ничего не найдено по запросу «$query»';
  }

  @override
  String get searchNoResultsBody =>
      'Проверьте написание или попробуйте другой язык — поддерживаются английские, русские и узбекские названия.';

  @override
  String get searchOfflineLabel => 'На устройстве · офлайн';

  @override
  String get searchExternalTitle => 'Научные базы данных (онлайн)';

  @override
  String get searchExternalBody =>
      'Внешние базы (PubMed, PubChem, Crossref) в этой версии не подключены. Внешние результаты никогда не смешиваются с проверенной внутренней базой.';

  @override
  String get searchTypeToStart => 'Введите не менее двух символов.';

  @override
  String searchResultsSemantics(int count) {
    return 'Результатов: $count';
  }

  @override
  String get aiAskTitle => 'Вопрос Forensic AI';

  @override
  String get aiInputHint =>
      'Спросите о веществах, методах или ограничениях интерпретации…';

  @override
  String get aiSend => 'Отправить';

  @override
  String aiPiiDetected(String kinds) {
    return 'Обнаружены возможные персональные данные: $kinds. Удалите их перед отправкой.';
  }

  @override
  String get piiKindEmail => 'эл. почта';

  @override
  String get piiKindPhone => 'номер телефона';

  @override
  String get piiKindPassport => 'номер паспорта/ID';

  @override
  String get piiKindCase => 'номер дела';

  @override
  String get piiKindName => 'ФИО';

  @override
  String get piiKindAddress => 'адрес';

  @override
  String get aiPreviewTitle => 'Структура ответа (демонстрация)';

  @override
  String get aiPreviewNotice =>
      'ДЕМОНСТРАЦИЯ — это не ответ ИИ и не научная рекомендация. Показано лишь, как будет устроен ответ после подключения.';

  @override
  String get aiSectionAvailable => 'Имеющиеся данные';

  @override
  String get aiSectionConsiderations => 'Дифференциальные соображения';

  @override
  String get aiSectionLimitations => 'Ограничения интерпретации';

  @override
  String get aiSampleInternal =>
      'Пример утверждения со ссылкой на проверенный внутренний источник.';

  @override
  String get aiSampleExternal =>
      'Пример утверждения из внешнего источника, не прошедшего проверку.';

  @override
  String get aiSampleLimitation =>
      'Пример ограничения — окончательная интерпретация требует полного контекста случая.';

  @override
  String get aiEvidenceInternalVerified => 'Внутренний · подтверждено';

  @override
  String get aiEvidenceInternalReviewed => 'Внутренний · проверено';

  @override
  String get aiEvidenceExternal => 'Внешний · не проверено';

  @override
  String aiPlaceholderSource(int number) {
    return 'Пример источника $number';
  }

  @override
  String aiCitationSemantics(int number) {
    return 'Источник $number';
  }

  @override
  String get aiExpertJudgment =>
      'Окончательное профессиональное суждение принадлежит квалифицированному специалисту. Forensic AI не формирует экспертных заключений.';

  @override
  String get aiReport => 'Пожаловаться на ответ';

  @override
  String get learnCourses => 'Курсы';

  @override
  String get learnLessons => 'Уроки';

  @override
  String get learnQuiz => 'Тест';

  @override
  String get learnFlashcards => 'Карточки';

  @override
  String get learnCases => 'Разбор случаев';

  @override
  String get learnProgress => 'Прогресс';

  @override
  String get learnNotStarted => 'Не начато';

  @override
  String get learnProgressEmpty =>
      'Прогресс сохраняется на этом устройстве, когда вы начнёте.';

  @override
  String learnLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count урока',
      many: '$count уроков',
      few: '$count урока',
      one: '$count урок',
    );
    return '$_temp0';
  }

  @override
  String get learnStart => 'Начать';

  @override
  String get quizCheck => 'Проверить ответ';

  @override
  String get quizCorrect => 'Верно';

  @override
  String get quizIncorrect => 'Неверно';

  @override
  String get quizExplanation => 'Пояснение';

  @override
  String get flashcardShowAnswer => 'Показать ответ';

  @override
  String get flashcardKnew => 'Знаю';

  @override
  String get flashcardAgain => 'Повторить';

  @override
  String get profileSectionPreferences => 'Настройки';

  @override
  String get profileSectionAccount => 'Данные на этом устройстве';

  @override
  String get profileSectionAbout => 'О приложении и правовая информация';

  @override
  String get settingsContrast => 'Контраст';

  @override
  String get contrastStandard => 'Стандартный';

  @override
  String get contrastHigh => 'Высокий';

  @override
  String get contrastSystemHint =>
      '«Системный» следует настройкам специальных возможностей устройства.';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get openSourceLicenses => 'Лицензии открытого ПО';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get legalDraftNotice =>
      'Черновик. Документ будет опубликован после профессиональной юридической проверки.';

  @override
  String get privacySummary =>
      'Основная библиотека и калькуляторы работают офлайн. История поиска, прогресс и необязательный профиль (имя, организация, специальность) хранятся на вашем устройстве. Данные профиля и документы о квалификации передаются только при подаче заявки на профессиональное подтверждение, когда этот сервис будет подключён; документы хранятся конфиденциально и никогда не публикуются. В приложении нет рекламных SDK. Персональные данные и сведения о делах никогда не передаются ИИ автоматически.\n\nПриглашения: если вы используете код приглашения коллеги, сервер хранит только связь между аккаунтами и солёный хеш вашего email (для защиты от злоупотреблений при повторном создании аккаунта). Пригласивший видит только итоговые числа — никогда ваше имя, email, профиль или документы. Приложение не читает ваши контакты.';

  @override
  String get aboutBody =>
      'Профессиональное справочное, обучающее и научно-расчётное приложение для судебной экспертизы.';

  @override
  String get aboutVersions =>
      'Версия приложения и версия научной базы данных учитываются раздельно.';

  @override
  String get storeNotConnected =>
      'В этой сборке App Store / Google Play не подключены. Цены и покупки появятся только из магазина.';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get restoreNothing => 'Нет активных подписок для восстановления.';

  @override
  String get subscriptionSafetyNote =>
      'Предупреждения, ограничения и источники никогда не скрываются за подпиской.';

  @override
  String get moduleHubTools => 'Инструменты раздела';

  @override
  String get moduleHubReference => 'Справочник';

  @override
  String get settingsJurisdiction => 'Юрисдикция';

  @override
  String get jurisdictionPickerIntro =>
      'Научные данные международны и одинаковы для всех стран. Юрисдикция выбирает только правовой и процессуальный слой (законы, списки контролируемых веществ, национальные методики), который всегда показывается отдельно.';

  @override
  String get jurisdictionGroupGlobal => 'Международные и региональные';

  @override
  String get jurisdictionGroupCountries => 'Страны';

  @override
  String get jurisdictionNoContent =>
      'Правовой и процессуальный контент для этой юрисдикции пока не загружен. Каждая будущая запись будет содержать официальный источник, дату вступления в силу, редакцию и дату последней проверки.';

  @override
  String get jurisdictionCompare => 'Сравнить юрисдикции';

  @override
  String get jurisdictionCompareSoon =>
      'Запланировано. Станет доступно, когда появится проверенный правовой контент хотя бы для двух юрисдикций.';

  @override
  String get jurisdictionInternationalHint =>
      'Выбрано «Международный»: здесь применимы только международные конвенции и стандарты. Выберите страну, чтобы увидеть её правовой слой.';

  @override
  String get detailLayerScientific => 'Международные научные данные';

  @override
  String get detailLayerScientificNote =>
      'Не зависит от страны. Правовой статус и национальные процедуры показаны ниже отдельно.';

  @override
  String detailLayerJurisdiction(String name) {
    return 'Юрисдикционный слой: $name';
  }

  @override
  String get detailLegalStatus => 'Правовой статус';

  @override
  String get detailNationalMethods => 'Национальные методики и процедуры';

  @override
  String get detailChangeJurisdiction => 'Сменить юрисдикцию';

  @override
  String get purchaseTitle => 'Тарифы';

  @override
  String get purchaseCta => 'Посмотреть тарифы';

  @override
  String get purchaseFreeTitle => 'Бесплатно';

  @override
  String get purchaseFreeBody =>
      'Базовый офлайн-справочник, поиск и основные калькуляторы — без аккаунта.';

  @override
  String get purchaseAiNote =>
      'Профессиональные функции ИИ станут доступны только после подключения ИИ-сервиса; лимиты будут указаны до покупки.';

  @override
  String get purchaseOwned => 'Ваша подписка активна';

  @override
  String get purchaseUnavailableSnack => 'Покупки недоступны в этой сборке.';

  @override
  String get accessFree => 'Бесплатно';

  @override
  String get homePilotNotice =>
      'Научная база проходит экспертную проверку. Каждая запись показана с источниками и статусом проверки и не является окончательным выводом.';

  @override
  String get detailIdentity => 'Идентификаторы';

  @override
  String get detailMolecularFormula => 'Молекулярная формула';

  @override
  String get detailMolecularWeight => 'Молекулярная масса (г/моль)';

  @override
  String get detailIupac => 'Название IUPAC';

  @override
  String get detailBiomarker => 'Биомаркер';

  @override
  String get detailTransformationProduct => 'Продукт превращения';

  @override
  String get detailMetabolismNote => 'Метаболизм';

  @override
  String get detailExcerpt => 'Цитата из источника';

  @override
  String get detailExcerptWithheld =>
      'Цитата не показана: лицензия источника не разрешает повторное использование. Откройте источник.';

  @override
  String get detailProvenance => 'Происхождение данных';

  @override
  String detailEvidenceLevel(String level) {
    return 'Уровень доказательности $level';
  }

  @override
  String get detailReviewerStatus => 'Статус рецензирования';

  @override
  String get detailReviewsNone => 'Экспертных рецензий пока нет (требуется 2)';

  @override
  String detailReviewsCount(int count) {
    return 'Экспертных рецензий: $count';
  }

  @override
  String get detailVersion => 'Версия';

  @override
  String detailVersionValue(int claim, String pack) {
    return 'Утверждение v$claim · база $pack';
  }

  @override
  String get detailTranslationDraft =>
      'Названия: машинный черновик, перевод не проверен';

  @override
  String get detailNoContentYet =>
      'Для этого раздела пока нет контента с источниками.';

  @override
  String detailSourceAccessed(String date) {
    return 'Дата обращения: $date';
  }

  @override
  String get detailIdentifierVerified => 'Идентификатор проверен автоматически';

  @override
  String detailSourceLicence(String mode) {
    return 'Режим лицензии: $mode';
  }

  @override
  String legalSchedule(String convention, String schedules) {
    return '$convention: список $schedules';
  }

  @override
  String get legalListRow => 'Строка официального списка';

  @override
  String legalEffective(String date) {
    return 'Издание действует с $date';
  }

  @override
  String get legalDateYearOnly => '(в источнике указан только год)';

  @override
  String legalLastVerified(String date) {
    return 'Последняя проверка: $date';
  }

  @override
  String get legalInternationalLayer => 'Международный уровень (конвенции ООН)';

  @override
  String get legalNotInListNote =>
      'Отсутствие в этих списках не означает, что вещество не контролируется: национальное законодательство может отличаться.';

  @override
  String legalNoNational(String name) {
    return 'Национальный правовой контент для $name пока не загружен.';
  }

  @override
  String get lockedTitle => 'Входит в Student Pro и Professional Pro';

  @override
  String get lockedBody =>
      'Названия, предупреждения и источники остаются открытыми. Научные данные и юрисдикционный слой открываются в платном тарифе.';

  @override
  String get freeDemoBadge => 'Бесплатно (демо)';

  @override
  String get lockedBadge => 'Pro';

  @override
  String searchMoreLocked(int count) {
    return 'Ещё $count результатов в платном тарифе';
  }

  @override
  String get learnEmptyCourses =>
      'Курсы появятся после экспертной проверки учебного контента.';

  @override
  String get contentLoading => 'Загрузка научной базы…';

  @override
  String get libraryNotInstalled =>
      'В этой сборке научная база не установлена.';

  @override
  String get purchasePending => 'Покупка ожидает подтверждения магазина.';

  @override
  String get purchaseFailed => 'Покупка не завершена.';

  @override
  String get purchaseCancelled => 'Покупка отменена.';

  @override
  String get purchaseSuccess => 'Подписка активирована. Спасибо!';

  @override
  String get aboutTrademarkPending =>
      'Название и логотип: проверка товарного знака не завершена.';

  @override
  String get diagPurchaseNone => 'Подписка: магазин не подтвердил';

  @override
  String get diagPurchaseStore =>
      'Подписка: подтверждена только магазином — серверная проверка не подключена (блокирует релиз)';

  @override
  String get diagPurchaseServer => 'Подписка: проверена сервером';

  @override
  String get statusDraft => 'Черновик';

  @override
  String get searchGroupTopics => 'Судебная медицина и биохимия';

  @override
  String get searchGroupReagents => 'Реактивы и растворы';

  @override
  String get searchGroupScreening => 'Скрининговые тесты';

  @override
  String get searchGroupStandardsLaws => 'Стандарты и законы';

  @override
  String get moduleBiochemistry => 'Биохимия';

  @override
  String get moduleReagents => 'Реактивы и растворы';

  @override
  String get moduleScreening => 'Экспресс- и скрининговые тесты';

  @override
  String get moduleMethods => 'Методы и СОП';

  @override
  String get moduleStandardsLaws => 'Право и юрисдикции';

  @override
  String get moduleEmerging => 'Новые проблемы';

  @override
  String get homeAreasHeading => 'Профессиональные разделы';

  @override
  String get homeDbTitle => 'Офлайн-база';

  @override
  String homeDbPack(String version) {
    return 'Пакет научных данных $version';
  }

  @override
  String homeDbScientific(String version) {
    return 'Научные данные $version';
  }

  @override
  String homeDbJurisdiction(String version) {
    return 'Юрисдикционные данные $version';
  }

  @override
  String get homeDbOffline =>
      'Работает офлайн. Поиск и вопросы остаются на устройстве.';

  @override
  String get homeDbNotInstalled => 'Пакет контента не установлен.';

  @override
  String get homeDbLoading => 'Открытие офлайн-базы…';

  @override
  String get knowledgeEmpty => 'В установленном пакете пока нет записей.';

  @override
  String get knowledgeNoSourcedContent => 'Пока нет материалов с источниками';

  @override
  String get knowledgeStatements => 'Утверждения с источниками';

  @override
  String get knowledgeSafety => 'Ограничения и безопасность';

  @override
  String get knowledgeSources => 'Источники';

  @override
  String get knowledgeDetails => 'Подробности';

  @override
  String knowledgeSourceRef(String source) {
    return 'Источник: $source';
  }

  @override
  String get knowledgeNotInSource => 'В источниках не указано — не оценивается';

  @override
  String get knowledgeTaxonomy => 'Темы';

  @override
  String knowledgeTopicCount(int count, int total) {
    return 'Материалы с источниками: $count из $total тем';
  }

  @override
  String get reagentPreparation => 'Приготовление';

  @override
  String get reagentNoRecipe =>
      'В источниках не найден проверенный рецепт приготовления. Компоненты, количества, порядок, хранение и срок годности не показываются и не оцениваются.';

  @override
  String get reagentIngredients => 'Компоненты';

  @override
  String get reagentFinalVolume => 'Конечный объём';

  @override
  String get reagentSteps => 'Этапы';

  @override
  String get reagentOrderNotStated =>
      'Источник не указывает порядок добавления — этапы перечислены без нумерации.';

  @override
  String get reagentStorage => 'Хранение';

  @override
  String get reagentTemperature => 'Температура';

  @override
  String get reagentStability => 'Стабильность';

  @override
  String get reagentHazards => 'Опасность';

  @override
  String get reagentDisposal => 'Утилизация';

  @override
  String get reagentQc => 'Контроль качества';

  @override
  String get reagentOpenCalculator => 'Калькулятор приготовления раствора';

  @override
  String get screeningBanner =>
      'РЕЗУЛЬТАТ СКРИНИНГА ≠ ПОДТВЕРЖДЁННАЯ ИДЕНТИФИКАЦИЯ. Положительный скрининг предварителен и требует валидированного подтверждающего метода.';

  @override
  String get screeningAnalyte => 'Аналит';

  @override
  String get screeningSpecimen => 'Образец';

  @override
  String get screeningPrinciple => 'Принцип';

  @override
  String get screeningCutoff => 'Пороговое значение';

  @override
  String get screeningSensitivity => 'Чувствительность';

  @override
  String get screeningSpecificity => 'Специфичность';

  @override
  String get screeningCrossReactivity => 'Перекрёстная реактивность';

  @override
  String get screeningFalsePositive => 'Ложноположительные';

  @override
  String get screeningFalseNegative => 'Ложноотрицательные';

  @override
  String get screeningLimitations => 'Ограничения';

  @override
  String get screeningConfirmatory => 'Подтверждающие методы';

  @override
  String get methodKindScientific => 'Научные методы';

  @override
  String get methodKindInternational => 'Международные стандарты';

  @override
  String get methodKindNational => 'Национальные методики';

  @override
  String get methodKindSop => 'СОП учреждений';

  @override
  String get methodKindNote =>
      'Типы методов не смешиваются: научный метод — не правовое требование, а СОП действует только в своём учреждении.';

  @override
  String get methodNoKindEntries => 'Записей этого типа пока нет.';

  @override
  String get methodOrganization => 'Организация';

  @override
  String get methodJurisdiction => 'Юрисдикция';

  @override
  String get methodTechniques => 'Методы анализа';

  @override
  String get methodDocumentVersion => 'Версия документа';

  @override
  String emergingDate(String date) {
    return 'Опубликовано $date';
  }

  @override
  String get emergingEvidenceType => 'Тип доказательства';

  @override
  String get emergingScopeGlobal => 'Охват: глобальный';

  @override
  String get evidenceTypeOfficialAlert => 'Официальное предупреждение';

  @override
  String get evidenceTypePeerReviewed => 'Рецензируемая публикация';

  @override
  String get evidenceTypeReport => 'Отчёт';

  @override
  String get evidenceTypeStandard => 'Стандарт';

  @override
  String get emergingNote =>
      'У каждой записи есть источник, дата, тип доказательства и охват. Это не новостная лента.';

  @override
  String get emergingCatNps => 'Новые психоактивные вещества';

  @override
  String get emergingCatSyntheticOpioids => 'Синтетические опиоиды';

  @override
  String get emergingCatStimulants => 'Новые стимуляторы';

  @override
  String get emergingCatAnalytical => 'Аналитические проблемы';

  @override
  String get emergingCatInterferences => 'Новые интерференции';

  @override
  String get emergingCatPostmortem => 'Посмертная интерпретация';

  @override
  String get emergingCatStandards => 'Новые стандарты';

  @override
  String get emergingCatValidation => 'Валидация методов';

  @override
  String get emergingCatQuality => 'Качество лаборатории';

  @override
  String get emergingCatAlert => 'Научное предупреждение';

  @override
  String get fmTopicDeathInvestigation => 'Расследование смерти';

  @override
  String get fmTopicCauseMechanismManner => 'Причина, механизм и род смерти';

  @override
  String get fmTopicPostmortemChanges => 'Посмертные изменения';

  @override
  String get fmTopicPostmortemInterval => 'Давность наступления смерти';

  @override
  String get fmTopicAlgorMortis => 'Охлаждение трупа';

  @override
  String get fmTopicRigorMortis => 'Трупное окоченение';

  @override
  String get fmTopicLivorMortis => 'Трупные пятна';

  @override
  String get fmTopicDecomposition => 'Гниение';

  @override
  String get fmTopicTrauma => 'Травма';

  @override
  String get fmTopicBluntForceInjury => 'Тупая травма';

  @override
  String get fmTopicSharpForceInjury => 'Острая травма';

  @override
  String get fmTopicFirearmInjury => 'Огнестрельная травма';

  @override
  String get fmTopicAsphyxia => 'Асфиксия';

  @override
  String get fmTopicBurns => 'Ожоги';

  @override
  String get fmTopicElectricalInjury => 'Электротравма';

  @override
  String get fmTopicHypoHyperthermia => 'Гипо- и гипертермия';

  @override
  String get fmTopicDrowning => 'Утопление';

  @override
  String get fmTopicAnthropology => 'Судебная антропология';

  @override
  String get fmTopicAgeEstimation => 'Определение возраста';

  @override
  String get fmTopicSexEstimation => 'Определение пола';

  @override
  String get fmTopicStatureEstimation => 'Определение роста';

  @override
  String get fmTopicOdontology => 'Судебная одонтология';

  @override
  String get fmTopicDisasterVictimIdentification =>
      'Идентификация жертв катастроф';

  @override
  String get fmTopicHistology => 'Судебная гистология';

  @override
  String get fmTopicPostmortemImaging => 'Посмертная визуализация';

  @override
  String get compareTitle => 'Сравнение юрисдикций';

  @override
  String get compareTopicDrinkDrive =>
      'Вождение в нетрезвом виде: установленный предел алкоголя';

  @override
  String get compareNoData => 'Нет данных — вывод не делается';

  @override
  String get compareNoTopics =>
      'В пакете пока нет сопоставимых правовых данных.';

  @override
  String get compareNotAdvice =>
      'Справочная информация, не юридическая консультация. Сверяйтесь с действующим официальным текстом.';

  @override
  String get compareNoInference =>
      'Отсутствие данных не означает «разрешено», «не контролируется» или «запрещено».';

  @override
  String compareOverrides(String jurisdiction) {
    return 'Заменяет правило: $jurisdiction';
  }

  @override
  String compareArticle(String section) {
    return 'Статья/раздел: $section';
  }

  @override
  String compareAuthority(String name) {
    return 'Орган: $name';
  }

  @override
  String get compareOfficialExcerpt => 'Официальный текст';

  @override
  String get specimenBreath => 'Выдыхаемый воздух';

  @override
  String get specimenBlood => 'Кровь';

  @override
  String get specimenUrine => 'Моча';

  @override
  String get legalThresholdTitle => 'Правовой предел';

  @override
  String get legalLayerNational => 'Национальное / региональное право';

  @override
  String get legalOpenCompare => 'Сравнить юрисдикции';

  @override
  String get toolSolutionName => 'Приготовление раствора (необходимая масса)';

  @override
  String get toolSolutionDesc =>
      'Масса вещества для заданной концентрации и объёма: m = C·V(·M)/p. Молярную массу и чистоту вводите вы (сертификат/этикетка).';

  @override
  String get calcTargetConc => 'Целевая концентрация';

  @override
  String get calcMolarMass => 'Молярная масса (г/моль)';

  @override
  String get calcPurity => 'Чистота (0–1)';

  @override
  String get calcMassRequired => 'Необходимая масса';

  @override
  String get calcErrorMolarMass =>
      'Для молярной концентрации введите молярную массу из сертификата или этикетки.';

  @override
  String get calcErrorPurity => 'Чистота должна быть больше 0 и не больше 1.';

  @override
  String get calcSolutionAssumptionDefinition =>
      'Расчёт по определению концентрации (без эмпирических коэффициентов).';

  @override
  String get calcSolutionAssumptionInputs =>
      'Молярную массу и чистоту вводит пользователь; ничего не оценивается.';

  @override
  String get calcSolutionLimitationRecipe =>
      'Это не рецепт реактива: выбор вещества, порядок, хранение и стабильность — только из проверенного источника или СОП.';

  @override
  String get calcSolutionLimitationVolume =>
      'Изменение объёма при растворении не учитывается.';

  @override
  String get calcWarnPurity => 'Применена поправка на чистоту.';

  @override
  String legalExtent(String extent) {
    return 'Территориальное действие: $extent';
  }

  @override
  String legalAppliesTo(String places) {
    return 'Применяется: $places';
  }

  @override
  String get legalStatusInForce => 'Действует';

  @override
  String get legalStatusAmended => 'С изменениями';

  @override
  String get legalStatusSuperseded => 'Заменён';

  @override
  String get legalStatusRepealed => 'Утратил силу';

  @override
  String get aiExperienceProfessional => 'Профессионал';

  @override
  String get aiExperienceTutor => 'Наставник';

  @override
  String get aiExperienceProfessionalHint =>
      'Краткие ответы с источниками для специалистов.';

  @override
  String get aiExperienceTutorHint =>
      'Пошаговые объяснения для обучения, всегда с источниками.';

  @override
  String get aiFindSources => 'Найти источники офлайн';

  @override
  String get aiRetrievalTitle => 'Подходящие утверждения в офлайн-базе';

  @override
  String get aiRetrievalNote =>
      'Это не ответ ИИ: это результаты локального поиска, у каждого есть источник.';

  @override
  String get aiNoContext =>
      'В офлайн-базе нет надёжного контекста — ответ не даётся.';

  @override
  String get aiBlockedConclusion =>
      'Окончательные выводы о причине или роде смерти не даются. Это решение эксперта с полными материалами дела.';

  @override
  String get aiBlockedLegal =>
      'Юридические выводы (вина, обвинение, наказание) не даются.';

  @override
  String get aiBlockedPii =>
      'Удалите персональные данные перед поиском или вопросом.';

  @override
  String get learnLevelAll => 'Все уровни';

  @override
  String get learnLevelFoundation => 'Базовый';

  @override
  String get learnLevelIntermediate => 'Средний';

  @override
  String get learnLevelAdvanced => 'Продвинутый';

  @override
  String learnProgressValue(int done, int total) {
    return 'Пройдено уроков: $done из $total';
  }

  @override
  String get learnHistory => 'Недавно изученные';

  @override
  String get learnBookmarks => 'Закладки';

  @override
  String get learnBookmarksEmpty =>
      'Добавьте тему в закладки звёздочкой, чтобы найти её здесь.';

  @override
  String get learnMarkComplete => 'Отметить как пройденный';

  @override
  String get learnCompleted => 'Пройден';

  @override
  String get learnCourseSourceNote =>
      'Уроки показывают исходные утверждения источников. Новый научный текст не пишется; материалы ждут экспертной проверки.';

  @override
  String get learnExam => 'Режим экзамена';

  @override
  String get learnExamIntro =>
      'Ответьте на все вопросы. Результаты и пояснения появятся только после отправки.';

  @override
  String get learnExamSubmit => 'Завершить экзамен';

  @override
  String learnExamScore(int correct, int total) {
    return 'Результат: $correct из $total';
  }

  @override
  String get learnExamEmpty =>
      'Проверенных экзаменационных вопросов пока нет. Вопросы не генерируются автоматически.';

  @override
  String get learnExamRetry => 'Пройти снова';

  @override
  String get learnSimulatedCase => 'СМОДЕЛИРОВАННЫЙ СЛУЧАЙ — не реальное дело';

  @override
  String get moduleHistology => 'Судебная гистология';

  @override
  String get moduleResearch => 'Исследования и доказательства';

  @override
  String get group_alcohols_volatiles => 'Спирты и летучие вещества';

  @override
  String get group_toxic_gases => 'Токсичные газы';

  @override
  String get group_opioids => 'Опиоиды';

  @override
  String get group_stimulants => 'Стимуляторы';

  @override
  String get group_cannabinoids => 'Каннабиноиды';

  @override
  String get group_hallucinogens_dissociatives =>
      'Галлюциногены и диссоциативы';

  @override
  String get group_benzodiazepines => 'Бензодиазепины';

  @override
  String get group_sedatives_hypnotics => 'Седативные и снотворные';

  @override
  String get group_barbiturates => 'Барбитураты';

  @override
  String get group_antidepressants => 'Антидепрессанты';

  @override
  String get group_antipsychotics => 'Антипсихотики';

  @override
  String get group_anticonvulsants => 'Противосудорожные';

  @override
  String get group_pharmaceuticals => 'Распространённые лекарства';

  @override
  String get group_adulterants => 'Примеси (адюльтеранты)';

  @override
  String get group_pesticides => 'Пестициды и родентициды';

  @override
  String get group_metals_inorganic => 'Металлы и неорганические яды';

  @override
  String get groupAll => 'Все группы';

  @override
  String get groupEditorialNote =>
      'Группы — редакционная навигация, а не научная классификация.';

  @override
  String get detailAnalyticalMethods => 'Аналитические методы (из источников)';

  @override
  String get detailReportedConcentrations => 'Сообщённые концентрации';

  @override
  String get concentrationNotThreshold =>
      'Значения из отдельных исследований или случаев — НЕ токсические, летальные или правовые пороги. Интерпретация зависит от образца, контекста, толерантности и посмертных изменений.';

  @override
  String get concentrationSpecimen => 'Образец';

  @override
  String concentrationContext(String context) {
    return 'Контекст: $context';
  }

  @override
  String get detailStructure => 'Химическая структура';

  @override
  String get detailRelated => 'Связанные профессиональные материалы';

  @override
  String get relationAnalysedBy =>
      'Анализируется методом (упомянуто в источнике)';

  @override
  String get relationMetabolism => 'Упомянуто вместе в источнике о метаболизме';

  @override
  String get relationConfirmedBy => 'Подтверждающие методы';

  @override
  String get relationRelatedTopic => 'Связанные темы';

  @override
  String get relationResearch => 'Исследования и доказательства';

  @override
  String relationBasis(String basis) {
    return 'Основание: $basis';
  }

  @override
  String researchMore(int count) {
    return 'Все исследования ($count)';
  }

  @override
  String get researchTitle => 'Библиотека исследований';

  @override
  String get researchNote =>
      'Только метаданные и ссылки — полные тексты не копируются. Диссертации, тезисы и материалы конференций не приравниваются к рецензируемым статьям.';

  @override
  String get researchAll => 'Все';

  @override
  String get researchPeerReviewed => 'Рецензируемая';

  @override
  String get researchNotPeerReviewed => 'Не рецензируемая статья';

  @override
  String researchEvidence(String level) {
    return 'Доказательность $level';
  }

  @override
  String get researchCopyLink => 'Копировать ссылку';

  @override
  String get researchLinkCopied => 'Ссылка скопирована';

  @override
  String get researchLinked => 'Связанные записи';

  @override
  String researchCount(int count) {
    return '$count записей';
  }

  @override
  String researchSourceApi(String api) {
    return 'Индексировано через $api';
  }

  @override
  String get researchKindJournalArticle => 'Статья';

  @override
  String get researchKindReview => 'Обзор';

  @override
  String get researchKindSystematicReview => 'Систематический обзор';

  @override
  String get researchKindMetaAnalysis => 'Метаанализ';

  @override
  String get researchKindCaseReport => 'Описание случая';

  @override
  String get researchKindConferenceAbstract => 'Тезисы конференции';

  @override
  String get researchKindConferencePaper => 'Доклад конференции';

  @override
  String get researchKindDissertation => 'Докторская диссертация';

  @override
  String get researchKindThesis => 'Диссертация (магистерская / др.)';

  @override
  String get researchKindOfficialReport => 'Официальный отчёт';

  @override
  String get researchKindStandard => 'Стандарт / руководство';

  @override
  String get imageSchematic => 'Схема — не экспериментальные данные';

  @override
  String get imageRealData => 'Рисунок из опубликованного исследования';

  @override
  String get imageDepiction => 'Изображение структуры (рассчитано)';

  @override
  String imageLicense(String license) {
    return 'Лицензия: $license';
  }

  @override
  String get imageAttribution => 'Атрибуция';

  @override
  String get imageOriginalCaption => 'Оригинальная подпись';

  @override
  String imageOpen(String title) {
    return 'Открыть изображение: $title';
  }

  @override
  String get imageUnavailable => 'Изображение недоступно офлайн';

  @override
  String get imagesHeading => 'Научные иллюстрации';

  @override
  String get licenseOriginalWork => 'Оригинальная работа (FORENSIC EXPERT)';

  @override
  String get licenseFactualDepiction =>
      'Оригинальное изображение фактических данных';

  @override
  String get histologyNote =>
      'Справочная информация для специалистов. Приложение и Forensic AI не ставят гистологических диагнозов.';

  @override
  String get fieldCaseObservation => 'Наблюдение (единичный случай)';

  @override
  String get fieldComposition => 'Состав (как в источнике)';

  @override
  String get fieldConfirmation => 'Требование подтверждения';

  @override
  String get metaAuthors => 'Авторы';

  @override
  String get metaContainer => 'Журнал / конференция';

  @override
  String get metaInstitution => 'Учреждение';

  @override
  String get metaDegree => 'Степень';

  @override
  String get metaYear => 'Год';

  @override
  String get metaCreator => 'Автор изображения';

  @override
  String get metaSource => 'Источник';

  @override
  String get metaAccessed => 'Дата обращения';

  @override
  String get tech_tlc => 'ТСХ (тонкослойная хроматография)';

  @override
  String get tech_gc => 'ГХ';

  @override
  String get tech_gcFid => 'ГХ-ПИД';

  @override
  String get tech_headspaceGc => 'Парофазная ГХ';

  @override
  String get tech_gcMs => 'ГХ-МС';

  @override
  String get tech_hplc => 'ВЭЖХ';

  @override
  String get tech_lcMsMs => 'ЖХ-МС/МС';

  @override
  String get tech_uvVis => 'УФ-видимая спектрофотометрия';

  @override
  String get tech_immunoassay => 'Иммуноанализ';

  @override
  String get tech_spectroscopy => 'Спектроскопия';

  @override
  String get tech_samplePreparation => 'Пробоподготовка';

  @override
  String get tech_extraction => 'Экстракция';

  @override
  String get tech_calibration => 'Калибровка';

  @override
  String get tech_qualityControl => 'Контроль качества';

  @override
  String get tech_validation => 'Валидация методики';

  @override
  String get tech_uncertainty => 'Неопределённость измерений';

  @override
  String get tech_statistics => 'Статистика';

  @override
  String get methodSection_purpose => 'Назначение';

  @override
  String get methodSection_scope => 'Область применения';

  @override
  String get methodSection_analytes => 'Аналиты';

  @override
  String get methodSection_specimens => 'Образцы';

  @override
  String get methodSection_principle => 'Принцип';

  @override
  String get methodSection_equipment => 'Оборудование';

  @override
  String get methodSection_reagents => 'Реагенты';

  @override
  String get methodSection_samplePreparation => 'Пробоподготовка';

  @override
  String get methodSection_calibrationQc => 'Калибровка и контроль качества';

  @override
  String get methodSection_workflow => 'Порядок работы';

  @override
  String get methodSection_interpretation => 'Интерпретация';

  @override
  String get methodSection_limitations => 'Ограничения';

  @override
  String get methodSection_validationStatus => 'Статус валидации';

  @override
  String get toolPercentName => 'Процентные растворы';

  @override
  String get toolPercentDesc =>
      'Количество вещества для % (масс./об.), (об./об.) или (масс./масс.) по определению.';

  @override
  String get calcValue => 'Значение';

  @override
  String get calcFrom => 'Из';

  @override
  String get calcTo => 'В';

  @override
  String get calcConvertAssumption =>
      'Приставки единиц — определения СИ; пересчёт массовой ↔ молярной использует ρ = c · M.';

  @override
  String get calcConvertLimitation =>
      'Молярная масса должна браться из сертификата или проверенных идентификационных данных; калькулятор её не оценивает.';

  @override
  String get calcMolarityMass => 'Навеска';

  @override
  String get calcMolarityVolume => 'Конечный объём';

  @override
  String get calcMolarityResult => 'Молярная концентрация';

  @override
  String get calcMolarityAssumption =>
      'Определение молярной концентрации: c = n / V, где n = m · p / M.';

  @override
  String get calcPercentBasis => 'Тип процентной концентрации';

  @override
  String get calcPercentWv => '% (масс./об.) — г на 100 мл';

  @override
  String get calcPercentVv => '% (об./об.) — мл на 100 мл';

  @override
  String get calcPercentWw => '% (масс./масс.) — г на 100 г';

  @override
  String get calcPercentValue => 'Процент (%)';

  @override
  String get calcPercentTotalMl => 'Общий объём раствора (мл)';

  @override
  String get calcPercentTotalG => 'Общая масса раствора (г)';

  @override
  String get calcPercentSolute => 'Количество растворённого вещества';

  @override
  String get calcPercentAssumption =>
      'Определения процентной концентрации — как указано для каждого типа.';

  @override
  String get calcPercentLimitationBasis =>
      'масс./об., об./об. и масс./масс. не взаимозаменяемы — используйте тип, указанный в валидированной методике или СОП.';

  @override
  String get calcErrorPercent => 'Введите процент больше 0 и не более 100.';

  @override
  String get calcStatsValues =>
      'Значения (через пробел, запятую или с новой строки)';

  @override
  String get calcStatsN => 'n';

  @override
  String get calcStatsMean => 'Среднее';

  @override
  String get calcStatsMedian => 'Медиана';

  @override
  String get calcStatsSd => 'СО (n − 1)';

  @override
  String get calcStatsCv => 'КВ %';

  @override
  String get calcStatsMin => 'Минимум';

  @override
  String get calcStatsMax => 'Максимум';

  @override
  String get calcStatsAssumption =>
      'Выборочное стандартное отклонение со знаменателем n − 1.';

  @override
  String get calcStatsLimitation =>
      'Проверка выбросов и нормальности не выполняется.';

  @override
  String get calcStatsWarnSd => 'Для СО и КВ нужно не менее двух значений.';

  @override
  String get calcErrorValues => 'Введите только числовые значения.';

  @override
  String get calcRegPoints => 'Точки калибровки (по одной паре «x y» в строке)';

  @override
  String get calcRegSlope => 'Наклон (b)';

  @override
  String get calcRegIntercept => 'Свободный член (a)';

  @override
  String get calcRegR2 => 'R²';

  @override
  String get calcRegSyx => 'Остаточное СО (s_y/x)';

  @override
  String get calcRegAssumptionOls =>
      'Метод наименьших квадратов без весов, y = a + b·x.';

  @override
  String get calcRegLimitationRange =>
      'Справедливо только в пределах калибровочного диапазона; взвешивание и линейность определяются валидацией методики.';

  @override
  String get calcRegWarnFew =>
      'Менее пяти точек калибровки — интерпретируйте с осторожностью.';

  @override
  String get calcErrorPoints => 'Введите не менее трёх пар «x y» с разными x.';

  @override
  String get calcLodSigma => 'Стандартное отклонение отклика (σ)';

  @override
  String get calcLodSlope => 'Наклон калибровочной кривой (S)';

  @override
  String get calcLodSigmaBasis => 'Источник σ';

  @override
  String get calcLodBasisBlank => 'СО откликов холостых проб';

  @override
  String get calcLodBasisResidual => 'Остаточное СО регрессии';

  @override
  String get calcLodBasisIntercept => 'СО свободных членов регрессий';

  @override
  String get calcLodLod => 'Предел обнаружения (DL = 3,3σ/S)';

  @override
  String get calcLodLoq => 'Предел количественного определения (QL = 10σ/S)';

  @override
  String get calcLodAssumptionSigma =>
      'σ оценивается одним из подходов, названных в источнике: СО холостых проб, остаточное СО или СО свободных членов.';

  @override
  String get calcLodAssumptionLinear => 'Отклик линеен вблизи предела.';

  @override
  String get calcLodLimitationOne =>
      'Это один из нескольких допустимых подходов; другие — визуальная оценка и отношение сигнал/шум.';

  @override
  String get calcLodLimitationVerify =>
      'Источник требует подтверждать рассчитанные пределы анализом проб вблизи предела.';

  @override
  String get calcLodReference =>
      'ICH Q2(R2) Validation of Analytical Procedures (2023) — §3.2.3.3';

  @override
  String get calcLodReferenceNote =>
      'Коэффициенты сверены с официальным PDF ICH Q2(R2); они не изменились по сравнению с Q2(R1) (заменён). Q2(R2) допускает также S/N и прямое подтверждение точности/прецизионности. Требуется подтверждение лабораторного рецензента (RG-25).';

  @override
  String get calcUseRegression => 'Взять σ = s_y/x и S из этой регрессии';

  @override
  String get calcErrorSigma => 'Введите σ > 0 и ненулевой наклон.';

  @override
  String get researchKindGuideline => 'Руководство';

  @override
  String get researchKindValidationStudy => 'Валидационное исследование';

  @override
  String get researchKindCaseSeries => 'Серия случаев';

  @override
  String get tech_gcMsMs => 'ГХ-МС/МС';

  @override
  String get tech_lcMs => 'ЖХ-МС';

  @override
  String get tech_hrms => 'HRMS (масс-спектрометрия высокого разрешения)';

  @override
  String get tech_spectrophotometry => 'Спектрофотометрия';

  @override
  String get emergingCatBiomarkers => 'Новые биомаркеры';

  @override
  String get emergingCatMethods => 'Новые аналитические методы';

  @override
  String get emergingCatLegal => 'Правовые и регуляторные изменения';

  @override
  String get severityCritical => 'Критично';

  @override
  String get severityWarning => 'Предупреждение';

  @override
  String get severityInfo => 'Информация';

  @override
  String get severityReview => 'Статус проверки';

  @override
  String get homeRecentlyViewed => 'Недавно просмотренные';

  @override
  String get homeQuickEmpty =>
      'Здесь появятся недавно просмотренные записи, инструменты, избранное и поиски. Они хранятся только на этом устройстве.';

  @override
  String homeJurisdictionChip(String name) {
    return 'Юрисдикция: $name';
  }

  @override
  String get homeChange => 'Изменить';

  @override
  String get homeAllDisciplines => 'Все судебные дисциплины';

  @override
  String get homeAllDisciplinesBody =>
      '20 дисциплин — охват и доступный контент';

  @override
  String get disc_forensicMedicine => 'Судебная медицина';

  @override
  String get disc_forensicPathology => 'Судебная патология';

  @override
  String get disc_clinicalForensicMedicine => 'Клиническая судебная медицина';

  @override
  String get disc_forensicRadiology => 'Судебная радиология и визуализация';

  @override
  String get disc_forensicPsychiatry => 'Судебная психиатрия и психология';

  @override
  String get disc_forensicToxicology => 'Судебная токсикология';

  @override
  String get disc_forensicChemistry => 'Судебная химия';

  @override
  String get disc_forensicBiochemistry => 'Судебная биохимия';

  @override
  String get disc_analyticalScience => 'Аналитическая наука';

  @override
  String get disc_forensicBiology => 'Судебная биология';

  @override
  String get disc_forensicGenetics => 'Судебная генетика / ДНК';

  @override
  String get disc_forensicHistology => 'Судебная гистология';

  @override
  String get disc_forensicAnthropology => 'Судебная антропология';

  @override
  String get disc_forensicOdontology => 'Судебная одонтология';

  @override
  String get disc_forensicMicrobiology => 'Судебная микробиология';

  @override
  String get disc_forensicEntomology => 'Судебная энтомология';

  @override
  String get disc_humanIdentification => 'DVI / идентификация личности';

  @override
  String get disc_laboratoryQuality => 'Качество и валидация в лаборатории';

  @override
  String get disc_evidenceHandling =>
      'Обращение с доказательствами и цепочка хранения';

  @override
  String get disc_educationResearch => 'Образование и исследования';

  @override
  String get discGroupMedicine => 'Медицина и патология';

  @override
  String get discGroupToxChem => 'Токсикология и химия';

  @override
  String get discGroupBioId => 'Биология и идентификация';

  @override
  String get discGroupLab => 'Лаборатория и качество';

  @override
  String get discGroupEdu => 'Образование и исследования';

  @override
  String get disciplinesTitle => 'Судебные дисциплины';

  @override
  String get disciplinesIntro =>
      'FORENSIC EXPERT охватывает эти дисциплины. Содержание добавляется постепенно и только с источниками и экспертной проверкой — пустая дисциплина означает «пока нет материалов с источниками», а не «знаний нет».';

  @override
  String disciplineRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи с источниками',
      many: '$count записей с источниками',
      few: '$count записи с источниками',
      one: '1 запись с источником',
      zero: 'Пока нет записей с источниками',
    );
    return '$_temp0';
  }

  @override
  String get disciplineReferenceOnly =>
      'Только профессиональный справочный охват';

  @override
  String get disciplineModules => 'Модули';

  @override
  String get disciplineTopics => 'Планируемая структура тем';

  @override
  String get disciplineEmpty =>
      'В этой дисциплине пока нет контента с источниками. Записи будут добавляться только с проверяемыми источниками и экспертной проверкой.';

  @override
  String get jurisdictionsTitle => 'Право и юрисдикции';

  @override
  String get jurisdictionCurrent => 'Текущая юрисдикция';

  @override
  String get jurisdictionLayersTitle => 'Три отдельных слоя';

  @override
  String get layerGlobalCore =>
      'Глобальное научное ядро — одинаково во всех странах';

  @override
  String get layerIntlStandards =>
      'Международные стандарты и методы — не закон, если не приняты';

  @override
  String get layerCountryLaw =>
      'Право и процедуры страны / юрисдикции — только для выбранной юрисдикции';

  @override
  String get jurisdictionViewDetails => 'Правовой и процессуальный слой';

  @override
  String get jurisdictionWithContent => 'Юрисдикции с правовыми записями';

  @override
  String get jurisdictionSearchHint => 'Поиск страны или кода ISO';

  @override
  String get jurisdictionNotVerified =>
      'Контент для этой юрисдикции ещё не проверен. Законы других стран никогда не показываются вместо него.';

  @override
  String get jurisdictionPilotContent =>
      'Правовые записи · на юридической проверке';

  @override
  String get jurisdictionNoContentShort => 'Контент ещё не проверен';

  @override
  String jurisdictionChain(String chain) {
    return 'Применяется через: $chain';
  }

  @override
  String get jurisdictionGlobalWorks =>
      'Глобальный научный контент работает без выбора юрисдикции. Юрисдикция нужна только для законов, списков контролируемых веществ и национальных процедур.';

  @override
  String get jurisdictionInstruments => 'Официальные документы';

  @override
  String get jurisdictionIntlLayer => 'Международный слой (для всех)';

  @override
  String get jurisdictionOwnLayer => 'Слой конкретной юрисдикции';

  @override
  String get jurisdictionCountryNames =>
      'Названия стран: Unicode CLDR. Список только позволяет выбор — это не значит, что есть правовой контент.';

  @override
  String get docKindLaw => 'ЗАКОН';

  @override
  String get docKindRegulation => 'НОРМАТИВНЫЙ АКТ';

  @override
  String get docKindStandard => 'СТАНДАРТ';

  @override
  String get docKindGuideline => 'РУКОВОДСТВО';

  @override
  String get docKindMethod => 'МЕТОДИКА';

  @override
  String get docKindSop => 'СОП';

  @override
  String get docKindArticle => 'НАУЧНАЯ СТАТЬЯ';

  @override
  String get docKindOfficial => 'ОФИЦИАЛЬНЫЙ ДОКУМЕНТ';

  @override
  String get bindingLegal =>
      'Юридически обязателен в своей юрисдикции, пока действует';

  @override
  String get bindingVoluntary =>
      'Добровольный, если не принят законом или аккредитацией';

  @override
  String get bindingAdvisory => 'Рекомендательный — не обязателен юридически';

  @override
  String get bindingInstitutional =>
      'Действует только в выпустившем учреждении';

  @override
  String get bindingScientific =>
      'Научное доказательство — не нормативный документ';

  @override
  String get instrNumber => 'Официальный номер';

  @override
  String get instrPublished => 'Опубликован';

  @override
  String get instrEffectiveFrom => 'Действует с';

  @override
  String get instrEffectiveTo => 'Действует до';

  @override
  String get instrAmended => 'Последнее изменение';

  @override
  String get instrVersion => 'Версия / редакция';

  @override
  String get instrLegalStatus => 'Правовой статус';

  @override
  String get instrLanguage => 'Официальный язык';

  @override
  String get instrTranslation => 'Перевод';

  @override
  String get instrLastVerified => 'Последняя проверка';

  @override
  String get instrReview => 'Статус проверки';

  @override
  String get instrSource => 'Официальный источник';

  @override
  String get instrAuthority => 'Орган';

  @override
  String get translationNone => 'Только язык оригинала';

  @override
  String get libraryHubIntro =>
      'Единый раздел научных записей. У каждой записи указаны источник и статус проверки.';

  @override
  String get libraryStandards => 'Стандарты и официальные документы';

  @override
  String libraryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '1 запись',
      zero: 'Записей пока нет',
    );
    return '$_temp0';
  }

  @override
  String get libraryGroupScience => 'Научные записи';

  @override
  String get libraryGroupDocs => 'Документы и доказательства';

  @override
  String get standardsIntro =>
      'Стандарты, руководства и методики помечены по типу. Юридически обязательны только законы и нормативные акты — и только в своей юрисдикции.';

  @override
  String get researchFilterPeer => 'Только рецензируемые';

  @override
  String get researchFilterOpen => 'Открытый доступ';

  @override
  String get researchPeriodAll => 'Любой год';

  @override
  String get researchPeriodRecent => '2020 и позже';

  @override
  String get researchPeriod2010 => '2010–2019';

  @override
  String get researchPeriodOlder => 'До 2010';

  @override
  String get researchDisciplineAll => 'Все дисциплины';

  @override
  String get researchDiscipline => 'Дисциплина';

  @override
  String get researchPeriod => 'Период';

  @override
  String get researchClear => 'Сбросить фильтры';

  @override
  String get researchRelevance => 'Судебно-экспертная значимость';

  @override
  String get relevanceUnassessed =>
      'Ещё не оценена рецензентом (отдельно от уровня доказательности)';

  @override
  String get relevanceDirect => 'Прямая';

  @override
  String get relevanceSupporting => 'Вспомогательная';

  @override
  String get relevanceBackground => 'Фоновая';

  @override
  String get researchOpenAccess => 'Открытый доступ';

  @override
  String get researchOpenPmc => 'Да — PubMed Central';

  @override
  String get researchOpenLink => 'Да — бесплатная ссылка на полный текст';

  @override
  String get researchOpenUnknown => 'Не определено';

  @override
  String get researchDocKind => 'Тип документа';

  @override
  String get detailOnThisPage => 'На этой странице';

  @override
  String get detailNotYetSourced => 'Пока без источников';

  @override
  String get detailJurisdictionShort => 'Юрисдикция';

  @override
  String searchMetaboliteOf(String name) {
    return 'Метаболит: $name';
  }

  @override
  String get aiBlockedOfficial =>
      'Forensic AI не составляет официальные экспертные заключения, свидетельства о смерти и окончательные выводы об интоксикации. Он может помочь найти и сравнить источники.';

  @override
  String get aiJurisdictionRequired =>
      'Это правовой или процессуальный вопрос. Сначала выберите юрисдикцию — Forensic AI никогда не предполагает её сам.';

  @override
  String get aiSelectJurisdiction => 'Выбрать юрисдикцию';

  @override
  String get aiSectionEvidenceStatus => 'Статус доказательств';

  @override
  String get aiSampleEvidenceStatus =>
      'У каждого утверждения указаны статус проверки и уровень доказательности исходной записи.';

  @override
  String get aiSectionJurisdiction => 'Юрисдикция';

  @override
  String get aiSampleJurisdiction =>
      'Правовые утверждения относятся только к выбранной юрисдикции; научные — глобальны.';

  @override
  String get aiSectionRelated => 'Связанные записи';

  @override
  String get aiSampleRelated =>
      'Ссылки на записи о веществах, методах и исследованиях, использованные в ответе.';

  @override
  String get tpl_overview => 'Обзор';

  @override
  String get tpl_names => 'Названия и синонимы';

  @override
  String get tpl_classification => 'Классификация';

  @override
  String get tpl_metabolism => 'Метаболизм';

  @override
  String get tpl_metabolites => 'Метаболиты';

  @override
  String get tpl_specimens => 'Образцы';

  @override
  String get tpl_screening => 'Скрининг';

  @override
  String get tpl_confirmation => 'Подтверждающий анализ';

  @override
  String get tpl_analyticalMethods => 'Аналитические методы';

  @override
  String get tpl_reportedConcentrations => 'Сообщённые концентрации';

  @override
  String get tpl_interpretation => 'Интерпретация';

  @override
  String get tpl_postmortem => 'Посмертные аспекты';

  @override
  String get tpl_stability => 'Стабильность';

  @override
  String get tpl_interferences => 'Интерференции';

  @override
  String get tpl_jurisdiction => 'Право и методики юрисдикции';

  @override
  String get tpl_research => 'Исследования и доказательства';

  @override
  String get tpl_sources => 'Источники';

  @override
  String get tpl_principle => 'Принцип';

  @override
  String get tpl_forensicUse => 'Судебно-экспертное применение';

  @override
  String get tpl_samplePreparation => 'Пробоподготовка';

  @override
  String get tpl_instrumentation => 'Приборное оснащение';

  @override
  String get tpl_qualitativeQuantitative =>
      'Качественное / количественное применение';

  @override
  String get tpl_validation => 'Требования к валидации';

  @override
  String get tpl_interference => 'Интерференция';

  @override
  String get tpl_limitations => 'Ограничения';

  @override
  String get tpl_qc => 'Контроль качества';

  @override
  String get tpl_relatedSubstances => 'Связанные вещества';

  @override
  String get tpl_relatedReagents => 'Связанные реагенты';

  @override
  String get tpl_purpose => 'Назначение';

  @override
  String get tpl_composition => 'Состав';

  @override
  String get tpl_preparation => 'Приготовление';

  @override
  String get tpl_storageStability => 'Хранение и стабильность';

  @override
  String get tpl_safety => 'Безопасность';

  @override
  String get tpl_disposal => 'Утилизация';

  @override
  String get tpl_linkedMethods => 'Связанные методы и тесты';

  @override
  String get tpl_technology => 'Технология';

  @override
  String get tpl_targetSpecimen => 'Мишень и образец';

  @override
  String get tpl_cutoff => 'Порог отсечения (cutoff)';

  @override
  String get tpl_performance => 'Чувствительность и специфичность';

  @override
  String get tpl_crossReactivity => 'Перекрёстная реактивность';

  @override
  String get tpl_falseResults => 'Ложноположительные / ложноотрицательные';

  @override
  String get tpl_marker => 'Маркер';

  @override
  String get tpl_specimen => 'Образец';

  @override
  String get tpl_collectionContext => 'Условия забора';

  @override
  String get tpl_postmortemLimitations => 'Посмертные ограничения';

  @override
  String get tpl_analyticalMethod => 'Аналитический метод';

  @override
  String get tpl_interpretationLimitations => 'Ограничения интерпретации';

  @override
  String get tpl_definition => 'Определение';

  @override
  String get tpl_findings => 'Находки';

  @override
  String get tpl_methods => 'Методы';

  @override
  String templateCoverage(int filled, int total) {
    return 'Разделы с источниками: $filled из $total';
  }

  @override
  String get provWhereFrom => 'Откуда это утверждение?';

  @override
  String get provSheetTitle => 'Происхождение утверждения';

  @override
  String get provStatement => 'Утверждение';

  @override
  String provLocation(String loc) {
    return 'Место в источнике: $loc';
  }

  @override
  String get provSource => 'Источник';

  @override
  String provTier(String tier) {
    return 'Уровень источника $tier';
  }

  @override
  String get provTierA => 'A — официальный текст, стандарт или руководство';

  @override
  String get provTierB => 'B — рецензируемая публикация';

  @override
  String get provTierC => 'C — справочник, база данных или вторичный источник';

  @override
  String get reuseOpen => 'Открытое использование';

  @override
  String get reuseCiteOnly => 'Только ссылка — текст не воспроизводится';

  @override
  String get reuseNonCommercial => 'Некоммерческая лицензия';

  @override
  String get reuseLicenseRequired => 'ТРЕБУЕТСЯ ЛИЦЕНЗИЯ';

  @override
  String get reuseLookup => 'Только поиск';

  @override
  String get reuseUnknown => 'Лицензия не определена';

  @override
  String get srcLifecycleCurrent => 'Не отозван';

  @override
  String get srcLifecycleRetracted => 'ОТОЗВАН (RETRACTED)';

  @override
  String get srcLifecycleSuperseded => 'ЗАМЕНЁН';

  @override
  String get srcLifecycleWithdrawn => 'ОТОЗВАН АВТОРАМИ';

  @override
  String provCheckedOn(String date) {
    return 'Проверка на отзыв: $date';
  }

  @override
  String get provArchiveHash => 'SHA-256 архивной копии';

  @override
  String provSourceVersion(String v) {
    return 'Версия: $v';
  }

  @override
  String get provLifecycle => 'Жизненный цикл';

  @override
  String get lcCurrent => 'Актуально';

  @override
  String get lcNeedsReview => 'Требует проверки';

  @override
  String get lcOutdated => 'Устарело';

  @override
  String get lcSuperseded => 'Заменено';

  @override
  String get lcRetracted => 'Источник отозван';

  @override
  String get lcRejected => 'Отклонено';

  @override
  String get provHumanVerified => 'Проверено квалифицированными рецензентами';

  @override
  String get provNotVerified =>
      'ИНФОРМАЦИЯ НЕ ПРОВЕРЕНА — ТРЕБУЕТСЯ ПОДТВЕРЖДЕНИЕ ЭКСПЕРТА';

  @override
  String provRequiredRole(String role) {
    return 'Требуемый рецензент: $role';
  }

  @override
  String provReviewsRecorded(int n) {
    return 'Действий рецензентов по этой версии: $n';
  }

  @override
  String provClaimId(String id, int v) {
    return 'ID записи: $id · v$v';
  }

  @override
  String get roleForensicToxicology => 'Судебная токсикология';

  @override
  String get roleForensicMedicine => 'Судебная медицина';

  @override
  String get roleLaboratory => 'Лаборатория / аналитика';

  @override
  String get roleBiochemistry => 'Судебная биохимия';

  @override
  String get roleLegal => 'Право / юрисдикция';

  @override
  String get roleTranslation => 'Перевод';

  @override
  String get roleEditor => 'Научный редактор / администратор';

  @override
  String get bannerRetracted =>
      'Источник отозван — утверждение сохранено для прозрачности, но не является актуальным доказательством.';

  @override
  String get bannerSuperseded => 'Все источники этого утверждения заменены.';

  @override
  String get bannerOutdated => 'Отмечено рецензентом как устаревшее.';

  @override
  String get bannerConflict =>
      'ПРОТИВОРЕЧИЕ ДАННЫХ — источники расходятся или перекрываются. Нажмите, чтобы сравнить.';

  @override
  String get conflictsTitle => 'Противоречия данных';

  @override
  String get conflictsIntro =>
      'Противоречия показываются, а не скрываются. Разрешить их может только квалифицированный рецензент; приложение не выбирает «правильный» вариант.';

  @override
  String get conflictKindDirect => 'Прямое противоречие';

  @override
  String get conflictKindContext => 'Зависит от условий';

  @override
  String get conflictKindOverlap => 'Значения перекрываются между контекстами';

  @override
  String get conflictKindCharacterisation => 'Описано по-разному';

  @override
  String get conflictQuestion => 'Вопрос';

  @override
  String get conflictStatements => 'Утверждения';

  @override
  String get conflictStateOpen => 'Открыто — ожидает решения рецензента';

  @override
  String get conflictStateResolved => 'Разрешено рецензентом';

  @override
  String get conflictNoteLabel => 'Что говорят источники';

  @override
  String get ctxTitle => 'Контекст (только то, что указано в источнике)';

  @override
  String get ctxSpecimen => 'Образец';

  @override
  String get ctxSampling => 'Забор';

  @override
  String get ctxSubject => 'Субъект';

  @override
  String get ctxPopulation => 'Популяция';

  @override
  String get ctxStudySize => 'Число случаев';

  @override
  String get ctxCaseType => 'Тип случаев';

  @override
  String get ctxCoIntoxicants => 'Сопутствующие вещества';

  @override
  String get ctxMethod => 'Аналитический метод';

  @override
  String get ctxTiming => 'Время забора';

  @override
  String get ctxStatistic => 'Приведённые значения';

  @override
  String get ctxReporting => 'Происхождение данных';

  @override
  String get ctxLimitations => 'Ограничения';

  @override
  String get ctxNotStated => 'не указано в источнике';

  @override
  String get ctxPostmortem => 'посмертно';

  @override
  String get ctxAntemortem => 'прижизненно';

  @override
  String get ctxMixed => 'смешанно';

  @override
  String get ctxDeceased => 'умершие';

  @override
  String get ctxLiving => 'живые';

  @override
  String get ctxPrimary => 'Первичные данные цитируемого исследования';

  @override
  String get ctxSecondary => 'Цитируется из другого исследования';

  @override
  String get ctxNotAssessed => 'Ещё не оценено';

  @override
  String get ctxAutoMinimal =>
      'Проверенные контекстные данные для этой записи пока отсутствуют.';

  @override
  String get metRelationsTitle => 'Метаболиты (связи с источниками)';

  @override
  String get metKindMetabolite => 'Метаболит';

  @override
  String get metKindActive => 'Активный метаболит';

  @override
  String get metKindInactive => 'Неактивный метаболит';

  @override
  String get metKindMarker => 'Маркер';

  @override
  String get metKindArtifact => 'Артефакт';

  @override
  String get metRoleNote =>
      'Роль (активный, маркер…) указывается, только если она прямо указана в источнике.';

  @override
  String metParentOf(String name) {
    return 'Исходное вещество: $name';
  }

  @override
  String get specimensTitle => 'Образцы';

  @override
  String get specimensIntro =>
      'Типы образцов с утверждениями из источников и приведёнными значениями. Приведённые значения не являются порогами.';

  @override
  String get specimenAbout => 'Об образце';

  @override
  String get specimenMeasured => 'Приведённые значения в этом образце';

  @override
  String get specimenNoClaims => 'Пока нет утверждений из источников.';

  @override
  String get specimenCatFluid => 'Биологическая жидкость';

  @override
  String get specimenCatTissue => 'Ткань';

  @override
  String get specimenCatKeratinous => 'Кератиновая матрица';

  @override
  String get specimenCatContent => 'Содержимое';

  @override
  String specimenRecords(int n) {
    return '$n записей';
  }

  @override
  String get detailMeasuredIn => 'Образцы с приведёнными значениями';

  @override
  String get detailScreenedBy =>
      'Скрининговые тесты (скрининг ≠ подтверждение)';

  @override
  String get chainTitle => 'Цепочка знаний';

  @override
  String get chainOpen => 'Показать цепочку знаний';

  @override
  String get chainIntro =>
      'У каждой связи ниже есть основание (утверждение из источника, запись официального списка или каталога). Нажмите на связь, чтобы увидеть его.';

  @override
  String get chainMetabolites => 'Метаболиты';

  @override
  String get chainSpecimens => 'Образцы';

  @override
  String get chainScreening => 'Скрининг';

  @override
  String get chainConfirmation => 'Подтверждающие методы';

  @override
  String get chainReagents => 'Реагенты';

  @override
  String get chainResearch => 'Исследования';

  @override
  String get chainStandards => 'Стандарты';

  @override
  String get chainLegal => 'Правовой статус';

  @override
  String get chainNone => 'Пока нет связи с источником';

  @override
  String chainBasis(String id) {
    return 'Основание: $id';
  }

  @override
  String chainResearchCount(int n) {
    return 'Связанных публикаций: $n';
  }

  @override
  String get stdCatalogue => 'Каталог стандартов (только метаданные)';

  @override
  String get stdStatusCurrent => 'Действующий';

  @override
  String get stdStatusProposed => 'Проект — ещё не опубликован';

  @override
  String stdStatusSuperseded(String id) {
    return 'Заменён: $id';
  }

  @override
  String get stdStatusWithdrawn => 'Отменён';

  @override
  String get stdStatusUnknown => 'Статус не определён';

  @override
  String stdVerifiedFrom(String date) {
    return 'Метаданные проверены $date у издателя или в реестре';
  }

  @override
  String get stdTextNotReproduced =>
      'Текст стандарта в приложении не воспроизводится.';

  @override
  String get reviewTitle => 'Статус научной проверки';

  @override
  String get reviewHumanVerified => 'Проверено людьми';

  @override
  String get reviewReviewed => 'Проверено одним рецензентом';

  @override
  String get reviewAwaiting => 'Ожидают проверки';

  @override
  String get reviewRetracted => 'Утверждения с отозванным источником';

  @override
  String get reviewActions => 'Записанных действий рецензентов';

  @override
  String get reviewReviewers => 'Зарегистрированных рецензентов';

  @override
  String get reviewOpenConflicts => 'Открытых противоречий данных';

  @override
  String get reviewExplain =>
      'Утверждение становится VERIFIED только после одобрения текущей версии двумя независимыми квалифицированными рецензентами по специальности. Приложение и его авторы не могут сами отметить что-либо как проверенное.';

  @override
  String get reviewRolesTitle => 'Роли и права рецензентов';

  @override
  String get reviewRoleApprove =>
      'Может одобрять или отклонять в своей специальности';

  @override
  String get reviewRoleFlagOnly =>
      'Может отмечать противоречия, устаревание и запрашивать изменения — не может одобрять';

  @override
  String get reviewActionsList => 'Возможные действия';

  @override
  String get libraryConflicts => 'Противоречия данных';

  @override
  String get libraryReview => 'Статус проверки';

  @override
  String get methodPublishedNote =>
      'Опубликованный научный метод — не валидированная методика для конкретной лаборатории.';

  @override
  String get reagentConcentration => 'Концентрация';

  @override
  String get reagentSolvent => 'Растворитель';

  @override
  String get reagentPh => 'pH';

  @override
  String get reagentExpiry => 'Срок годности';

  @override
  String get reagentPpe => 'Средства индивидуальной защиты';

  @override
  String get screeningResultType =>
      'Тип результата (качественный / полуколичественный)';

  @override
  String get screeningDetectionWindow =>
      'Окно обнаружения (зависит от условий)';

  @override
  String get screeningInterference => 'Интерференция';

  @override
  String get evInternationalStandard => 'Международный стандарт';

  @override
  String get evGuideline => 'Руководство';

  @override
  String get evPublishedValidated => 'Опубликованный валидированный метод';

  @override
  String get evNationalMethod => 'Национальная методика';

  @override
  String get evLocalSop => 'Ссылка на локальную СОП';

  @override
  String get evEducationalSummary => 'Учебное обобщение';

  @override
  String get disciplineSourcedTopics => 'Темы с источниками';

  @override
  String get aiRagAnswer => 'Ответ';

  @override
  String get aiRagJurisdictionNotApplicable =>
      'Не правовой вопрос — юрисдикция не применяется';

  @override
  String get aiLimNotVerified =>
      'Данные ещё не проверены квалифицированными рецензентами.';

  @override
  String get aiLimConflict =>
      'Источники расходятся или перекрываются — см. ПРОТИВОРЕЧИЕ ДАННЫХ.';

  @override
  String aiLimRetracted(int n) {
    return 'Исключено утверждений из отозванных или заменённых источников: $n.';
  }

  @override
  String get aiLimExpert =>
      'Интерпретация конкретного случая требует квалифицированного эксперта.';

  @override
  String get aiLimMock =>
      'Демонстрационный провайдер — реальный ответ ИИ не сформирован.';

  @override
  String get instrOriginalTitle => 'Оригинальное название';

  @override
  String legalMissingFields(String fields) {
    return 'Для этого документа не указано: $fields';
  }

  @override
  String get lfOfficialTitle => 'Официальное название';

  @override
  String get lfOriginalTitle => 'Название на языке оригинала';

  @override
  String get lfArticle => 'Статья / раздел';

  @override
  String get lfOfficialUrl => 'Официальная ссылка';

  @override
  String get lfReviewStatus => 'Статус проверки';

  @override
  String get legalDomainsTitle => 'Правовые области';

  @override
  String legalDomainRecords(int n) {
    return 'Записей: $n';
  }

  @override
  String get legalDomainNoContent => 'Нет проверенного содержания';

  @override
  String get compareTopicControlStatus => 'Статус контроля';

  @override
  String get ldExpertStatus => 'Статус судебного эксперта';

  @override
  String get ldEvidenceHandling => 'Обращение с доказательствами';

  @override
  String get ldChainOfCustody => 'Цепочка хранения';

  @override
  String get ldSpecimenCollection => 'Отбор образцов';

  @override
  String get ldDeathInvestigation => 'Расследование смерти';

  @override
  String get ldAutopsy => 'Вскрытие';

  @override
  String get ldToxicology => 'Токсикология';

  @override
  String get ldAlcoholDriving => 'Алкоголь и вождение';

  @override
  String get ldControlledSubstances => 'Контролируемые вещества';

  @override
  String get ldReporting => 'Отчётность';

  @override
  String get ldLaboratoryStandards => 'Лабораторные стандарты';

  @override
  String get ldRetentionStorage => 'Хранение';

  @override
  String get ldTestimony => 'Показания в суде';

  @override
  String get ldQualityAccreditation => 'Качество и аккредитация';

  @override
  String get deleteLocalData => 'Удалить данные на этом устройстве';

  @override
  String get deleteLocalDataBody =>
      'Закладки, история поиска, недавно просмотренные записи и прогресс уроков будут удалены только с этого устройства. Научная база, аккаунт и подписки в магазине не затрагиваются — для удаления аккаунта используйте «Удалить аккаунт».';

  @override
  String get deleteLocalDataConfirm => 'Удалить';

  @override
  String get deleteLocalDataDone => 'Локальные данные удалены';

  @override
  String get tierStudentPro => 'Student Pro';

  @override
  String get tierProfessionalPro => 'Professional Pro';

  @override
  String get tierInstitution => 'Организация';

  @override
  String get tierCurrent => 'Текущий тариф';

  @override
  String get tierFreeF1 =>
      'Офлайн научная база с предупреждениями и источниками';

  @override
  String get tierFreeF2 => 'Поиск и избранные справочные записи';

  @override
  String get tierFreeF3 => 'Основные калькуляторы';

  @override
  String get tierStudentF1 =>
      'Полный справочник: вещества, методы, реактивы, судебная медицина, стандарты, юрисдикции';

  @override
  String get tierStudentF2 =>
      'Все курсы, тесты, карточки и подготовка к экзамену';

  @override
  String get tierStudentF3 => 'Поиск без ограничения результатов';

  @override
  String get tierProF1 => 'Всё из Student Pro';

  @override
  String get tierProF2 =>
      'Профессиональные калькуляторы и лабораторные инструменты';

  @override
  String get tierProF3 =>
      'Аналитические методы, исследования и инструменты доказательств';

  @override
  String get tierProF4 =>
      'Профессиональные функции ИИ — после подключения ИИ-сервиса';

  @override
  String get periodMonthly => 'Ежемесячно';

  @override
  String get periodYearly => 'Ежегодно';

  @override
  String get periodUnknown => 'Подписка';

  @override
  String offerPriceLine(String price, String period) {
    return '$price · $period';
  }

  @override
  String get offerSubscribe => 'Оформить подписку';

  @override
  String get offerPriceFromStore => 'Цену показывает App Store / Google Play';

  @override
  String get subscriptionTerms =>
      'Подписка продлевается автоматически, пока вы её не отмените. Оплата списывается с аккаунта App Store / Google Play. Отменить можно не позднее чем за 24 часа до конца периода в настройках аккаунта магазина.';

  @override
  String get manageSubscription => 'Управлять подпиской';

  @override
  String get manageSubscriptionFailed =>
      'Не удалось открыть настройки подписки в магазине.';

  @override
  String get planLabel => 'Тариф';

  @override
  String get subscriptionStateLabel => 'Статус подписки';

  @override
  String get stActive => 'Активна';

  @override
  String get stExpired => 'Истекла';

  @override
  String get stGrace => 'Проблема с оплатой — льготный период';

  @override
  String get stBillingRetry => 'Проблема с оплатой — доступ приостановлен';

  @override
  String stCancelled(String date) {
    return 'Отменена — действует до $date';
  }

  @override
  String get stCancelledNoDate => 'Отменена — действует до конца периода';

  @override
  String get stRevoked => 'Отозвана магазином';

  @override
  String get stUnknown => 'Статус неизвестен';

  @override
  String get stNone => 'Нет подписки';

  @override
  String stRenewsOn(String date) {
    return 'Продление или окончание: $date';
  }

  @override
  String get accountOptionalNote =>
      'Аккаунт необязателен. Офлайн-справочник работает без входа; аккаунт нужен только для облачных сервисов.';

  @override
  String get accountNotConnected =>
      'В этой сборке сервис аккаунтов ещё не подключён. Все офлайн-функции доступны.';

  @override
  String get accountTestBackend =>
      'ТЕСТОВЫЙ сервер аккаунтов — реальные письма не отправляются, данные хранятся только в памяти.';

  @override
  String get accountSignIn => 'Войти';

  @override
  String get accountCreate => 'Создать аккаунт';

  @override
  String get accountSignOut => 'Выйти';

  @override
  String get accountSignedOut => 'Вы вышли из аккаунта';

  @override
  String get accountEmail => 'Эл. почта';

  @override
  String get accountPassword => 'Пароль';

  @override
  String get accountConfirmPassword => 'Повторите пароль';

  @override
  String get accountShowPassword => 'Показать пароль';

  @override
  String get accountHidePassword => 'Скрыть пароль';

  @override
  String get accountVerified => 'Почта подтверждена';

  @override
  String get accountNotVerified => 'Почта не подтверждена';

  @override
  String get accountVerifyNow => 'Подтвердить почту';

  @override
  String get accountTermsAccept =>
      'Я принимаю Условия использования и Политику конфиденциальности';

  @override
  String get accountMinimalData =>
      'Мы запрашиваем только эл. почту. Профессиональные, служебные и личные данные не собираются.';

  @override
  String get passwordRulesTitle => 'Требования к паролю';

  @override
  String pwRuleMinLength(int n) {
    return 'Не менее $n символов';
  }

  @override
  String get pwRuleLetter => 'Хотя бы одна буква';

  @override
  String get pwRuleDigit => 'Хотя бы одна цифра';

  @override
  String get pwRuleNotEmail => 'Не совпадает с эл. почтой';

  @override
  String get accountForgot => 'Забыли пароль?';

  @override
  String get accountNoAccount => 'Нет аккаунта? Создайте';

  @override
  String get accountHaveAccount => 'Уже есть аккаунт? Войдите';

  @override
  String get verifyTitle => 'Подтвердите эл. почту';

  @override
  String verifyBody(int n, String email) {
    return 'Мы отправили $n-значный код на $email. Введите его ниже, чтобы активировать аккаунт.';
  }

  @override
  String get verifyCode => 'Код подтверждения';

  @override
  String get verifySubmit => 'Подтвердить';

  @override
  String get verifyResend => 'Отправить новый код';

  @override
  String get verifyResent =>
      'Если аккаунт требует подтверждения, новый код отправлен.';

  @override
  String get verifyDone => 'Почта подтверждена. Аккаунт активен.';

  @override
  String get forgotTitle => 'Сброс пароля';

  @override
  String get forgotBody =>
      'Введите эл. почту аккаунта. Если аккаунт существует, мы отправим код сброса.';

  @override
  String get forgotSubmit => 'Отправить код сброса';

  @override
  String forgotSent(int minutes) {
    return 'Если для этой почты есть аккаунт, код сброса отправлен. Он действует $minutes минут.';
  }

  @override
  String get resetTitle => 'Новый пароль';

  @override
  String get resetCode => 'Код сброса';

  @override
  String get resetNewPassword => 'Новый пароль';

  @override
  String get resetSubmit => 'Сохранить новый пароль';

  @override
  String get resetDone => 'Пароль изменён. Войдите с новым паролем.';

  @override
  String get authErrInvalidEmail => 'Введите корректный адрес эл. почты.';

  @override
  String get authErrWeakPassword => 'Пароль не соответствует требованиям.';

  @override
  String get authErrMismatch => 'Пароли не совпадают.';

  @override
  String get authErrTerms =>
      'Примите Условия использования и Политику конфиденциальности.';

  @override
  String get authErrCredentials => 'Неверная эл. почта или пароль.';

  @override
  String get authErrNotVerified =>
      'Почта ещё не подтверждена. Введите отправленный код.';

  @override
  String get authErrCodeInvalid => 'Неверный код.';

  @override
  String get authErrCodeExpired => 'Срок действия кода истёк. Запросите новый.';

  @override
  String get authErrAlreadyVerified =>
      'Эта почта уже подтверждена. Можно войти.';

  @override
  String get authErrTooMany =>
      'Слишком много попыток. Подождите минуту и повторите.';

  @override
  String get authErrOffline =>
      'Нет подключения к интернету. Офлайн-функции продолжают работать.';

  @override
  String get authErrServer =>
      'Сервис аккаунтов временно недоступен. Повторите позже.';

  @override
  String get authErrNotConfigured =>
      'Сервис аккаунтов в этой сборке ещё не подключён.';

  @override
  String get authErrRecentLogin =>
      'Неверный пароль. Подтвердите текущий пароль, чтобы продолжить.';

  @override
  String get authErrNotSignedIn => 'Сначала войдите в аккаунт.';

  @override
  String get deleteAccountTitle => 'Удаление аккаунта';

  @override
  String get deleteAccountBody =>
      'Аккаунт и связанные с ним данные на наших серверах (эл. почта, сессии входа, синхронизированные данные, записи о правах) будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get deleteAccountStoreNote =>
      'Удаление аккаунта не отменяет подписку App Store / Google Play. Отмените её в настройках аккаунта магазина, чтобы прекратить списания.';

  @override
  String get deleteAccountLocalNote =>
      'Данные на этом устройстве (закладки, история) удаляются отдельно: «Удалить данные на этом устройстве».';

  @override
  String get deleteAccountUnderstand => 'Я понимаю, что это нельзя отменить';

  @override
  String get deleteAccountPassword => 'Текущий пароль';

  @override
  String get deleteAccountConfirm => 'Удалить аккаунт навсегда';

  @override
  String get deleteAccountFinalTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountDone => 'Аккаунт удалён.';

  @override
  String get aiDisclaimerLink => 'Оговорка об ИИ';

  @override
  String get aiDisclaimerBody =>
      'Ответы Forensic AI формируются на основе локального содержимого приложения со ссылками на источники и не являются экспертным заключением. Они могут быть неполными или ошибочными, не проверены квалифицированным рецензентом и не должны быть единственным основанием для экспертного вывода, правового решения или лечения. Всегда проверяйте указанные источники и консультируйтесь с квалифицированным экспертом.';

  @override
  String get accountSection => 'Аккаунт';

  @override
  String get subscriptionSection => 'Подписка';

  @override
  String get availNoDataTitle => 'Записей пока нет';

  @override
  String get availNoDataBody =>
      'В установленной научной базе для этого раздела записей нет.';

  @override
  String get availFilterTitle => 'По выбранному фильтру ничего не найдено';

  @override
  String get availFilterBody =>
      'Нет проверенных записей, соответствующих фильтру. Сбросьте фильтр или выполните поиск по всей базе.';

  @override
  String get availNotConnectedTitle => 'Недоступно в этой версии';

  @override
  String get availNotConnectedBody =>
      'Для этой функции нужен онлайн-сервис, который в этой версии не подключён. Все офлайн-функции продолжают работать.';

  @override
  String get availServiceTitle => 'Сервис временно недоступен';

  @override
  String get availServiceBody =>
      'Проверьте подключение и повторите позже. Офлайн-функции продолжают работать.';

  @override
  String get availClearFilters => 'Сбросить фильтры';

  @override
  String get availBrowseAll => 'Все записи';

  @override
  String get availSearch => 'Поиск';

  @override
  String get aiStatusPreview => 'Предпросмотр · не подключён';

  @override
  String get aiPreviewPoint1 => 'Этот экран — предпросмотр интерфейса.';

  @override
  String get aiPreviewPoint2 =>
      'Рабочий ИИ-сервис не подключён, поэтому ответ ИИ не формируется.';

  @override
  String get aiPreviewPoint3 =>
      'Пример ответа ниже — только демонстрация структуры.';

  @override
  String get aiPreviewPoint4 =>
      '«Найти источники офлайн» ищет в локальной базе и работает уже сейчас.';

  @override
  String get aiSendUnavailable =>
      'Отправка недоступна, пока ИИ-сервис не подключён.';

  @override
  String get concWarning =>
      'Это значение получено из отдельного случая или исследования. Его нельзя трактовать как универсальный токсический, смертельный, терапевтический или правовой порог.';

  @override
  String get concTitle => 'Сообщаемая концентрация';

  @override
  String get concSubstance => 'Вещество';

  @override
  String get concValue => 'Значение и единица';

  @override
  String get concValueInQuote => 'Как приведено в источнике (см. цитату)';

  @override
  String get concLivingPostmortem => 'Прижизненно / посмертно';

  @override
  String get concSourceType => 'Тип источника';

  @override
  String get concSectionCase => 'Описание случая';

  @override
  String get concSectionAbstract => 'Аннотация';

  @override
  String get concSectionIntro => 'Введение (обзор)';

  @override
  String get concSectionResults => 'Результаты';

  @override
  String get concSectionDiscussion => 'Обсуждение';

  @override
  String get concStudyContext => 'Контекст случая / исследования';

  @override
  String get concEvidenceLevel => 'Уровень доказательности';

  @override
  String get concReviewStatus => 'Статус проверки';

  @override
  String get concSource => 'Источник';

  @override
  String get concNotAvailable => 'Нет данных';

  @override
  String get concExcerpt => 'Цитата из источника';

  @override
  String get calcStatusTitle => 'Статус';

  @override
  String get calcEngineLabel => 'Расчётный модуль';

  @override
  String get calcEngineTested =>
      'Проверен автоматическими программными тестами — это не научная экспертиза';

  @override
  String get calcEngineChip => 'Модуль протестирован';

  @override
  String get calcReferenceLabel => 'Источник формулы';

  @override
  String get calcInterpretationLabel => 'Интерпретация';

  @override
  String get calcInterpretationValue =>
      'Зависит от контекста — требует профессиональной оценки';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get homeHeaderSubtitle => 'Справочник судебной экспертизы';

  @override
  String get modeRoleTitle => 'Ваша роль (необязательно)';

  @override
  String get modeProfessionalNotVerified =>
      'Выбор режима «Специалист» не означает, что ваш профессиональный статус подтверждён.';

  @override
  String get modeSwitchNote =>
      'Режим использования меняет только устройство приложения. Он не даёт и не отменяет профессиональное подтверждение.';

  @override
  String get roleStudent => 'Студент';

  @override
  String get roleResident => 'Ординатор / стажёр';

  @override
  String get roleResearcher => 'Исследователь / обучающийся';

  @override
  String get roleForensicExpert => 'Судебный эксперт';

  @override
  String get roleForensicPhysician => 'Судебно-медицинский эксперт';

  @override
  String get roleForensicToxicologist => 'Судебный токсиколог';

  @override
  String get roleForensicChemist => 'Судебный химик';

  @override
  String get roleLaboratorySpecialist => 'Специалист лаборатории';

  @override
  String get rolePathologist => 'Патологоанатом';

  @override
  String get roleGeneticist => 'Генетик / специалист по ДНК';

  @override
  String get roleForensicBiochemist => 'Судебный биохимик';

  @override
  String get roleAnthropologist => 'Судебный антрополог';

  @override
  String get roleOdontologist => 'Судебный одонтолог';

  @override
  String get roleOtherProfessional =>
      'Другой специалист судебной экспертизы / лаборатории';

  @override
  String get specForensicMedicine => 'Судебная медицина';

  @override
  String get specForensicToxicology => 'Судебная токсикология';

  @override
  String get specForensicChemistry => 'Судебная химия';

  @override
  String get specAnalyticalLaboratory => 'Аналитическая / лабораторная наука';

  @override
  String get specForensicBiochemistry => 'Судебная биохимия';

  @override
  String get specPathologyHistology => 'Патология / гистология';

  @override
  String get specGeneticsDna => 'Генетика / ДНК';

  @override
  String get specForensicAnthropology => 'Судебная антропология';

  @override
  String get specForensicOdontology => 'Судебная одонтология';

  @override
  String get specForensicRadiology => 'Судебная радиология';

  @override
  String get specForensicPsychology => 'Судебная психология / психиатрия';

  @override
  String get specForensicBiology => 'Судебная биология';

  @override
  String get specEntomology => 'Судебная энтомология';

  @override
  String get specOther => 'Другое';

  @override
  String get scopeLegal => 'Право и юрисдикция';

  @override
  String get scopeTranslation => 'Перевод';

  @override
  String get studyBachelor => 'Бакалавриат';

  @override
  String get studyMaster => 'Магистратура';

  @override
  String get studyResidency => 'Ординатура';

  @override
  String get studyDoctoral => 'Докторантура';

  @override
  String get studyOther => 'Другое';

  @override
  String get accountChoiceTitle => 'Пользуйтесь приложением без учётной записи';

  @override
  String get accountChoiceSubtitle =>
      'Офлайн-база, поиск и калькуляторы работают без учётной записи. Она нужна только для облачных функций.';

  @override
  String get accountContinueWithout => 'Продолжить без учётной записи';

  @override
  String get accountContinueWithoutNote =>
      'Учётную запись можно создать позже в профиле.';

  @override
  String get accountCreateOrSignIn => 'Создать учётную запись / Войти';

  @override
  String get accountCloudUnavailable =>
      'Облачный сервис учётных записей в этой версии не подключён. Всё офлайн продолжает работать.';

  @override
  String get accountNeededFor => 'Учётная запись нужна для';

  @override
  String get accountNeedVerification => 'Профессионального подтверждения';

  @override
  String get accountNeedReviews =>
      'Профессиональных рецензий научных материалов';

  @override
  String get accountNeedSync => 'Синхронизации между устройствами';

  @override
  String get accountNeedSubscriptions => 'Подписок на нескольких устройствах';

  @override
  String get accountNeedCloudAi => 'Облачного ИИ (после подключения)';

  @override
  String get accountNeedInstitution => 'Функций для организаций';

  @override
  String get accountFillProfile => 'Заполнить профиль сейчас (необязательно)';

  @override
  String get profileLocalOnlyNote =>
      'Данные профиля хранятся только на этом устройстве и никуда не отправляются.';

  @override
  String get profileStudentTitle => 'Профиль студента';

  @override
  String get profileProTitle => 'Профиль специалиста';

  @override
  String get profileSaved => 'Профиль сохранён на этом устройстве';

  @override
  String get profileSectionIdentity => 'Личные данные';

  @override
  String get profileSectionWork => 'Профессиональные данные';

  @override
  String get profileSectionOptional => 'Необязательно';

  @override
  String get profileStudentCannotReview =>
      'Профиль студента предназначен для обучения: он не может подтверждать научные материалы или выполнять квалифицированные рецензии.';

  @override
  String get fieldFullName => 'ФИО';

  @override
  String get fieldCountry => 'Страна';

  @override
  String get fieldCountryChoose => 'Выберите страну';

  @override
  String get fieldCountrySearch => 'Поиск страны';

  @override
  String get fieldCity => 'Город / регион (необязательно)';

  @override
  String get fieldInstitution => 'Вуз / учреждение (необязательно)';

  @override
  String get fieldFaculty => 'Факультет / программа (необязательно)';

  @override
  String get fieldStudyLevel => 'Уровень обучения (необязательно)';

  @override
  String get fieldInterests => 'Области интересов';

  @override
  String get fieldOrganization => 'Организация / учреждение';

  @override
  String get fieldPosition => 'Должность';

  @override
  String get fieldPrimarySpecialty => 'Основная специальность';

  @override
  String get fieldAdditionalSpecialties => 'Дополнительные специальности';

  @override
  String get fieldYearsExperience => 'Стаж работы (лет)';

  @override
  String get fieldEducation => 'Образование / квалификация';

  @override
  String get fieldWorkEmail => 'Рабочий e-mail (необязательно)';

  @override
  String get fieldPrivateHelper =>
      'Не публикуется — не отображается в открытом профиле.';

  @override
  String get fieldLicense => 'Номер регистрации / лицензии (необязательно)';

  @override
  String get fieldLicenseHelper =>
      'Только если в вашей стране он выдаётся. Не публикуется.';

  @override
  String get fieldBio => 'Краткая профессиональная биография (необязательно)';

  @override
  String get fieldLanguages => 'Языки (через запятую)';

  @override
  String get fieldProInterests => 'Профессиональные интересы (необязательно)';

  @override
  String get fieldShowOrganization =>
      'Показывать организацию в открытом профиле';

  @override
  String get fieldShowOrganizationHelper =>
      'По умолчанию выключено. Имя, специальность и страна публикуются только после подтверждения.';

  @override
  String get formRequired => 'Обязательное поле';

  @override
  String get formTooLong => 'Слишком длинно';

  @override
  String get formInvalid => 'Недопустимое значение';

  @override
  String get formHasErrors => 'Исправьте отмеченные поля.';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionRemove => 'Удалить';

  @override
  String get verifTitle => 'Профессиональное подтверждение';

  @override
  String get verifStatusLabel => 'Текущий статус';

  @override
  String get verifUnverified => 'Не подтверждён';

  @override
  String get verifPending => 'Ожидает проверки';

  @override
  String get verifVerified => 'Подтверждённый специалист';

  @override
  String get verifChangesRequested => 'Нужны дополнительные сведения';

  @override
  String get verifRejected => 'Отклонено';

  @override
  String get verifSuspended => 'Временно приостановлено';

  @override
  String get verifUnverifiedBody =>
      'Вы не подавали заявку на подтверждение. Все офлайн-функции доступны и без него.';

  @override
  String get verifPendingBody =>
      'Ваша заявка ожидает проверки уполномоченным сотрудником.';

  @override
  String get verifVerifiedBody =>
      'Ваш профессиональный статус подтверждён уполномоченным сотрудником. Право рецензирования выдаётся отдельно по каждой специальности.';

  @override
  String get verifChangesBody =>
      'Нужны дополнительные сведения. Обновите профиль или документы и отправьте заявку повторно.';

  @override
  String get verifRejectedBody =>
      'Заявка не одобрена. Вы можете подать новую заявку.';

  @override
  String get verifSuspendedBody =>
      'Подтверждение временно приостановлено. Право рецензирования не действует.';

  @override
  String get verifServiceNotConnected =>
      'Сервис подтверждения в этой версии не подключён. Заявки пока нельзя отправить, и никто не может быть подтверждён.';

  @override
  String get verifHowTitle => 'Как проходит подтверждение';

  @override
  String get verifStep1 => 'Заполните профиль специалиста.';

  @override
  String get verifStep2 =>
      'При желании приложите документ о квалификации (хранится закрыто).';

  @override
  String get verifStep3 =>
      'Уполномоченный администратор или подтверждённый специалист той же области вручную проверяет заявку и документ. Самоподтверждение невозможно.';

  @override
  String get verifStep4 =>
      'Право рецензирования выдаётся отдельно по каждой специальности.';

  @override
  String get verifHumanOnly =>
      'Выбор режима «Специалист», указание должности, загрузка сертификата или автоматическая/ИИ-проверка никогда не дают статус подтверждённого специалиста. Документ — лишь доказательство; статус присваивается только после ручной проверки, при этом фиксируется, кто подтвердил, когда, какой документ проверен и по какой специальности.';

  @override
  String get verifApplication => 'Заявка';

  @override
  String get verifProfileMissing => 'Профиль специалиста не заполнен';

  @override
  String get verifSubmit => 'Отправить заявку';

  @override
  String get verifSubmitted => 'Заявка отправлена. Статус: ожидает проверки.';

  @override
  String get verifSubmitUnavailable =>
      'Отправка недоступна, пока сервис подтверждения не подключён.';

  @override
  String get verifSubmitNote =>
      'Заявка и документы передаются по зашифрованному каналу в закрытое хранилище.';

  @override
  String proYearsExperience(int years) {
    return 'Стаж: $years лет';
  }

  @override
  String proReviewCount(int count) {
    return 'Рецензий: $count';
  }

  @override
  String get proServiceNotConnected =>
      'Облачный сервис в этой версии не подключён.';

  @override
  String get proInvalidInput => 'Проверьте введённые данные.';

  @override
  String get proOffline => 'Нет подключения к интернету.';

  @override
  String get proServerError => 'Сервис временно недоступен. Повторите позже.';

  @override
  String get credUploadTitle => 'Загрузить документ о квалификации';

  @override
  String get credOptional => 'Необязательно';

  @override
  String credSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count файлов',
      few: 'Выбрано $count файла',
      one: 'Выбран $count файл',
    );
    return '$_temp0';
  }

  @override
  String get credIntro =>
      'Документ необязателен и лишь помогает уполномоченному сотруднику проверить заявку. Сам по себе он не даёт статус подтверждённого специалиста.';

  @override
  String get credPrivacy =>
      'Документы конфиденциальны: они никогда не публикуются, не имеют открытой ссылки, их содержимое не записывается в журналы. Открыть их может только уполномоченный проверяющий.';

  @override
  String get credNoCaseData =>
      'Не загружайте материалы дел, вещественные доказательства, заключения или любые конфиденциальные документы по делам. Паспорт и удостоверение личности не требуются.';

  @override
  String get credKindTitle => 'Тип документа';

  @override
  String get credProfessionalCertificate => 'Профессиональный сертификат';

  @override
  String get credQualificationCertificate => 'Свидетельство о квалификации';

  @override
  String get credDiploma => 'Диплом';

  @override
  String get credEmployment => 'Подтверждение места работы / назначения';

  @override
  String get credRegistration => 'Документ о регистрации / лицензии';

  @override
  String get credTraining => 'Сертификат признанного обучения';

  @override
  String get credFormats =>
      'PDF, JPG или PNG, до 10 МБ на файл, не более 5 файлов.';

  @override
  String get credChooseFile => 'Выбрать файл';

  @override
  String get credSelectedTitle => 'Выбранные документы';

  @override
  String get credNotUploaded =>
      'Не загружено: сервис подтверждения не подключён. Файлы остаются только в памяти устройства и удаляются при закрытии приложения.';

  @override
  String get credWillSendOnSubmit =>
      'Файлы будут отправлены конфиденциально вместе с заявкой.';

  @override
  String get credPickFailed => 'Не удалось открыть файл.';

  @override
  String get credErrorEmpty => 'Файл пуст.';

  @override
  String get credErrorTooLarge => 'Файл больше 10 МБ.';

  @override
  String get credErrorType => 'Принимаются только файлы PDF, JPG и PNG.';

  @override
  String get credErrorTooMany => 'Не более 5 файлов.';

  @override
  String get reviewSectionTitle => 'Рецензия специалиста';

  @override
  String get reviewEmpty =>
      'Этот материал ещё не рецензирован квалифицированным специалистом.';

  @override
  String get reviewWhoCanReview =>
      'Рецензировать этот материал могут только подтверждённые специалисты с правом рецензирования в соответствующей области.';

  @override
  String get reviewScopeNotAssigned =>
      'Для этой записи ещё не назначена область рецензирования.';

  @override
  String get reviewWrite => 'Написать рецензию';

  @override
  String get reviewDecision => 'Решение';

  @override
  String get reviewActApprove => 'Одобрить';

  @override
  String get reviewActRequestChange => 'Запросить исправление';

  @override
  String get reviewActConflict => 'Отметить противоречие данных';

  @override
  String get reviewActOutdated => 'Отметить как устаревшее';

  @override
  String get reviewActReject => 'Отклонить';

  @override
  String get reviewDecApprove => 'Одобрено';

  @override
  String get reviewDecRequestChange => 'Требуется исправление';

  @override
  String get reviewDecConflict => 'Противоречие данных';

  @override
  String get reviewDecOutdated => 'Устарело';

  @override
  String get reviewDecReject => 'Отклонено';

  @override
  String get reviewStateInProgress => 'Идёт рецензирование';

  @override
  String get reviewStateProfessional => 'Рецензировано специалистом';

  @override
  String get reviewStateHumanVerified => 'Научно подтверждено людьми';

  @override
  String get reviewStateReReview => 'Требуется повторная рецензия';

  @override
  String get reviewNote => 'Текст рецензии';

  @override
  String get reviewNoteHelper =>
      'Обоснуйте решение со ссылкой на данные. Не менее 20 символов.';

  @override
  String get reviewNoteTooShort => 'Нужно не менее 20 символов.';

  @override
  String get reviewSourceRef => 'Подтверждающий источник (необязательно)';

  @override
  String get reviewSourceHelper => 'DOI, PMID или ссылка https';

  @override
  String get reviewSourceInvalid => 'Укажите DOI, PMID или ссылку https.';

  @override
  String get reviewSubmit => 'Отправить рецензию';

  @override
  String get reviewSubmitted => 'Рецензия отправлена';

  @override
  String get reviewNotVerification =>
      'Одна рецензия не делает материал научно подтверждённым. Для подтверждения нужны независимые квалифицированные рецензии согласно политике проверки.';

  @override
  String reviewVersionNote(String version) {
    return 'Рецензия относится к версии содержания $version. При изменении содержания нужна повторная рецензия.';
  }

  @override
  String reviewMeta(String date, String version) {
    return 'Рецензия от $date · версия содержания $version';
  }

  @override
  String get reviewStale =>
      'Написана для более ранней версии — сохранена в истории; требуется повторная рецензия.';

  @override
  String get reviewPermAllowed => 'Вы можете рецензировать этот материал.';

  @override
  String get reviewPermSignIn => 'Сначала войдите в учётную запись.';

  @override
  String get reviewPermNotVerified =>
      'Рецензии могут писать только подтверждённые специалисты.';

  @override
  String get reviewPermSuspended =>
      'Ваше подтверждение приостановлено; рецензирование недоступно.';

  @override
  String get reviewPermScope =>
      'У вас нет права рецензирования в этой области.';

  @override
  String get reviewPermStudentMode =>
      'Переключитесь в режим «Специалист», чтобы писать рецензии. Подтверждение сохраняется.';

  @override
  String get layerSource => 'Источник прикреплён';

  @override
  String layerSourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count источников',
      few: '$count источника',
      one: '$count источник',
    );
    return '$_temp0';
  }

  @override
  String get noReliableSource => 'Надёжный источник не прикреплён.';

  @override
  String get layerIdentifier => 'Идентификатор (DOI/PMID) проверен';

  @override
  String get layerIdentifierOk => 'Проверен';

  @override
  String get layerIdentifierPending => 'Ещё не проверен';

  @override
  String get layerNotApplicable => 'Не применимо';

  @override
  String get layerProfessional => 'Рецензии специалистов';

  @override
  String get layerHuman => 'Научное подтверждение людьми';

  @override
  String layerHumanCount(int count, int required) {
    return '$count из $required независимых одобрений';
  }

  @override
  String get dashboardTitle => 'Рабочее место рецензента';

  @override
  String get dashboardOnlyVerified =>
      'Доступно только подтверждённым специалистам с правом рецензирования хотя бы в одной области.';

  @override
  String get dashboardQueueEmpty => 'В этой очереди нет записей.';

  @override
  String dashboardItemMeta(
    int claims,
    int sources,
    String level,
    String version,
  ) {
    return 'Утверждений: $claims · источников: $sources · доказательность: $level · версия $version';
  }

  @override
  String get queueNeedsReview => 'Требует рецензии';

  @override
  String get queueAssigned => 'Назначено мне';

  @override
  String get queueReviewedByMe => 'Рецензировано мной';

  @override
  String get queueConflicts => 'Противоречия';

  @override
  String get queueReReview => 'Нужна повторная рецензия';

  @override
  String get profileSectionVerification => 'Подтверждение';

  @override
  String get profileSectionData => 'Данные и конфиденциальность';

  @override
  String get profileStudentVerificationNote =>
      'Профессиональное подтверждение относится к режиму «Специалист». Смена режима не влияет на подтверждение.';

  @override
  String get profileNotFilled => 'Профиль не заполнен';

  @override
  String get profileFillAction => 'Заполнить профиль';

  @override
  String get profileEditAction => 'Изменить профиль';

  @override
  String get moduleHubSourced => 'Записи с источниками';

  @override
  String get moduleHubSourcedNote =>
      'Показаны с источниками и текущим статусом проверки. «Требует проверки» означает доступные материалы с источниками, ожидающие экспертной проверки, — а не отсутствие материалов.';

  @override
  String get moduleHubOpenAll => 'Открыть все';

  @override
  String methodsStandardsLink(int count) {
    return 'Международные стандарты и руководства ($count)';
  }

  @override
  String get sourceOneTap => 'Источники и происхождение';

  @override
  String get researchKeyRelevance => 'Судебно-экспертное значение';

  @override
  String get researchLimitationsNote =>
      'Показаны только библиографические данные и краткое описание; полный текст доступен у издателя.';

  @override
  String get emailCodeTitle => 'Вход по коду из письма';

  @override
  String get emailCodeRowHint =>
      'На почту придёт 6-значный код — пароль не нужен';

  @override
  String get emailCodeSubtitle =>
      'Введите email. Мы отправим одноразовый 6-значный код подтверждения FORENSIC EXPERT.';

  @override
  String get emailCodeSend => 'Отправить код';

  @override
  String get emailCodeEnterTitle => 'Введите 6-значный код';

  @override
  String get emailCodeChange => 'Изменить email';

  @override
  String emailCodeResendIn(int seconds) {
    return 'Повторная отправка через $seconds с';
  }

  @override
  String get emailCodeNotProfessional =>
      'Подтверждение email выполняет вход. Оно не подтверждает профессиональный статус.';

  @override
  String get emailCodeSignedIn => 'Email подтверждён. Вы вошли в аккаунт.';

  @override
  String get actionNext => 'Далее';

  @override
  String get profileSectionProfessional => 'Профиль специалиста';

  @override
  String get profileStepPersonal => 'Личные данные';

  @override
  String get profileStepWork => 'Профессиональные данные';

  @override
  String get profileStepProfessional => 'Профиль и подтверждение';

  @override
  String profileStepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get verifReceivedTitle => 'Ваша заявка принята.';

  @override
  String get verifReceivedBody => 'Профессиональный статус проверяется.';

  @override
  String get verifReceivedNote =>
      'Статус: заявка на рассмотрении. Статус «Подтверждённый специалист» может присвоить только уполномоченный проверяющий — загрузка документов не подтверждает автоматически.';

  @override
  String get sourceDetailTitle => 'Источник';

  @override
  String sourceLinkedRecords(int count) {
    return 'Связанные записи ($count)';
  }

  @override
  String get sourceNoLinkedRecords =>
      'В офлайн-базе нет записей, ссылающихся на этот источник.';

  @override
  String get sourceNotAttached => 'Надёжный источник не прикреплён.';

  @override
  String get sourceNotFound => 'Источник не найден в офлайн-базе.';

  @override
  String get sourceOpenDetails => 'Подробности источника и связанные записи';

  @override
  String homeDbCounts(int substances, int sources, int claims) {
    return 'Веществ: $substances · источников: $sources · утверждений с источниками: $claims';
  }

  @override
  String homeDbHumanVerified(int count) {
    return 'Подтверждено людьми (2 независимых эксперта): $count';
  }

  @override
  String sourcePmid(String id) {
    return 'PMID $id';
  }

  @override
  String get homeStatSubstances => 'Вещества';

  @override
  String get homeStatSources => 'Источники';

  @override
  String get homeStatClaims => 'Утверждения';

  @override
  String get homeStatHumanVerified => 'Подтверждено экспертами';

  @override
  String get homeStatPolicy =>
      '«Подтверждено» = два независимых квалифицированных эксперта. Автоматические проверки и ИИ не учитываются.';

  @override
  String get aiHeroSubtitle =>
      'Ответы только из научной базы FORENSIC EXPERT с источниками — каждое утверждение ссылается на запись и показывает статус проверки.';

  @override
  String get aiStatusConnected => 'Подключено · бета';

  @override
  String get aiContextSources => 'Источник: офлайн-база';

  @override
  String get aiComposerTitle => 'Научный запрос';

  @override
  String get referralTitle => 'Пригласить коллегу';

  @override
  String get referralLead =>
      'Знаете судебного эксперта, специалиста лаборатории или студента, которому пригодится FORENSIC EXPERT? Поделитесь личным приглашением.';

  @override
  String get referralYourCode => 'Ваш код приглашения';

  @override
  String get referralYourLink => 'Ваша ссылка-приглашение';

  @override
  String get referralNoLinkNote =>
      'Веб-ссылка появится здесь после подключения публичного сайта FORENSIC EXPERT. Пока поделитесь кодом — коллега вводит его в «Профиль → Код приглашения».';

  @override
  String get referralShare => 'Поделиться приглашением';

  @override
  String get referralCopy => 'Копировать';

  @override
  String get referralCopied => 'Скопировано в буфер обмена';

  @override
  String get referralStatsTitle => 'Ваши приглашения';

  @override
  String get referralStatJoined => 'Присоединились';

  @override
  String get referralStatVerified => 'Подтверждены';

  @override
  String get referralStatPending => 'Ожидают';

  @override
  String get referralStatCredits => 'Кредиты FORENSIC';

  @override
  String referralCreditsPending(String amount) {
    return '$amount кредитов ожидают подтверждения';
  }

  @override
  String referralCreditsFuture(String percent) {
    return 'После запуска платных услуг подходящие покупки приглашённых вами коллег могут приносить вам FORENSIC Credits — $percent% от суммы покупки. Кредиты — внутренний промо-бонус, а не деньги; за регистрацию они не начисляются.';
  }

  @override
  String referralCreditsActive(String percent) {
    return 'Вы получаете FORENSIC Credits в размере $percent% от подходящих покупок приглашённых коллег. Кредиты подтверждаются после периода возврата. Это внутренний промо-бонус, а не деньги.';
  }

  @override
  String get referralPrivacyNote =>
      'Показываются только итоговые числа. Имена, email, профили и документы коллег никогда не передаются — ни вам, ни в приглашении.';

  @override
  String get referralShareSubject => 'Приглашение в FORENSIC EXPERT';

  @override
  String referralShareWithLink(String link) {
    return 'Я пользуюсь FORENSIC EXPERT как научным справочником для судебно-экспертной работы: вещества, методы, источники и ответы ИИ со ссылками на источники. Присоединяйтесь по моему приглашению:\n$link';
  }

  @override
  String referralShareWithCode(String code) {
    return 'Я пользуюсь FORENSIC EXPERT как научным справочником для судебно-экспертной работы: вещества, методы, источники и ответы ИИ со ссылками на источники. Установите приложение и введите мой код в «Профиль → Код приглашения»: $code';
  }

  @override
  String get referralSignInTitle => 'Войдите, чтобы получить приглашение';

  @override
  String get referralSignInBody =>
      'Личный код создаётся на сервере после входа по email. Весь научный контент доступен и без аккаунта.';

  @override
  String get referralNotConfigured =>
      'Приглашения станут доступны после подключения аккаунт-сервиса FORENSIC EXPERT.';

  @override
  String get referralLoadError =>
      'Не удалось загрузить приглашение. Проверьте соединение и повторите.';

  @override
  String get referralRetry => 'Повторить';

  @override
  String get referralHaveCode => 'Код приглашения';

  @override
  String get referralHaveCodeHint =>
      'Получили приглашение от коллеги? Введите 8-значный код. Он действует только для новых аккаунтов.';

  @override
  String get referralCodeField => 'Код приглашения';

  @override
  String get referralApply => 'Применить';

  @override
  String get referralLinkedNote => 'Ваш аккаунт создан по приглашению коллеги.';

  @override
  String get referralClaimValid =>
      'Приглашение применено. Добро пожаловать в FORENSIC EXPERT.';

  @override
  String get referralClaimPending =>
      'Приглашение сохранено. Оно вступит в силу после подтверждения email.';

  @override
  String get referralClaimInvalid =>
      'Код не найден. Проверьте его и попробуйте снова.';

  @override
  String get referralClaimSelf =>
      'Нельзя использовать собственный код приглашения.';

  @override
  String get referralClaimAlready =>
      'К вашему аккаунту уже привязано приглашение.';

  @override
  String get referralClaimNotEligible =>
      'Коды приглашения действуют только для новых аккаунтов.';

  @override
  String get referralClaimRateLimited =>
      'Слишком много попыток. Попробуйте позже.';

  @override
  String get referralClaimSaved =>
      'Код сохранён. Он будет применён после входа.';

  @override
  String get referralClaimOffline =>
      'Нет соединения. Код сохранён и будет применён позже.';

  @override
  String get referralClaimFormat => 'Введите 8-значный код (буквы и цифры).';

  @override
  String get referralProfileRowHint => 'Поделитесь FORENSIC EXPERT с коллегами';

  @override
  String get homeInviteHint => 'Поделитесь надёжным справочником с коллегами';

  @override
  String get shareAction => 'Поделиться';

  @override
  String get shareFooter =>
      'Отправлено из FORENSIC EXPERT — научного справочника для судебных экспертов. Перед использованием сверяйтесь с первоисточником.';

  @override
  String get shareSourcesLabel => 'Источники';

  @override
  String get savedAdded => 'Сохранено в вашу библиотеку';

  @override
  String get savedRemoved => 'Удалено из сохранённого';

  @override
  String get firstStepsTitle => 'Начните за 5 минут';

  @override
  String firstStepsProgress(int done, int total) {
    return 'Выполнено $done из $total';
  }

  @override
  String get firstStepsSearch => 'Найдите вещество';

  @override
  String get firstStepsDiscipline => 'Откройте дисциплину';

  @override
  String get firstStepsSource => 'Откройте научный источник';

  @override
  String get firstStepsAi => 'Попробуйте Forensic AI';

  @override
  String get firstStepsSave => 'Сохраните полезный материал';

  @override
  String get firstStepsHide => 'Скрыть';

  @override
  String get firstStepsDone =>
      'Всё готово. Сохранённые материалы и недавние записи остаются на этом устройстве.';

  @override
  String get fullTextPdf => 'Полный текст (PDF)';

  @override
  String get fullTextPdfNote =>
      'Статья открытого доступа (PubMed Central через Europe PMC). Открывается в программе просмотра PDF или браузере устройства.';

  @override
  String get fullTextPdfPro => 'Загрузка полного текста (PDF) доступна в Pro.';

  @override
  String get fullTextOpenFailed =>
      'Не удалось открыть PDF. Проверьте соединение.';

  @override
  String get adminTitle => 'Админ-панель';

  @override
  String get adminProfileHint => 'Пользователи, платформы, страны, доступ';

  @override
  String get adminUsers => 'Пользователи';

  @override
  String get adminConfirmed => 'Email подтверждён';

  @override
  String get adminSignups7d => 'Новые (7 дней)';

  @override
  String get adminActive7d => 'Активные (7 дней)';

  @override
  String get adminAndroid => 'Android';

  @override
  String get adminIos => 'iOS';

  @override
  String get adminAiRequests => 'Запросы к ИИ';

  @override
  String get adminReferrals => 'Приглашения';

  @override
  String get adminProGrants => 'Выдано Pro';

  @override
  String get adminRegions => 'Страны (регион устройства)';

  @override
  String get adminDaily => 'Регистрации за 30 дней';

  @override
  String adminUserList(int count) {
    return 'Пользователи ($count)';
  }

  @override
  String get adminStoreNote =>
      'Здесь учитываются только зарегистрированные пользователи. Установки без регистрации видны в App Store Connect и Google Play Console.';

  @override
  String get adminPrivacyNote =>
      'Содержит персональные данные (email). Не пересылайте скриншоты.';

  @override
  String get adminGrantTitle => 'Выдать или снять Pro';

  @override
  String get adminEmail => 'Email пользователя';

  @override
  String get adminGrantPro => 'Выдать Professional Pro';

  @override
  String get adminRevoke => 'Снять';

  @override
  String get adminGranted => 'Pro выдан.';

  @override
  String get adminRevoked => 'Доступ снят.';

  @override
  String get adminNotFound => 'Пользователь с таким email не найден.';

  @override
  String get adminFailed => 'Не удалось. Проверьте соединение.';

  @override
  String get adminForbidden => 'Раздел только для администраторов.';

  @override
  String get adminRefresh => 'Обновить';

  @override
  String get adminUnknownRegion => 'Неизвестно';

  @override
  String get adminAdminBadge => 'Админ';

  @override
  String get calcSex => 'Пол';

  @override
  String get calcSexMale => 'Мужской';

  @override
  String get calcSexFemale => 'Женский';

  @override
  String get calcBodyWeight => 'Масса тела, кг';

  @override
  String get calcHeightOptional => 'Рост, см (необязательно — r по Seidl)';

  @override
  String get calcDrinkVolume => 'Объём напитка, мл';

  @override
  String get calcDrinkAbv => 'Крепость, % об.';

  @override
  String get calcHoursSinceStart => 'Часов с начала употребления';

  @override
  String get calcAddDrink => 'Добавить напиток';

  @override
  String get calcRemoveDrink => 'Удалить напиток';

  @override
  String calcDrinkN(String n) {
    return 'Напиток $n';
  }

  @override
  String get calcWidmarkEthanol => 'Выпито чистого этанола';

  @override
  String get calcWidmarkR => 'Коэффициент распределения r';

  @override
  String get calcWidmarkPeak =>
      'Теоретический максимум (без дефицита и элиминации)';

  @override
  String get calcWidmarkMin => 'Минимальная оценка';

  @override
  String get calcWidmarkMax => 'Максимальная оценка';

  @override
  String get calcWidmarkAssumptionDeficit =>
      'Резорбционный дефицит 10 % (максимум) и 30 % (минимум).';

  @override
  String get calcWidmarkAssumptionBeta =>
      'Элиминация 0,10 ‰/ч (максимум) и 0,20 ‰/ч (минимум) с начала употребления.';

  @override
  String get calcWidmarkAssumptionR =>
      'r: среднее по Widmark (муж. 0,7, жен. 0,6) или по Seidl и соавт. (2000) из роста и массы.';

  @override
  String get calcWidmarkLimitation =>
      'Это оценка, а не измерение. Пища, функция печени, характер употребления и лекарства меняют результат. Не заменяет измеренную концентрацию и экспертное заключение.';

  @override
  String get calcBacMeasured => 'Измеренная концентрация в крови, ‰';

  @override
  String get calcHoursEventToSample => 'Часов от события до взятия крови';

  @override
  String get calcHoursDrinkEndOptional =>
      'Часов от окончания употребления до события (необязательно)';

  @override
  String get calcBackMin => 'На момент события, минимум';

  @override
  String get calcBackMax => 'На момент события, максимум';

  @override
  String get calcBackAssumptionLinear =>
      'Элиминация линейная (нулевой порядок), к моменту события всасывание завершено.';

  @override
  String get calcBackAssumptionBeta =>
      'β = 0,10–0,25 г/л/ч охватывает большинство людей (Jones 2010).';

  @override
  String get calcBackLimitation =>
      'В течение ~2 часов после окончания употребления всасывание может продолжаться — обратный расчёт может завысить результат. Употребление после события делает расчёт недействительным.';

  @override
  String get calcWarnAbsorption =>
      'Событие было менее чем через 2 часа после окончания употребления: всасывание могло не завершиться. Минимум показан без обратной экстраполяции.';

  @override
  String get calcWarnEliminated =>
      'К этому времени алкоголь, вероятно, полностью выведен.';

  @override
  String get calcWarnRUnusual =>
      'Рассчитанный r вне обычного диапазона 0,45–0,85 — проверьте рост и массу.';

  @override
  String get calcEthanolMatrix => 'Образец';

  @override
  String get calcMatrixBlood => 'Цельная кровь';

  @override
  String get calcMatrixSerum => 'Сыворотка / плазма';

  @override
  String get calcSerumRatio => 'Отношение сыворотка / кровь';

  @override
  String get calcEthanolBloodHeader => 'Эквивалент для цельной крови';

  @override
  String get calcEthanolAssumptionDensity =>
      '‰ — это г/кг; для г/л используется плотность крови 1,055 г/мл.';

  @override
  String get calcEthanolAssumptionRatio =>
      'В сыворотке больше воды, чем в крови, поэтому этанола в ней больше; по умолчанию отношение 1,2.';

  @override
  String get calcEthanolLimitation =>
      'Отношение сыворотка/кровь индивидуально (около 1,1–1,3; Rainey 1993). Используйте значение, принятое в вашей лаборатории или юрисдикции.';

  @override
  String get calcRectalTemp => 'Ректальная температура, °C';

  @override
  String get calcAmbientTemp => 'Температура среды, °C';

  @override
  String get calcCorrectiveFactor => 'Одежда / среда (поправочный коэффициент)';

  @override
  String get calcFactorNakedDry => 'Обнажён, сухо, неподвижный воздух — 1,0';

  @override
  String get calcFactorNakedMovingAir => 'Обнажён, движение воздуха — 0,75';

  @override
  String get calcFactorWetStill => 'Обнажён, в стоячей воде — 0,5';

  @override
  String get calcFactorWetFlowing => 'Обнажён, в проточной воде — 0,35';

  @override
  String get calcFactorThin => '1–2 тонких слоя одежды — 1,1';

  @override
  String get calcFactorLayers => '2–3 слоя одежды — 1,2';

  @override
  String get calcFactorThick => '3–4 слоя / тёплая одежда — 1,3';

  @override
  String get calcFactorBedding => 'Под толстым одеялом — 2,0';

  @override
  String get calcHenssgeTime => 'Расчётная давность смерти';

  @override
  String get calcHenssgeRange => '95 % границы';

  @override
  String calcHoursValue(String h) {
    return '$h ч';
  }

  @override
  String calcHoursRange(String from, String to) {
    return '$from–$to ч';
  }

  @override
  String get calcHenssgeAssumptionNormal =>
      'Температура тела в момент смерти 37,2 °C.';

  @override
  String get calcHenssgeAssumptionAmbient =>
      'Температура среды была примерно постоянной; формулы для ≤ 23 °C и > 23 °C различаются.';

  @override
  String get calcHenssgeAssumptionCi =>
      '95 % границы: ±2,8 ч (≤ 23 °C), ±3,2 ч (> 23 °C), ±4,5 ч при поправочном коэффициенте.';

  @override
  String get calcHenssgeLimitation =>
      'Неприменимо при лихорадке, переохлаждении, источниках тепла, солнце, перемещении тела или больших изменениях температуры среды. Сочетайте с другими признаками (трупные пятна, окоченение, суправитальные реакции).';

  @override
  String get calcWarnNoCooling =>
      'Ректальная температура ≥ 37,2 °C — охлаждение не началось или была лихорадка.';

  @override
  String get calcWarnLatePhase =>
      'Тело близко к температуре среды — точность низкая.';

  @override
  String get calcErrorWeight => 'Введите реальную массу тела.';

  @override
  String get calcErrorTime => 'Введите корректное время в часах.';

  @override
  String get calcErrorAbv => 'Крепость должна быть от 0 до 100 %.';

  @override
  String get calcErrorHeight =>
      'Рост должен быть 120–230 см, или оставьте поле пустым.';

  @override
  String get calcErrorBac => 'Введите концентрацию от 0 до 8 ‰.';

  @override
  String get calcErrorRatio => 'Отношение должно быть от 1,0 до 1,5.';

  @override
  String get calcErrorRectal =>
      'Ректальная температура должна быть выше температуры среды и не более 42 °C.';

  @override
  String get calcErrorAmbient =>
      'Температура среды должна быть от −20 до 35 °C.';
}
