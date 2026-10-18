// Ilovaning haqiqiy Supabase adapteri → lokal PostgreSQL dagi haqiqiy RPC'lar.
// Ishga tushirish: `bash supabase/tests/class_groups_dart_e2e.sh` (bazani
// ko'taradi, migratsiyalarni qo'llaydi va shu testni chaqiradi). Muhit
// o'zgaruvchilarisiz (oddiy `flutter test`) — o'tkazib yuboriladi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/remote/supabase_class_groups.dart';
import 'package:forensic_expert/data/remote/supabase_rest.dart';
import 'package:forensic_expert/domain/auth/auth_models.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_groups/variant_draw.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';

final _host = Platform.environment['FE_LOCAL_PG_HOST'];
final _port = Platform.environment['FE_LOCAL_PG_PORT'];

/// PostgREST o'rnida: `POST rest/v1/rpc/<name>` → psql, Bearer token =
/// foydalanuvchi id si (`request.jwt.claim.sub`), rol `authenticated`.
class PsqlTransport implements RestTransport {
  int calls = 0;

  @override
  Future<RestResponse> send(
    String method,
    Uri uri, {
    Map<String, String> headers = const {},
    Object? jsonBody,
    List<int>? bytes,
    String? contentType,
  }) async {
    calls++;
    final name = uri.pathSegments.last;
    final uid = headers['Authorization']!.replaceFirst('Bearer ', '');
    String q(String s) => "'${s.replaceAll("'", "''")}'";
    final sql =
        "select set_config('request.jwt.claim.sub', ${q(uid)}, false);"
        "select set_config('request.jwt.claims', '{}', false);"
        'set role authenticated;'
        'select e2e_tools.rpc(${q(name)}, ${q(jsonEncode(jsonBody))}::jsonb);';
    final r = await Process.run('psql', [
      '-h',
      _host!,
      '-p',
      _port!,
      '-U',
      'postgres',
      '-d',
      'fe',
      '-tAq',
      '-v',
      'ON_ERROR_STOP=1',
      '-c',
      sql,
    ]);
    if (r.exitCode != 0) {
      final err = '${r.stderr}';
      return RestResponse(
        err.contains('forbidden') || err.contains('permission denied')
            ? 403
            : 400,
        {'message': err},
      );
    }
    final lines = '${r.stdout}'.trim().split('\n');
    return RestResponse(200, jsonDecode(lines.last));
  }
}

/// Faqat `current` va `accessToken` kerak.
class _Auth implements AuthRepository {
  _Auth(this.uid);

  final String uid;

  @override
  AuthState get current => AuthState(
    AuthStatus.signedIn,
    account: AuthAccount(userId: uid, email: '$uid@e2e', emailVerified: true),
  );

  @override
  Future<String?> accessToken() async => uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const teacherId = '7d000000-0000-0000-0000-0000000000a1';
  const students = {
    '7d000000-0000-0000-0000-0000000000b1': 'G’ayrat',
    '7d000000-0000-0000-0000-0000000000b2': 'Oʻtkir',
    '7d000000-0000-0000-0000-0000000000b3': 'Lola',
  };
  final transport = PsqlTransport();
  SupabaseClassGroupsService as(String uid) => SupabaseClassGroupsService(
    config: SupabaseConfig(url: Uri.parse('https://local.test/'), anonKey: 'x'),
    auth: _Auth(uid),
    transport: transport,
  );

  test(
    'Dart adapter ↔ lokal Postgres: 1 ustoz + 3 talaba',
    () async {
      final teacher = as(teacherId);
      final g = (await teacher.create('4-kurs, Dart e2e')).value!;
      expect(g.code, matches(RegExp(r'^[A-HJKMNP-Z2-9]{8}$')));
      final a = (await teacher.createAssignment(
        g.id,
        AssignmentDraft(
          topicId: 'dart-tox',
          questionCount: 5,
          timeLimitMin: 20,
          dueAt: DateTime.now().add(const Duration(days: 1)),
          variantMode: true,
          reveal: RevealPolicy.afterDue,
        ),
      )).value!;
      expect(a.variantMode, isTrue);
      expect(a.poolSize, 20);
      // Variant rad etilishi (hovuz 20 < 2 × 11).
      final refused = await teacher.createAssignment(
        g.id,
        const AssignmentDraft(
          topicId: 'dart-tox',
          questionCount: 11,
          variantMode: true,
        ),
      );
      expect(refused.failure, GroupFailure.variantPoolSmall);
      expect(refused.extra['needed'], 22);

      // Ustoz o'z kodini ochadi — a'zo bo'lmaydi.
      final own = (await teacher.join(
        code: g.code!,
        assignmentId: a.id,
      )).value!;
      expect(own.isTeacher, isTrue);

      final pool = (await teacher.preview(a.id)).value!.pool;
      final key = {for (final q in pool) q.id: q.correctIndex};
      final sets = <String>{};
      var expectedScore = 5;
      for (final MapEntry(key: uid, value: nick) in students.entries) {
        final s = as(uid);
        final first = await s.join(
          code: g.code!.toLowerCase(),
          assignmentId: a.id,
        );
        expect(first.failure, GroupFailure.nicknameRequired);
        final j = (await s.join(
          code: g.code!,
          nickname: nick,
          assignmentId: a.id,
        )).value!;
        expect(j.assignmentId, a.id);
        expect(j.nickname, ClassNickname.clean(nick));
        final att = (await s.open(a.id)).value!;
        final ids = [for (final q in att.questions) q.id];
        // Server bergan to'plam == ilovadagi drawVariant (bir xil algoritm).
        expect(
          ids,
          drawVariant(
            assignmentId: a.id,
            userId: uid,
            pool: [for (final q in pool) q.id],
            count: 5,
          ),
        );
        expect(
          jsonEncode(att.questions.map((q) => q.text).toList()),
          isNot(contains('correct')),
        );
        sets.add((ids.toList()..sort()).join(','));
        // Har savoldan keyin saqlash, so'ng yuborish; birinchi `expectedScore` ta to'g'ri.
        for (final (i, id) in ids.indexed) {
          final ans = i < expectedScore ? key[id]! : (key[id]! + 1) % 4;
          expect((await s.save(a.id, {id: ans})).ok, isTrue);
        }
        final sub = (await s.submit(a.id, const {})).value!;
        expect(sub.score, expectedScore);
        expect(sub.revealed, isFalse);
        final res = (await s.result(a.id)).value!;
        expect(res.revealed, isFalse);
        expect(res.items.every((it) => it.correctIndex == null), isTrue);
        expectedScore -= 2;
      }
      expect(sets, hasLength(3), reason: 'har talabaga boshqa savollar');

      final board = (await teacher.board(a.id)).value!;
      expect(
        [for (final r in board.rows) '${r.nickname}=${r.score}/${r.total}'],
        ["G'ayrat=5/5", "O'tkir=3/5", 'Lola=1/5'],
      );
      // Talaba ustoz panelini ko'rmaydi.
      expect(
        (await as(students.keys.first).board(a.id)).failure,
        GroupFailure.forbidden,
      );
      expect((await teacher.closeAssignment(a.id)).ok, isTrue);
      final after = (await as(students.keys.first).result(a.id)).value!;
      expect(after.revealed, isTrue);
      expect(after.items.every((it) => it.isCorrect == true), isTrue);
      // «Umumiy test»: ikki mavzu, navbatma-navbat (20 + 6 → 12 savolda 6/6).
      final mixed = (await teacher.createAssignment(
        g.id,
        AssignmentDraft(
          topicId: 'dart-tox',
          topics: const ['dart-tox', 'dart-co'],
          title: 'Umumiy test: Toks · CO',
          questionCount: 12,
          timeLimitMin: 10,
          dueAt: DateTime.now().add(const Duration(days: 1)),
        ),
      )).value!;
      expect(mixed.isMixed, isTrue);
      expect(mixed.topicTitle, 'Umumiy test: Toks · CO');
      expect(mixed.poolSize, 12);
      final mpool = (await teacher.preview(mixed.id)).value!.pool;
      expect(mpool.where((q) => q.text.startsWith('Dart CO')).length, 6);
      // ignore: avoid_print
      print('Dart e2e: ${transport.calls} RPC, ${board.rows.length} talaba');
    },
    skip: _host == null
        ? 'FE_LOCAL_PG_HOST yo‘q (lokal baza ko‘tarilmagan)'
        : false,
  );
}
