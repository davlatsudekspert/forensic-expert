import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ports/student_card_ports.dart';
import '../domain/student_card/student_card.dart';
import 'providers.dart';

/// Bootstrap’da Supabase sozlangan bo‘lsa [SupabaseStudentCardService] bilan
/// almashtiriladi; aks holda ulanmagan (karta bo‘limi ko‘rinmaydi).
final studentCardServiceProvider = Provider<StudentCardService>(
  (ref) => const UnconfiguredStudentCardService(),
);

/// Talabaning o‘z kartasi (Profil → «Talaba kartam»).
final myStudentCardProvider =
    FutureProvider.autoDispose<StudentCardResult<StudentCard?>>((ref) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(studentCardServiceProvider).mine();
    });

/// Guruh sahifasidagi ko‘rinadigan guruhdosh kartalari (server qoidasi:
/// yashirilganlar kelmaydi).
final groupStudentCardsProvider = FutureProvider.autoDispose
    .family<StudentCardResult<StudentGroupCards>, String>((ref, groupId) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(studentCardServiceProvider).forGroup(groupId);
    });

/// Karta rasmi (Storage RLS orqali). Fayl nomi har yangi rasmda yangi
/// bo‘lgani uchun natija xavfsiz keshlanadi.
final studentCardImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, path) {
      ref.watch(authStateProvider.select((s) => s.userId));
      return ref.watch(studentCardServiceProvider).image(path);
    });
