import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/ports/teacher_card_ports.dart';
import '../domain/teacher_card/teacher_card.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseTeacherCardService] bilan
/// almashtiriladi; aks holda ulanmagan (karta bo‘limi ko‘rinmaydi).
final teacherCardServiceProvider = Provider<TeacherCardService>(
  (ref) => const UnconfiguredTeacherCardService(),
);

/// Ustozning o‘z kartasi (Profil → «Ustoz kartam»).
final myTeacherCardProvider =
    FutureProvider.autoDispose<TeacherCardResult<TeacherCard?>>((ref) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(teacherCardServiceProvider).mine();
    });

/// Guruh sahifasidagi «Ustoz kartasi» (talaba ko‘rinishi). Server karta
/// yo‘q/yashirin bo‘lsa `null` qaytaradi.
final groupTeacherCardProvider = FutureProvider.autoDispose
    .family<TeacherCardResult<TeacherCard?>, String>((ref, groupId) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(teacherCardServiceProvider).forGroup(groupId);
    });

/// Karta rasmi (Storage RLS orqali). Fayl nomi har yangi rasmda yangi
/// bo‘lgani uchun natija xavfsiz keshlanadi; sahifa yopilsa tozalanadi.
final teacherCardImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, path) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(teacherCardServiceProvider).image(path);
    });

/// Havolani tashqi ilovada ochish (testlarda almashtiriladi). Chaqirishdan
/// oldin HAR DOIM [TeacherLinks.openable] tekshiriladi.
typedef TeacherLinkOpener = Future<bool> Function(Uri uri);

final teacherLinkOpenerProvider = Provider<TeacherLinkOpener>(
  (ref) =>
      (uri) async => launchUrl(uri, mode: LaunchMode.externalApplication),
);
