import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/flags.dart';
import '../domain/ports/qa_ports.dart';
import '../domain/qa/qa_models.dart';
import 'account.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa almashtiriladi.
final qaServiceProvider = Provider<QaService>(
  (ref) => const UnconfiguredQaService(),
);

/// Yig‘ish bayrog‘i `FE_QA` (testlarda almashtiriladi).
final qaFlagProvider = Provider<bool>((ref) => FeFlags.qaCommunity);

/// Bo‘lim ko‘rinadimi.
///
/// Uchta shart: bayroq (yoki admin — egasi sinovi uchun), server **ulangan**,
/// foydalanuvchi **kirgan**. Server ulanmagan bo‘lsa bo‘lim umuman
/// ko‘rsatilmaydi — ishlamaydigan ekran chiqmaydi.
final qaVisibleProvider = Provider<bool>((ref) {
  if (!ref.watch(qaServiceProvider).isConfigured) return false;
  if (!ref.watch(authStateProvider).signedIn) return false;
  if (ref.watch(qaFlagProvider)) return true;
  return ref.watch(serverAccessProvider).value?.isAdmin ?? false;
});

/// O‘z holati: profil, teglar, bugungi urinishlar, javob yozish huquqi.
final qaMeProvider = FutureProvider.autoDispose<QaMe?>((ref) async {
  if (!ref.watch(qaVisibleProvider)) return null;
  return ref.watch(qaServiceProvider).status();
});

/// Ro‘yxat so‘rovi: teg (`null` — hammasi) va qidiruv so‘zi.
typedef QaFeedQuery = ({String? tag, String? query});

const QaFeedQuery qaAllQuestions = (tag: null, query: null);

final qaFeedProvider = FutureProvider.autoDispose.family<QaFeed?, QaFeedQuery>((
  ref,
  q,
) async {
  if (!ref.watch(qaVisibleProvider)) return null;
  final query = (q.query ?? '').trim();
  return ref
      .watch(qaServiceProvider)
      .feed(tag: q.tag, query: query.isEmpty ? null : query);
});

final qaQuestionProvider = FutureProvider.autoDispose
    .family<QaQuestion?, String>((ref, id) async {
      if (!ref.watch(qaVisibleProvider)) return null;
      return ref.watch(qaServiceProvider).question(id);
    });

final qaMineProvider = FutureProvider.autoDispose<QaMine?>((ref) async {
  if (!ref.watch(qaVisibleProvider)) return null;
  return ref.watch(qaServiceProvider).mine();
});

/// Admin moderatsiya navbati — faqat admin uchun (server tekshiradi).
final qaModerationQueueProvider =
    FutureProvider.autoDispose<QaModerationQueue?>((ref) async {
      if (!ref.watch(qaVisibleProvider)) return null;
      final admin = ref.watch(serverAccessProvider).value?.isAdmin ?? false;
      if (!admin) return null;
      return ref.watch(qaServiceProvider).moderationQueue();
    });

/// Mashina tarjimasi: (nishon, id, til) uchun bir marta so‘raladi; server
/// tomonida ham keshlangan.
typedef QaTranslationRequest = ({QaTargetType target, String id, QaLang lang});

final qaTranslationProvider = FutureProvider.autoDispose
    .family<QaTranslation?, QaTranslationRequest>((ref, req) async {
      if (!ref.watch(qaVisibleProvider)) return null;
      return ref
          .watch(qaServiceProvider)
          .translate(target: req.target, id: req.id, lang: req.lang);
    });
