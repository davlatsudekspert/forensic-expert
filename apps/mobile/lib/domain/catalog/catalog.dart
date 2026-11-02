import 'package:flutter/foundation.dart';

import '../teacher_card/teacher_card.dart';

/// «Ustozlar va mutaxassislar» katalogi turi.
enum CatalogKind {
  teacher('teacher'),
  expert('expert');

  const CatalogKind(this.wire);

  final String wire;
}

/// Katalog yozuvi (`catalog_list`). Yulduzcha soni — server sanog‘i;
/// kim bosgani hech kimga berilmaydi.
@immutable
class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.kind,
    required this.name,
    this.subtitle = '',
    this.category,
    this.bio = '',
    this.photoPath,
    this.coverPath,
    this.verified = false,
    this.founder = false,
    this.socials = const {},
    this.stars = 0,
    this.starred = false,
    this.mine = false,
  });

  final String id;
  final CatalogKind kind;
  final String name;
  final String subtitle;
  final TeacherCategory? category;
  final String bio;
  final String? photoPath;

  /// Fon (cover) rasmi yo‘li (faqat ustozlar; ixtiyoriy).
  final String? coverPath;

  /// Tasdiqlangan mutaxassis (server belgisi); ustozlarda `false`.
  final bool verified;

  /// Asoschi belgisi (faqat admin serverda qo‘yadi).
  final bool founder;
  final Map<TeacherSocial, String> socials;
  final int stars;
  final bool starred;

  /// O‘zimning yozuvim (o‘zimga yulduzcha bosib bo‘lmaydi).
  final bool mine;

  CatalogEntry copyWith({int? stars, bool? starred}) => CatalogEntry(
    id: id,
    kind: kind,
    name: name,
    subtitle: subtitle,
    category: category,
    bio: bio,
    photoPath: photoPath,
    coverPath: coverPath,
    verified: verified,
    founder: founder,
    socials: socials,
    stars: stars ?? this.stars,
    starred: starred ?? this.starred,
    mine: mine,
  );

  /// Ko‘rinish uchun ustoz kartasi (rasm, tarmoqlar vidjetlari qayta ishlatiladi).
  TeacherCard toCard() => TeacherCard(
    teacherId: id,
    displayName: name,
    workplace: subtitle,
    category: category,
    bio: bio,
    photoPath: photoPath,
    coverPath: coverPath,
    founder: founder,
    socials: socials,
  );

  static CatalogEntry? tryParse(Map<String, Object?> j) {
    final id = j['id'];
    final name = j['name'];
    if (id is! String || name is! String || name.isEmpty) return null;
    String s(Object? v) => v is String ? v : '';
    final soc = j['socials'];
    final photo = s(j['photo_path']);
    final cover = s(j['cover_path']);
    return CatalogEntry(
      id: id,
      kind: j['kind'] == 'expert' ? CatalogKind.expert : CatalogKind.teacher,
      name: name,
      subtitle: s(j['subtitle']),
      category: TeacherCategory.parse(j['category']),
      bio: s(j['bio']),
      photoPath: photo.isEmpty ? null : photo,
      coverPath: cover.isEmpty ? null : cover,
      verified: j['verified'] == true,
      founder: j['founder'] == true,
      socials: TeacherLinks.safe(
        soc is Map ? soc.cast<String, Object?>() : const {},
      ),
      stars: j['stars'] is num ? (j['stars']! as num).toInt() : 0,
      starred: j['starred'] == true,
      mine: j['mine'] == true,
    );
  }
}

/// O‘z holatim: yulduzchalarim soni va katalog roziliklari.
@immutable
class CatalogMe {
  const CatalogMe({
    this.stars = 0,
    this.teacherCatalog = false,
    this.expertCatalog = false,
    this.expertEligible = false,
    this.expertVerified = false,
  });

  static const empty = CatalogMe();

  final int stars;
  final bool teacherCatalog;
  final bool expertCatalog;

  /// Kasbiy profili bor (tasdiqlangan bo‘lishi shart emas).
  final bool expertEligible;

  /// Kasbiy profili tasdiqlangan (ismi yonida belgi chiqadi).
  final bool expertVerified;

  factory CatalogMe.fromJson(Map<String, Object?> j) => CatalogMe(
    stars: j['stars'] is num ? (j['stars']! as num).toInt() : 0,
    teacherCatalog: j['teacher_catalog'] == true,
    expertCatalog: j['expert_catalog'] == true,
    expertEligible: j['expert_eligible'] == true,
    expertVerified: j['expert_verified'] == true,
  );
}

enum CatalogFailure { notConfigured, notSignedIn, offline, notFound, server }

@immutable
class CatalogResult<T> {
  const CatalogResult.ok(T this.value) : failure = null;
  const CatalogResult.fail(CatalogFailure this.failure) : value = null;

  final T? value;
  final CatalogFailure? failure;

  bool get ok => failure == null;
}

/// Katalog servisi (Supabase yoki soxta).
abstract interface class CatalogService {
  bool get isConfigured;

  Future<CatalogResult<List<CatalogEntry>>> list(
    CatalogKind kind, {
    String? query,
  });

  /// Yulduzcha bosish/qaytarish → (bosilganmi, jami).
  Future<CatalogResult<(bool, int)>> toggleStar(String targetId);

  Future<CatalogResult<CatalogMe>> me();

  Future<CatalogResult<void>> setVisible(CatalogKind kind, bool on);
}

class UnconfiguredCatalogService implements CatalogService {
  const UnconfiguredCatalogService();

  @override
  bool get isConfigured => false;

  @override
  Future<CatalogResult<List<CatalogEntry>>> list(
    CatalogKind kind, {
    String? query,
  }) async => const CatalogResult.fail(CatalogFailure.notConfigured);

  @override
  Future<CatalogResult<(bool, int)>> toggleStar(String targetId) async =>
      const CatalogResult.fail(CatalogFailure.notConfigured);

  @override
  Future<CatalogResult<CatalogMe>> me() async =>
      const CatalogResult.fail(CatalogFailure.notConfigured);

  @override
  Future<CatalogResult<void>> setVisible(CatalogKind kind, bool on) async =>
      const CatalogResult.fail(CatalogFailure.notConfigured);
}
