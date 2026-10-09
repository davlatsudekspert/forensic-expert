import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/settings_controller.dart';
import '../domain/court_prep/court_prep_models.dart';
import '../domain/ports/billing_ports.dart';
import 'providers.dart';

/// «Sudda so‘roq: tayyorgarlik» paketi (ilovaga qo‘shilgan, oflayn).
const courtPrepAsset = 'assets/content/court_prep/court_prep_v1.json';

final courtPrepLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(courtPrepAsset),
);

final courtPrepProvider = FutureProvider<CourtPrepBundle>((ref) async {
  try {
    final text = await ref.watch(courtPrepLoaderProvider)();
    return CourtPrepBundle.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>(),
    );
  } on Object {
    // Buzilgan yoki yo‘q paket — bo‘sh bo‘lim (soxta kontent yo‘q).
    return CourtPrepBundle.empty;
  }
});

/// Mutaxassis Pro: kengaytirilgan simulyator, rol mashqlari, AI tahlili
/// (ulanmagan — «tez orada»), shaxsiy statistika va tarix. Savol-javob
/// kartalari (A–I, manbalar bilan), mashq rejimi, halollik tamoyillari va
/// asosiy ssenariylar — hamma uchun bepul.
final courtPrepUnlockedProvider = Provider<bool>(
  (ref) => AccessPolicy.unlocks(
    ProductFeature.courtTestimonyPrep,
    ref.watch(accessProvider),
  ),
);

/// Bootstrap’da SharedPreferences bilan override qilinadi (faqat lokal).
final courtHistoryStoreProvider = Provider<CourtHistoryStore>(
  (ref) => InMemoryCourtHistoryStore(),
);

final courtHistoryProvider =
    NotifierProvider<CourtHistoryController, List<CourtAttempt>>(
      CourtHistoryController.new,
    );

/// Shaxsiy tayyorgarlik tarixi (Pro) — faqat qurilmada saqlanadi.
class CourtHistoryController extends Notifier<List<CourtAttempt>> {
  @override
  List<CourtAttempt> build() => ref.read(courtHistoryStoreProvider).load();

  Future<void> record(CourtAttempt attempt) async {
    state = [...state, attempt];
    await ref.read(courtHistoryStoreProvider).save(state);
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(courtHistoryStoreProvider).save(state);
  }
}

/// Huquqiy savollar uchun yurisdiksiya: O‘zbekiston tanlangan bo‘lsa —
/// O‘zbekiston qonunlari bo‘yicha, aks holda umumiy xalqaro savollar.
final courtUzbekistanProvider = Provider<bool>(
  (ref) =>
      ref.watch(settingsControllerProvider.select((s) => s.jurisdictionId)) ==
      'UZ',
);
