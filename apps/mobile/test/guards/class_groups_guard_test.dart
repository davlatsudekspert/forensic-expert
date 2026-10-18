import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_groups/fake_class_groups_service.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_groups/variant_draw.dart';

import '../unit/class_groups_test.dart' show loadVectors;

/// «Qorovul» testlari: «Ustoz–talaba testi»ning asosiy kafolatlari keyingi
/// o‘zgarishlarda jimgina buzilmasin. Bu test yiqilsa — o‘zgarish ataylab
/// bo‘lsa, server (SQL), ilova (Dart) va hujjat (docs/CLASS_GROUPS.md)
/// birga yangilanadi.
void main() {
  final sql = File('../../supabase/migrations/20261018050000_class_groups.sql')
      .readAsStringSync();

  String fn(String name) {
    final i = sql.indexOf('create function $name(');
    expect(i, greaterThanOrEqualTo(0), reason: '$name SQL’da yo‘q');
    return sql.substring(i, sql.indexOf(r'end $$;', i));
  }

  group('variant algoritmi', () {
    test(
      'qotirilgan qiymatlar (fixture qayta yasalsa ham algoritm o‘zgarmasin)',
      () {
        expect(
          drawVariant(
            assignmentId: '8d6f0a4e-1b2c-4d3e-9f80-112233445566',
            userId: '11111111-1111-4111-8111-111111111111',
            pool: [
              for (var i = 1; i <= 30; i++)
                '3f2a1c00-0000-4000-8000-${i.toString().padLeft(12, '0')}',
            ],
            count: 10,
          ).take(3),
          [
            '3f2a1c00-0000-4000-8000-000000000005',
            '3f2a1c00-0000-4000-8000-000000000013',
            '3f2a1c00-0000-4000-8000-000000000030',
          ],
        );
        expect(
          drawVariant(
            assignmentId: '00000000-0000-4000-8000-0000000000aa',
            userId: '11111111-1111-4111-8111-111111111111',
            pool: [
              for (var i = 1; i <= 12; i++) 'q${i.toString().padLeft(2, '0')}',
            ],
            count: 4,
          ),
          ['q01', 'q12', 'q07', 'q10'],
        );
      },
    );

    test('Dart == umumiy vektorlar (SQL testi ham shu faylni tekshiradi)', () {
      for (final c in loadVectors()) {
        expect(
          drawVariant(
            assignmentId: c['assignment_id']! as String,
            userId: c['user_id']! as String,
            pool: [for (final q in c['pool']! as List) q as String],
            count: c['n']! as int,
          ),
          [for (final q in c['expected']! as List) q as String],
        );
      }
      // SQL testi vektorlarni o‘qiydi (run_local.sh -v fixture=...).
      final t = File('../../supabase/tests/class_groups_test.sql')
          .readAsStringSync();
      expect(t, contains('variant draw == shared fixture'));
      expect(
        File('../../supabase/tests/run_local.sh').readAsStringSync(),
        contains('class_group_variant_vectors.json'),
      );
    });

    test('SQL: SHA-256("<assignmentId>:<userId>"), so‘ng seed:savolId', () {
      final d = sql.substring(
        sql.indexOf('create function private.group_variant_draw('),
        sql.indexOf(
          r'$$;',
          sql.indexOf('create function private.group_variant_draw(') + 200,
        ),
      );
      expect(
        d,
        contains("sha256(convert_to(p_assignment || ':' || p_user, 'UTF8'))"),
      );
      expect(d, contains("sha256(convert_to(s.seed || ':' || q, 'UTF8'))"));
      expect(d, contains('collate "C"'));
    });

    test('variant chegarasi: hovuz < 2 × N bo‘lsa server rad etadi', () {
      expect(variantAllowed(19, 10), isFalse);
      expect(
        fn('public.group_assignment_create'),
        contains('v_pool < 2 * p_count'),
      );
    });
  });

  group('anonim qo‘shilish yo‘q', () {
    test('SQL: group_join — auth.uid() shart, anon’dan EXECUTE olingan', () {
      final j = fn('public.group_join');
      expect(j, contains("if me is null then raise exception 'forbidden'"));
      expect(
        sql,
        contains(
          'revoke execute on function public.group_join(text, text, uuid) from public, anon;',
        ),
      );
      // Talaba API — har biri a’zolikni tekshiradi.
      for (final f in [
        'public.group_assignment_open',
        'public.group_assignment_save',
        'public.group_assignment_submit',
        'public.group_assignment_result',
      ]) {
        expect(fn(f), contains('private.group_assignment_member('), reason: f);
      }
    });

    test('ilova: kirmagan foydalanuvchi qo‘shila olmaydi', () async {
      final b = FakeClassGroupsBackend(
        topics: () async => const [],
        teachers: {'t'},
      );
      final g = b.create('t', 'Guruh').value!;
      final anon = FakeClassGroupsService(b, userIdOf: () => null);
      expect(
        (await anon.join(code: g.code!, nickname: 'Ali')).failure,
        GroupFailure.notSignedIn,
      );
    });
  });

  group('taxallus normalizatsiyasi', () {
    test('Dart: ’ ‘ ʻ ʼ ` ´ ′ → \'', () {
      expect(ClassNickname.apostrophes.runes.length, 7);
      for (final ch in ['’', '‘', 'ʻ', 'ʼ', '`', '´', '′']) {
        expect(ClassNickname.fold('G${ch}ayrat'), "G'ayrat", reason: ch);
      }
    });

    test(
      'SQL: nick_fold xuddi shu 7 belgi; laqab tekshiruvlari undan o‘tadi',
      () {
        final f = sql.substring(
          sql.indexOf('create function private.nick_fold('),
        );
        expect(f, contains(r"E'’‘ʻʼ`´′', repeat('''', 7)"));
        expect(sql, contains('t text := private.nick_fold(p);'));
        expect(sql, contains('base text := private.nick_fold(p_nick);'));
        expect(
          fn('public.group_join'),
          contains('private.nick_fold(p_nickname)'),
        );
      },
    );
  });

  group('maxfiylik va chegaralar', () {
    test(
      'to‘g‘ri javob faqat ochilgach; 200 chegara; ustoz faqat o‘z guruhi',
      () {
        expect(
          fn('public.group_assignment_result'),
          contains('when v_rev then'),
        );
        expect(fn('public.group_join'), contains('>= 200'));
        expect(fn('private.group_owned'), contains('g.teacher_id <> me'));
        expect(GroupRules.maxMembers, 200);
        expect(GroupRules.graceSeconds, 30);
        for (final ch in ['0', 'O', '1', 'I', 'L']) {
          expect(GroupCode.alphabet, isNot(contains(ch)));
        }
      },
    );
  });

  group('marshrutlar', () {
    test('guruh marshrutlari o‘rnida (router.dart bilan)', () {
      expect(Routes.groups, '/home/learn/groups');
      expect(Routes.groupLinkPrefix, '/g/');
      expect(Routes.group('g1'), '/home/learn/groups/g1');
      expect(Routes.groupAssign('g1'), '/home/learn/groups/g1/assign');
      expect(Routes.groupAssignment('g1', 'a1'), '/home/learn/groups/g1/a/a1');
      expect(Routes.groupBoard('g1', 'a1'), '/home/learn/groups/g1/a/a1/board');
      expect(
        Routes.groupPreview('g1', 'a1'),
        '/home/learn/groups/g1/a/a1/preview',
      );
      expect(Routes.groupTest('g1', 'a1'), '/home/learn/groups/g1/t/a1');
      expect(Routes.groupResult('g1', 'a1'), '/home/learn/groups/g1/r/a1');
      final r = File('lib/app/router.dart').readAsStringSync();
      for (final p in [
        "path: 'groups'",
        "path: ':gid'",
        "path: 'assign'",
        "path: 'a/:aid'",
        "path: 'board'",
        "path: 'preview'",
        "path: 't/:aid'",
        "path: 'r/:aid'",
        "path: 'join'",
        r"'${Routes.groupLinkPrefix}:code'",
      ]) {
        expect(r, contains(p), reason: p);
      }
      // Kutilayotgan taklif diskda (bootstrap) — ro‘yxatdan o‘tishda yo‘qolmaydi.
      expect(
        File('lib/app/bootstrap.dart').readAsStringSync(),
        contains('SharedPrefsPendingGroupInviteStore(prefs)'),
      );
    });
  });
}
