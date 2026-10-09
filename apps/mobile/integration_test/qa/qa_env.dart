// Real-ilova QA muhiti: ilovani haqiqiy `bootstrap()` bilan ishga tushirish,
// tarmoqni o‘chirish va tarmoqsiz soxta servislar.
//
// MUHIM: production Supabase’ga hech narsa yozilmaydi — yig‘ma
// `FE_SUPABASE_*` siz quriladi (`tool/qa_real_app.sh`), akkaunt MOCK
// (`FE_AUTH_MODE=mock`, faqat xotirada), va barcha HTTP ulanishlar
// [NoNetworkOverrides] bilan bloklanadi.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/publications.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/domain/ports/publication_ports.dart';
import 'package:forensic_expert/domain/publications/publication_models.dart';
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
