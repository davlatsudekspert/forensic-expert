import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/referral.dart';
import 'package:forensic_expert/data/auth/mock_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_auth_repository.dart';
import 'package:forensic_expert/data/remote/supabase_referral.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/ports/referral_ports.dart';
import 'package:forensic_expert/domain/referral/referral_models.dart';
import 'package:forensic_expert/domain/referral/share_text.dart';

import '../helpers/referral_fakes.dart';

class _Transport implements RestTransport {
  _Transport(this.handler);

  final RestResponse Function(Uri uri, Object? body) handler;
  final calls = <(Uri, Map<String, String>, Object?)>[];

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls.add((uri, headers, jsonBody));
    return handler(uri, jsonBody);
  }
}

final _cfg = SupabaseConfig(
  url: Uri.parse('https://fe-test.supabase.co/'),
  anonKey: 'anon-public-test-key',
);

SourceView _src(String id, {String? doi, String? pmid, String? url}) =>
    SourceView(
      sourceId: id,
      title: 'Title $id',
      sourceType: 'journal_article',
      evidenceLevel: 'B',
      licenseMode: 'metadata_only',
      identifierVerified: true,
      journal: 'J Anal Toxicol',
      year: 2021,
      doi: doi,
      pmid: pmid,
      url: url,
    );

void main() {
  group('Kod va havolalar', () {
    test('kod normalizatsiyasi: 8 belgi, 0/O/1/I yo‘q', () {
      expect(ReferralCode.normalize(' k7qh-2mpx '), 'K7QH2MPX');
      expect(ReferralCode.normalize('K7QH2MP'), isNull);
      expect(ReferralCode.normalize('O0I1ABCD'), isNull);
      expect(ReferralCode.normalize(null), isNull);
      expect(ReferralCode.normalize('K7QH2MPX9'), isNull);
    });

    test('ommaviy domen sozlanmagan — soxta URL yo‘q', () {
      const links = ReferralLinks();
      expect(links.hasPublicLink, isFalse);
      expect(links.inviteLink('K7QH2MPX'), isNull);
      expect(links.recordLink('morphine'), isNull);
      // Test muhitida FE_REFERRAL_BASE_URL berilmagan.
      expect(ReferralLinks.fromEnvironment().hasPublicLink, isFalse);
    });

    test('sozlangan domen — /invite/<CODE> va /record/<id>', () {
      final links = ReferralLinks(publicBase: Uri.parse('https://ex.org/app'));
      expect(
        links.inviteLink('K7QH2MPX').toString(),
        'https://ex.org/app/invite/K7QH2MPX',
      );
      expect(
        links.recordLink('morphine').toString(),
        'https://ex.org/app/record/morphine',
      );
    });

    test('kiruvchi havoladan kod ajratish', () {
      for (final u in [
        'https://ex.org/invite/k7qh2mpx',
        'forensicexpert://app/invite/K7QH2MPX',
        '/invite/K7QH2MPX',
        'https://ex.org/?ref=K7QH2MPX',
      ]) {
        expect(ReferralLinks.extractCode(Uri.parse(u)), 'K7QH2MPX', reason: u);
      }
      expect(ReferralLinks.extractCode(Uri.parse('/invite/<script>')), isNull);
      expect(ReferralLinks.extractCode(Uri.parse('/home')), isNull);
    });
  });

  group('Panel va natijalar', () {
    test('agregat JSON → model; kredit formati', () {
      final d = ReferralDashboard.fromJson({
        'code': 'K7QH2MPX',
        'joined': 3,
        'verified': 2,
        'pending': 1,
        'credits_earned_minor': 250,
        'credits_pending_minor': '100',
        'currency': 'USD',
        'reward_percent': '10.00',
        'rewards_enabled': false,
        'has_referrer': true,
      });
      expect(
        (d.joined, d.verified, d.pending, d.creditsEarnedMinor),
        (3, 2, 1, 250),
      );
      expect(d.creditsPendingMinor, 100);
      expect(d.rewardPercent, 10);
      expect(d.rewardsEnabled, isFalse);
      expect(d.hasReferrer, isTrue);
      expect(formatCredits(250), '2.50');
      expect(formatCredits(5), '0.05');
      expect(
        () => ReferralDashboard.fromJson({'code': 'bad'}),
        throwsFormatException,
      );
    });

    test('server natijalari', () {
      expect(
        ReferralClaimOutcome.fromServer('VALID'),
        ReferralClaimOutcome.valid,
      );
      expect(
        ReferralClaimOutcome.fromServer('SELF_REFERRAL'),
        ReferralClaimOutcome.selfReferral,
      );
      expect(
        ReferralClaimOutcome.fromServer('???'),
        ReferralClaimOutcome.server,
      );
      expect(ReferralClaimOutcome.pendingVerification.accepted, isTrue);
      expect(ReferralClaimOutcome.alreadyAttributed.terminal, isTrue);
      expect(ReferralClaimOutcome.offline.terminal, isFalse);
      expect(ReferralClaimOutcome.rateLimited.terminal, isFalse);
    });
  });

  group('Supabase adapter', () {
    Future<SupabaseAuthRepository> signedIn(_Transport t) async {
      final repo = SupabaseAuthRepository(
        config: _cfg,
        sessionStore: InMemorySessionStore(),
        transport: t,
      );
      await repo.verifyEmailCode(email: 'e@x.org', code: '123456');
      return repo;
    }

    RestResponse session() => const RestResponse(200, {
      'access_token': 'access-1',
      'refresh_token': 'refresh-1',
      'user': {
        'id': 'uid-1',
        'email': 'e@x.org',
        'email_confirmed_at': '2026-10-05',
      },
    });

    test('panel: RPC + Bearer; faqat o‘z agregatlari', () async {
      final t = _Transport((u, b) {
        if (u.path.endsWith('rpc/referral_dashboard')) {
          return const RestResponse(200, {
            'code': 'K7QH2MPX',
            'joined': 1,
            'verified': 1,
          });
        }
        return session();
      });
      final svc = SupabaseReferralService(
        config: _cfg,
        auth: await signedIn(t),
        transport: t,
      );
      final r = await svc.fetch();
      expect(r.dashboard?.code, 'K7QH2MPX');
      final call = t.calls.last;
      expect(call.$1.path, '/rest/v1/rpc/referral_dashboard');
      expect(call.$2['Authorization'], 'Bearer access-1');
      expect(call.$3, isEmpty);
    });

    test('kod qo‘llash: normallashgan kod; mukofot yozilmaydi', () async {
      final t = _Transport((u, b) {
        if (u.path.endsWith('rpc/claim_referral')) {
          return const RestResponse(200, 'PENDING_VERIFICATION');
        }
        return session();
      });
      final svc = SupabaseReferralService(
        config: _cfg,
        auth: await signedIn(t),
        transport: t,
      );
      expect(
        await svc.claim('k7qh 2mpx'),
        ReferralClaimOutcome.pendingVerification,
      );
      expect(t.calls.last.$3, {'p_code': 'K7QH2MPX'});
      // Mijozda mukofot yo‘li umuman yo‘q.
      expect(t.calls.where((c) => c.$1.path.contains('reward')), isEmpty);
    });

    test('noto‘g‘ri kod / kirmagan / oflayn — tarmoqqa chiqmaydi', () async {
      final t = _Transport((u, b) => throw const SocketException('offline'));
      final out = SupabaseReferralService(
        config: _cfg,
        auth: SupabaseAuthRepository(
          config: _cfg,
          sessionStore: InMemorySessionStore(),
          transport: t,
        ),
        transport: t,
      );
      expect(await out.claim('bad'), ReferralClaimOutcome.invalidCode);
      expect(await out.claim('K7QH2MPX'), ReferralClaimOutcome.notSignedIn);
      expect((await out.fetch()).failure, ReferralFailure.notSignedIn);
      expect(t.calls, isEmpty);
    });

    test('oflayn — offline natija', () async {
      var online = true;
      final t = _Transport((u, b) {
        if (!online) throw const SocketException('offline');
        return session();
      });
      final svc = SupabaseReferralService(
        config: _cfg,
        auth: await signedIn(t),
        transport: t,
      );
      online = false;
      expect(await svc.claim('K7QH2MPX'), ReferralClaimOutcome.offline);
      expect((await svc.fetch()).failure, ReferralFailure.offline);
    });

    test('ulanmagan xizmat — hech narsa soxtalashtirilmaydi', () async {
      const s = UnconfiguredReferralService();
      expect(s.isConfigured, isFalse);
      expect((await s.fetch()).failure, ReferralFailure.notConfigured);
      expect(await s.claim('K7QH2MPX'), ReferralClaimOutcome.notConfigured);
    });
  });

  group('Kutilayotgan kod (deep link → kirgandan keyin bir marta)', () {
    test('kirmagan: saqlanadi; kirgach bir marta yuboriladi', () async {
      final auth = MockAuthRepository();
      final svc = FakeReferralService();
      final store = InMemoryPendingReferralStore();
      final c = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          referralServiceProvider.overrideWithValue(svc),
          pendingReferralStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(c.dispose);
      c.listen(pendingReferralProvider, (_, _) {});
      c.listen(authStateProvider, (_, _) {});
      expect(
        await c.read(pendingReferralProvider.notifier).remember('k7qh2mpx'),
        isTrue,
      );
      expect(store.value, 'K7QH2MPX');
      expect(svc.claims, isEmpty);

      await auth.register(
        email: 'new@lab.uz',
        password: 'TestPassw0rd!',
        acceptedTermsVersion: 'v',
      );
      await auth.verifyEmail(email: 'new@lab.uz', code: auth.outbox.last.code!);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(svc.claims, ['K7QH2MPX']);
      expect(store.value, isNull);
      expect(
        c.read(pendingReferralProvider).lastOutcome,
        ReferralClaimOutcome.valid,
      );
    });

    test(
      'oflayn — kod saqlanib qoladi; noto‘g‘ri format qabul qilinmaydi',
      () async {
        final svc = FakeReferralService(
          claimOutcome: ReferralClaimOutcome.offline,
        );
        final store = InMemoryPendingReferralStore();
        final c = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(await signedInMockAuth()),
            referralServiceProvider.overrideWithValue(svc),
            pendingReferralStoreProvider.overrideWithValue(store),
          ],
        );
        addTearDown(c.dispose);
        final ctl = c.read(pendingReferralProvider.notifier);
        expect(await ctl.remember('nope'), isFalse);
        expect(await ctl.remember('K7QH2MPX'), isTrue);
        expect(svc.claims, ['K7QH2MPX']);
        expect(store.value, 'K7QH2MPX');
      },
    );
  });

  group('Ulashish matni (shaxsiy ma’lumotsiz)', () {
    test('manba: DOI havolasi va ogohlantirish; HTTP havola tashlanadi', () {
      final t = sourceShareText(_src('S1', doi: '10.1/x'), footer: 'FOOT');
      expect(t, contains('https://doi.org/10.1/x'));
      expect(t, contains('J Anal Toxicol, 2021'));
      expect(t.trim().endsWith('FOOT'), isTrue);
      final insecure = sourceShareText(
        _src('S2', url: 'http://insecure.example'),
        footer: 'FOOT',
      );
      expect(insecure, isNot(contains('http://')));
      expect(
        sourceShareText(_src('S3', pmid: '34436497'), footer: 'F'),
        contains('https://pubmed.ncbi.nlm.nih.gov/34436497/'),
      );
    });

    test('yozuv: ko‘pi bilan 3 manba, takror yo‘q, email/profil yo‘q', () {
      final t = recordShareText(
        title: 'Morphine',
        sources: [
          _src('A', doi: '10.1/a'),
          _src('A', doi: '10.1/a'),
          _src('B'),
          _src('C'),
          _src('D'),
        ],
        sourcesLabel: 'Sources',
        footer: 'FOOT',
      );
      expect(t.split('\n').first, 'Morphine');
      expect('•'.allMatches(t).length, 3);
      expect(t, isNot(contains('@')));
      expect(t, isNot(contains('Title D')));
    });
  });
}
