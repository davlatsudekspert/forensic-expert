// Real-ilova QA muhiti: ilovani haqiqiy `bootstrap()` bilan ishga tushirish,
// tarmoqni o‘chirish va tarmoqsiz soxta servislar.
//
// MUHIM: production Supabase’ga hech narsa yozilmaydi — yig‘ma
// `FE_SUPABASE_*` siz quriladi (`tool/qa_real_app.sh`), akkaunt MOCK
// (`FE_AUTH_MODE=mock`, faqat xotirada), va barcha HTTP ulanishlar
// [NoNetworkOverrides] bilan bloklanadi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/publications.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/admin/admin_models.dart';
import 'package:forensic_expert/domain/ports/account_ports.dart';
import 'package:forensic_expert/domain/ports/publication_ports.dart';
import 'package:forensic_expert/domain/publications/publication_models.dart';
import 'package:forensic_expert/domain/support/support_models.dart';
import 'package:forensic_expert/features/support/support_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'harness.dart';

/// Har qanday HTTP ulanish urinishi «tarmoq yo‘q» xatosi bilan tugaydi.
class NoNetworkOverrides extends HttpOverrides {
  int attempts = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..connectionFactory = (uri, proxyHost, proxyPort) {
          attempts++;
          return Future.error(
            const SocketException('QA: tarmoq o‘chirilgan (simulyatsiya)'),
          );
        };
}

/// Natijalar katalogi (`QA_OUT`, standart: build/qa_real_app).
Directory qaOutDir() =>
    Directory(Platform.environment['QA_OUT'] ?? 'build/qa_real_app')
      ..createSync(recursive: true);

/// Ilovani **haqiqiy** `bootstrap()` orqali ishga tushiradi (toza o‘rnatish:
/// bo‘sh sozlamalar). [overrides] faqat tarmoqsiz soxta servislar uchun.
Future<QaRun> launchRealApp(
  WidgetTester tester, {
  required String role,
  List<Override> overrides = const [],
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final run = QaRun(tester, role: role, outDir: qaOutDir());
  run.installErrorCollector();
  await bootstrap(testOverrides: overrides);
  await run.setSize(const Size(390, 844));
  await run.settle(maxMs: 8000);
  return run;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

void goTo(WidgetTester tester, String location) =>
    containerOf(tester).read(routerProvider).go(location);

/// MOCK backend «yuborgan» oxirgi kod (xat yuborilmaydi).
String? lastMockCode(WidgetTester tester) {
  final auth = containerOf(tester).read(authRepositoryProvider);
  if (auth is! MockAuthRepository || auth.outbox.isEmpty) return null;
  return auth.outbox.last.code;
}

bool isPublicationsFake(WidgetTester tester) =>
    containerOf(tester).read(publicationServiceProvider)
        is QaPublicationService;

/// «Ekspert maqolalari» uchun xotiradagi soxta server (QA). Server
/// kontraktini soddalashtirib takrorlaydi: uchala tasdiqsiz yuborish rad
/// etiladi, sarlavha/annotatsiya/fan majburiy.
class QaPublicationService implements PublicationService {
  final _drafts = <String, PublicationDraft>{};
  final _status = <String, PublicationStatus>{};
  int _n = 0;

  /// Muvaffaqiyatli yuborilgan maqolalar soni.
  int get submittedCount =>
      _status.values.where((v) => v == PublicationStatus.submitted).length;

  static const _published = Publication(
    id: 'qa-pub-1',
    status: PublicationStatus.published,
    title: 'QA namunasi: qonda etanolni HS-GC-FID bilan aniqlash tajribasi',
    abstract:
        'Bu QA sinovi uchun soxta maqola (haqiqiy nashr emas). Ro‘yxat, '
        'ochish va shikoyat oqimini tekshirish uchun ishlatiladi.',
    keywords: ['etanol', 'HS-GC-FID'],
  );

  @override
  bool get isConfigured => true;

  @override
  Future<List<Publication>?> listPublished() async => const [_published];

  @override
  Future<List<Publication>?> myPublications() async => [
    for (final e in _drafts.entries)
      Publication(
        id: e.key,
        status: _status[e.key] ?? PublicationStatus.draft,
        title: e.value.title,
        abstract: e.value.abstract,
        disciplineCode: e.value.disciplineCode,
        rightsConfirmed: e.value.rightsConfirmed,
        publicationConsent: e.value.publicationConsent,
        noPersonalDataConfirmed: e.value.noPersonalDataConfirmed,
        own: true,
      ),
  ];

  @override
  Future<String?> saveDraft(PublicationDraft draft) async {
    final id = draft.id ?? 'qa-draft-${++_n}';
    _drafts[id] = draft;
    _status.putIfAbsent(id, () => PublicationStatus.draft);
    return id;
  }

  @override
  Future<SubmitResult> submit(String id) async {
    final d = _drafts[id];
    if (d == null) return SubmitResult.notFound;
    if (!d.allConfirmed) return SubmitResult.confirmationsRequired;
    if (d.submitIssues.isNotEmpty) return SubmitResult.incomplete;
    _status[id] = PublicationStatus.submitted;
    return SubmitResult.submitted;
  }

  @override
  Future<ReportResult> report(
    String id,
    ReportReason reason,
    String details,
  ) async => ReportResult.reported;

  @override
  Future<bool> canModerate() async => false;

  @override
  Future<ModerationQueue?> moderationQueue() async => null;

  @override
  Future<ModerationResult> moderate(
    String id,
    PublicationStatus to,
    String? comment,
  ) async => ModerationResult.failed;
}

/// Profil formasida davlatni tanlash (qidiruvli pastki oyna).
Future<void> pickCountry(QaRun qa, String query, String code) async {
  await qa.tapFinder(find.byKey(const Key('profileEdit.country')));
  await qa.enterText(find.byKey(const Key('country.search')), query);
  await qa.tapFinder(find.byKey(Key('country.$code')));
}

/// Oldingi SnackBar tugmalarni to‘smasin.
void clearSnackBars(WidgetTester tester) {
  for (final e in find.byType(ScaffoldMessenger).evaluate()) {
    final st = (e as StatefulElement).state;
    if (st is ScaffoldMessengerState) st.clearSnackBars();
  }
}

/// Ilovani fonga o‘tkazib qaytaradi (haqiqiy hayot sikli hodisalari).
/// Oraliq holatlarda kadr chizilmaydi (hidden/paused’da kadrlar o‘chiq —
/// `pump` osilib qoladi), shuning uchun faqat oxirida chiziladi.
Future<void> resumeApp(WidgetTester tester) async {
  for (final st in const [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(st);
  }
  await tester.pump();
}

/// MOCK OTP bilan kirish (email → kod → tasdiqlash). Kirish ekrani ochiq
/// bo‘lishi kerak.
Future<void> mockSignIn(QaRun qa, WidgetTester tester, String email) async {
  final l = lookupAppLocalizations(const Locale('uz'));
  await qa.enterText(find.byType(TextField), email);
  await qa.tapText(l.emailCodeSend);
  await qa.enterText(find.byType(TextField), lastMockCode(tester)!);
  await qa.tapText(l.verifySubmit);
  await qa.settle(maxMs: 4000);
}

/// Tizim fayl tanlagichi (GTK/SAF/Document Picker) Xvfb’da boshqarilmaydi —
/// o‘rniga haqiqiy PNG baytlarini qaytaruvchi tanlagich. Qolgan oqim
/// (ko‘rinish, hajm, yuborish) haqiqiy.
class QaImagePicker implements SupportImagePicker {
  int calls = 0;

  /// 16×16 haqiqiy PNG (gradient).
  static final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAB3klEQVR42g3LIc6GIACA4f8k'
    '3wE8gAfwAI7oSCZmdCQTIzISiRmZyb3BERnJxMye6Pfpz99P0Al6wSAYBVKgBFpgBF4QBYfg'
    'ElRBE7yCv99EN9FPDBPjhJxQE3rCTPiJOHFMXBN1ok280xdmupl+ZpgZZ+SMmtEzZsbPxJlj'
    '5pqpM23mnb+w0C30C8PCuCAX1IJeMAt+IS4cC9dCXWgL7/KFlW6lXxlWxhW5olb0ilnxK3Hl'
    'WLlW6kpbedcvbHQb/cawMW7IDbWhN8yG34gbx8a1UTfaxrt9wdJZestgGS3SoizaYizeEi2H'
    '5bJUS7O89guOztE7BsfokA7l0A7j8I7oOByXozqa43VfCHSBPjAExoAMqIAOmIAPxMARuAI1'
    '0AJv+MJOt9PvDDvjjtxRO3rH7PiduHPsXDt1p+28+xcSXaJPDIkxIRMqoRMm4RMxcSSuRE20'
    'xJu+cNKd9CfDyXgiT9SJPjEn/iSeHCfXST1pJ+/5hUyX6TNDZszIjMrojMn4TMwcmStTMy3z'
    '5i8UukJfGApjQRZUQRdMwRdi4ShchVpohbd84aa76W+Gm/FG3qgbfWNu/E28OW6um3rTbt77'
    'Cw/dQ/8wPIwP8kE96Afz4B/iw/FwPdSH9vA+/APegq4Q/NP4FwAAAABJRU5ErkJggg==',
  );

  @override
  Future<PickedImage?> pick() async {
    calls++;
    final mime = sniffImageMime(png);
    if (mime == null) {
      return const PickedImageRejected(PickedImageError.wrongType);
    }
    return PickedImageOk(SupportAttachment(bytes: png, mimeType: mime));
  }
}

/// Server `my_access` / boshqaruv paneli taqlidi (QA, tarmoqsiz). Admin
/// huquqi faqat shu «server» javobidan; email’dan emas.
class QaAccountService implements AccountService {
  QaAccountService({this.admin = false});

  final bool admin;

  @override
  bool get isConfigured => true;

  @override
  Future<ServerAccess?> myAccess() async => ServerAccess(isAdmin: admin);

  @override
  Future<void> registerDevice({
    required String platform,
    required String version,
    required String locale,
    String? region,
  }) async {}

  @override
  Future<AdminDashboard?> dashboard() async => admin
      ? AdminDashboard.fromJson(const {
          'totals': {
            'users': 128,
            'confirmed': 117,
            'signups_7d': 19,
            'active_7d': 41,
            'android': 90,
            'ios': 31,
            'ai_requests': 940,
            'referrals': 6,
            'pro_grants': 3,
          },
          'regions': [
            {'region': 'UZ', 'users': 101},
            {'region': 'KZ', 'users': 12},
            {'region': '??', 'users': 15},
          ],
        })
      : null;

  @override
  Future<AdminGrantResult> setAccess(String email, String? tier) async =>
      AdminGrantResult.failed;
}

/// QA FIXTURE statistika (soxta; haqiqiy server ma’lumoti emas).
final qaAdminStats = AdminStats.fromJson(const {
  'users': {'total': 128, 'new_today': 4, 'new_7d': 19, 'new_30d': 57},
  'modes': {
    'students': null,
    'experts': null,
    'professional_profiles': 23,
    'verified_professionals': 9,
  },
  'tiers': {'pro': 14, 'free': 114},
  'active': {'d7': 41, 'd30': 88},
  'support': {
    'awaiting': 3,
    'new': 2,
    'in_review': 1,
    'answered': 5,
    'closed': 7,
    'by_category': {
      'SUGGESTION': 6,
      'BUG': 4,
      'SCIENTIFIC_ERROR': 3,
      'FEATURE_REQUEST': 2,
      'TECH_SUPPORT': 1,
      'GENERAL': 1,
    },
  },
  'publications': {'awaiting_moderation': 2, 'open_reports': 0},
  'ai': {'total': 940, 'd7': 112},
  'daily': [
    {'day': '2026-09-26', 'signups': 2, 'ai': 5},
    {'day': '2026-09-27', 'signups': 1, 'ai': 8},
    {'day': '2026-09-28', 'signups': 0, 'ai': 4},
    {'day': '2026-09-29', 'signups': 3, 'ai': 9},
    {'day': '2026-09-30', 'signups': 5, 'ai': 12},
    {'day': '2026-10-01', 'signups': 2, 'ai': 7},
    {'day': '2026-10-02', 'signups': 1, 'ai': 6},
    {'day': '2026-10-03', 'signups': 4, 'ai': 10},
    {'day': '2026-10-04', 'signups': 6, 'ai': 15},
    {'day': '2026-10-05', 'signups': 3, 'ai': 9},
    {'day': '2026-10-06', 'signups': 2, 'ai': 11},
    {'day': '2026-10-07', 'signups': 7, 'ai': 14},
    {'day': '2026-10-08', 'signups': 5, 'ai': 13},
    {'day': '2026-10-09', 'signups': 4, 'ai': 6},
  ],
});

/// 30 ta soxta foydalanuvchi (2 sahifa: 25 + 5), `@example.test` domeni.
List<AdminUserSummary> qaAdminUsers() => [
  AdminUserSummary.fromJson(const {
    'id': 'u0',
    'email': 'owner@example.test',
    'display_name': 'Egasi',
    'created_at': '2026-09-01T09:00:00Z',
    'last_activity': '2026-10-09T08:00:00Z',
    'roles': ['identity_admin'],
    'tier': 'professionalPro',
    'locale': 'uz',
    'platforms': 'android',
    'status': 'ACTIVE',
  }),
  AdminUserSummary.fromJson(const {
    'id': 'u-mod',
    'email': 'moderator@example.test',
    'display_name': 'Moderator',
    'created_at': '2026-09-03T09:00:00Z',
    'roles': ['publication_moderator'],
    'locale': 'ru',
    'platforms': 'ios',
    'status': 'ACTIVE',
  }),
  for (var i = 1; i <= 28; i++)
    AdminUserSummary.fromJson({
      'id': 'u$i',
      'email': 'user${i.toString().padLeft(2, '0')}@example.test',
      'created_at': '2026-10-0${i % 9 + 1}T09:00:00Z',
      'last_activity': i.isEven ? '2026-10-08T18:00:00Z' : null,
      'tier': i % 7 == 0 ? 'studentPro' : null,
      'locale': i.isEven ? 'uz' : 'ru',
      'platforms': i.isEven ? 'android' : 'ios',
      'status': i % 10 == 0 ? 'UNCONFIRMED' : 'ACTIVE',
    }),
];
