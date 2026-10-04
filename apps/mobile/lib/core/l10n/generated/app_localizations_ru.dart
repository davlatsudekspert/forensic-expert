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
  String get searchHint =>
      'Поиск вещества, метода, формулы, темы или источника…';

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
}
