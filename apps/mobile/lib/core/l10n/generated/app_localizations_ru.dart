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
  String get modeTitle => 'Как вы будете использовать Forensic Expert?';

  @override
  String get modeSubtitle =>
      'От этого зависит главный экран. Позже это можно изменить в профиле.';

  @override
  String get modeProfessional => 'Специалист';

  @override
  String get modeProfessionalDescription =>
      'Судебно-медицинские эксперты, судебные химики-токсикологи, специалисты лабораторий';

  @override
  String get modeStudent => 'Студент / ординатор';

  @override
  String get modeStudentDescription => 'Курсы, глоссарий, карточки и практика';

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
  String get inDevelopmentTitle => 'В разработке';

  @override
  String get inDevelopmentBody =>
      'Этот раздел появится на одном из следующих этапов разработки. Научный контент не показывается, пока не пройдёт экспертную проверку.';

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
  String get aiNotConnectedTitle => 'Forensic AI пока не подключён';

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
  String get legalSection => 'Правовая информация';

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
      'Прототип: записи с пометкой TEST DATA — заглушки, а не научный контент.';

  @override
  String get testDataBadge => 'TEST DATA';

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
      'Запланировано на V1.1 после научной и лицензионной проверки.';

  @override
  String get toolMolarityName => 'Молярность и массовая концентрация';

  @override
  String get toolMolarityDesc =>
      'Пересчёт массовой концентрации в молярную и обратно.';

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
  String get toolUnitsDesc => 'мг/л, мкг/мл, нг/мл, ммоль/л и др.';

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
  String get detailPlaceholder => 'Заглушка — научного контента пока нет.';

  @override
  String get detailConcentrationsNote =>
      'Концентрация сама по себе не устанавливает причину смерти. Значения будут показаны только с указанием матрицы, популяции и источников.';

  @override
  String get sourcesButton => 'Источники';

  @override
  String get sourcesNone => 'Источников нет — это тестовые данные.';

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
      'Поиск в PubMed, PubChem и Crossref появится в одной из следующих версий. Внешние результаты никогда не смешиваются с проверенными внутренними данными.';

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
  String get aiPreviewTitle => 'Формат ответа (предпросмотр)';

  @override
  String get aiPreviewNotice =>
      'Прототип интерфейса. Ниже — текст-заглушка: это не ответ ИИ и не научный контент.';

  @override
  String get aiSectionAvailable => 'Имеющиеся данные';

  @override
  String get aiSectionConsiderations => 'Дифференциальные соображения';

  @override
  String get aiSectionLimitations => 'Ограничения интерпретации';

  @override
  String get aiSampleInternal =>
      'Утверждение-заглушка, подтверждённое проверенным внутренним источником.';

  @override
  String get aiSampleExternal =>
      'Утверждение-заглушка из внешнего источника, который не проверялся.';

  @override
  String get aiSampleLimitation =>
      'Ограничение-заглушка — окончательная интерпретация требует полного контекста случая.';

  @override
  String get aiEvidenceInternalVerified => 'Внутренний · подтверждено';

  @override
  String get aiEvidenceInternalReviewed => 'Внутренний · проверено';

  @override
  String get aiEvidenceExternal => 'Внешний · не проверено';

  @override
  String aiPlaceholderSource(int number) {
    return 'Источник-заглушка $number';
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
  String get profileSectionAccount => 'Аккаунт и покупки';

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
  String get accountNone => 'Без аккаунта — приложение работает без входа.';

  @override
  String get legalDraftNotice =>
      'Черновик. Документ будет опубликован после профессиональной юридической проверки.';

  @override
  String get privacySummary =>
      'Основная библиотека и калькуляторы работают офлайн. История поиска и прогресс хранятся на вашем устройстве. В приложении нет рекламных SDK. Персональные данные и сведения о делах никогда не передаются ИИ автоматически.';

  @override
  String get aboutBody =>
      'Профессиональное справочное, обучающее и научно-расчётное приложение для судебной экспертизы.';

  @override
  String get aboutVersions =>
      'Версия приложения и версия научной базы данных учитываются раздельно.';

  @override
  String get storeNotConnected =>
      'В этой сборке магазин не подключён, поэтому покупка недоступна.';

  @override
  String get restorePurchases => 'Восстановить покупку';

  @override
  String get restoreNothing => 'Нет покупок для восстановления.';

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
  String get purchaseTitle => 'Пожизненный доступ';

  @override
  String get purchaseOneTime => 'Разовая покупка';

  @override
  String purchasePriceLine(String price) {
    return '$price · Разовая покупка';
  }

  @override
  String get purchaseReferencePriceNote =>
      'Ориентировочная цена. Окончательную цену в вашей валюте покажет App Store или Google Play.';

  @override
  String get purchaseValueReference =>
      'Профессиональный судебно-экспертный справочник';

  @override
  String get purchaseValueTools =>
      'Научные калькуляторы и лабораторные инструменты';

  @override
  String get purchaseValueSources =>
      'Проверенные источники и статус доказательности';

  @override
  String get purchaseValueOffline => 'Профессиональная офлайн-база';

  @override
  String get purchaseValueLearning => 'Обучение и профессиональное развитие';

  @override
  String get purchaseValueUpdates => 'Будущие обновления научного контента';

  @override
  String get purchaseCta => 'Открыть FORENSIC EXPERT';

  @override
  String get purchaseFooter => 'Разовая покупка · Без регулярной подписки';

  @override
  String get purchaseFreeTitle => 'Бесплатная версия';

  @override
  String get purchaseFreeBody =>
      'Попробуйте до покупки: демо поиска, избранные справочные статьи, отдельные инструменты и демо-уроки.';

  @override
  String get purchaseAiNote =>
      'Forensic AI не входит без ограничений: у него есть серверные расходы. Любой объём AI будет чётко указан до покупки.';

  @override
  String get purchaseOwned => 'Пожизненный доступ активен';

  @override
  String get purchaseUnavailableSnack => 'Покупки недоступны в этой сборке.';

  @override
  String get accessFree => 'Бесплатная версия';

  @override
  String get accessLifetime => 'Пожизненный';

  @override
  String get homePilotNotice =>
      'Пилотная научная база: все записи ожидают экспертной проверки. Сведения приводятся с источниками и не являются окончательным заключением.';

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
  String get lockedTitle => 'Входит в FORENSIC EXPERT Lifetime';

  @override
  String get lockedBody =>
      'Названия, предупреждения и источники остаются открытыми. Научные данные и юрисдикционный слой открываются с Lifetime Access.';

  @override
  String get freeDemoBadge => 'Бесплатно (демо)';

  @override
  String get lockedBadge => 'Lifetime';

  @override
  String searchMoreLocked(int count) {
    return 'Ещё $count результатов в Lifetime';
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
  String get purchaseSuccess => 'Пожизненный доступ открыт. Спасибо!';

  @override
  String get aboutTrademarkPending =>
      'Название и логотип: проверка товарного знака не завершена.';

  @override
  String get diagPurchaseNone => 'Покупка: магазин не подтвердил';

  @override
  String get diagPurchaseStore =>
      'Покупка: подтверждена только магазином — серверная проверка не подключена (блокирует релиз)';

  @override
  String get diagPurchaseServer => 'Покупка: проверена сервером';

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
}
