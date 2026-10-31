import 'package:flutter/foundation.dart';

/// «Ustoz kartasi»: ustoz o‘z guruhlari a’zolariga ko‘rsatadigan qisqa
/// ma’lumot (rasm, ism, ish joyi, «o‘zim haqimda», tarmoq havolalari).
/// Server chegaralari va havola qoidalari
/// `supabase/migrations/20261031020000_teacher_card.sql` bilan bir xil
/// (`private.teacher_card_url_ok`); asosiy to‘siq — SERVER, bu yerdagi
/// tekshiruv foydalanuvchiga tez va tushunarli xato berish hamda
/// ruxsat etilmagan havolani hech qachon ochmaslik uchun.
abstract final class TeacherCardLimits {
  static const nameMin = 2;
  static const nameMax = 60;
  static const workplaceMax = 120;
  static const bioMax = 300;
  static const urlMax = 255;

  /// Rasm/logotip hajmi (Storage bucket cheklovi bilan bir xil).
  static const imageBytes = 1024 * 1024;
}

/// Ijtimoiy tarmoqlar. [key] — serverdagi `socials` JSON kaliti.
enum TeacherSocial {
  telegram('telegram', ['t.me', 'telegram.me'], 'https://t.me/'),
  instagram('instagram', [
    'instagram.com',
    'www.instagram.com',
  ], 'https://instagram.com/'),
  youtube('youtube', [
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'youtu.be',
  ], 'https://youtube.com/'),
  facebook('facebook', [
    'facebook.com',
    'www.facebook.com',
    'm.facebook.com',
  ], 'https://facebook.com/'),
  linkedin('linkedin', [
    'linkedin.com',
    'www.linkedin.com',
  ], 'https://www.linkedin.com/in/'),
  tiktok('tiktok', [
    'tiktok.com',
    'www.tiktok.com',
  ], 'https://www.tiktok.com/@'),
  website('website', [], null);

  const TeacherSocial(this.key, this.hosts, this.usernameBase);

  final String key;

  /// Ruxsat etilgan domenlar (aniq moslik). `website` uchun bo‘sh — istalgan
  /// https domen.
  final List<String> hosts;

  /// «@username» → havola (null — username qabul qilinmaydi).
  final String? usernameBase;

  static TeacherSocial? fromKey(String key) {
    for (final s in values) {
      if (s.key == key) return s;
    }
    return null;
  }
}

/// Havolani normallashtirish va xavfsiz ochish qoidalari.
abstract final class TeacherLinks {
  static final _username = RegExp(r'^[A-Za-z0-9._-]{2,64}$');
  static final _host = RegExp(
    r'^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z][a-z0-9-]{1,23}$',
  );
  static final _bad = RegExp(r'''[\s\u0000-\u001f\u007f<>"'\\]''');
  static final _scheme = RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:');

  /// Foydalanuvchi kiritganidan (to‘liq havola, `t.me/ism`, `@ism`)
  /// serverga yuboriladigan `https://…` havolani yasaydi. Yaroqsiz bo‘lsa
  /// `null`. Bo‘sh matn — `''` (maydon bo‘sh).
  static String? normalize(TeacherSocial social, String raw) {
    var s = raw.trim();
    if (s.isEmpty) return '';
    if (_bad.hasMatch(s)) return null;
    // @username → platforma havolasi (faqat username qabul qiladigan tarmoq).
    if (s.startsWith('@')) {
      final base = social.usernameBase;
      final name = s.substring(1);
      if (base == null || !_username.hasMatch(name)) return null;
      return _ok(social, '$base$name');
    }
    if (_scheme.hasMatch(s)) {
      // Faqat https. «javascript:», «data:», «http:», «ftp:» … rad.
      if (!s.toLowerCase().startsWith('https://')) return null;
      s = 'https://${s.substring(8)}';
      return _ok(social, s);
    }
    if (s.startsWith('//')) return null;
    // «t.me/ism», «instagram.com/ism», «forensic.uz».
    if (s.contains('.')) {
      final u = _ok(social, 'https://$s');
      if (u != null) return u;
    }
    // Oddiy username («ism», «ism.familiya»): faqat username qabul qiladigan
    // tarmoq; natija baribir shu tarmoqning o‘z domenida bo‘ladi.
    final base = social.usernameBase;
    if (base != null && _username.hasMatch(s)) {
      return _ok(social, '$base$s');
    }
    return null;
  }

  static String? _ok(TeacherSocial social, String url) =>
      isAllowed(social, url) ? url : null;

  /// Havola shu tarmoq uchun ruxsat etilganmi (server qoidasi nusxasi).
  static bool isAllowed(TeacherSocial social, String url) {
    if (url.length > TeacherCardLimits.urlMax) return false;
    if (_bad.hasMatch(url)) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.hasPort) return false;
    if (uri.userInfo.isNotEmpty) return false;
    final host = uri.host.toLowerCase();
    if (!_host.hasMatch(host)) return false;
    // «https://host?x» (yo‘lsiz so‘rov) serverda rad etiladi.
    final rest = url.substring(8 + uri.host.length);
    if (rest.isNotEmpty && !rest.startsWith('/')) return false;
    if (social == TeacherSocial.website) return true;
    return social.hosts.contains(host);
  }

  /// Ochishdan oldingi oxirgi tekshiruv: faqat shu tarmoq uchun ruxsat
  /// etilgan https havola ochiladi.
  static Uri? openable(TeacherSocial social, String url) =>
      isAllowed(social, url) ? Uri.parse(url) : null;

  /// Kartani ko‘rsatishga yaroqli havolalar (server noto‘g‘ri narsa
  /// qaytarsa ham ikonka ko‘rinmaydi).
  static Map<TeacherSocial, String> safe(Map<String, Object?> raw) {
    final out = <TeacherSocial, String>{};
    for (final s in TeacherSocial.values) {
      final v = raw[s.key];
      if (v is String && isAllowed(s, v)) out[s] = v;
    }
    return out;
  }
}

String _str(Object? v, [String d = '']) => v is String ? v : d;

/// Serverdagi karta (talaba ko‘rinishi + egasi uchun qo‘shimcha maydonlar).
@immutable
class TeacherCard {
  const TeacherCard({
    required this.teacherId,
    required this.displayName,
    this.workplace = '',
    this.bio = '',
    this.photoPath,
    this.logoPath,
    this.socials = const {},
    this.visible = false,
    this.hiddenByAdmin = false,
  });

  final String teacherId;
  final String displayName;
  final String workplace;
  final String bio;

  /// Storage yo‘li (`<uid>/photo-<uuid>.png`); rasm baytlari alohida yuklanadi.
  final String? photoPath;
  final String? logoPath;
  final Map<TeacherSocial, String> socials;

  /// Faqat egasining o‘z javobida ma’noli (talabaga server bermaydi).
  final bool visible;
  final bool hiddenByAdmin;

  factory TeacherCard.fromJson(Map<String, Object?> j) {
    final soc = j['socials'];
    return TeacherCard(
      teacherId: _str(j['teacher_id']),
      displayName: _str(j['display_name']),
      workplace: _str(j['workplace']),
      bio: _str(j['bio']),
      photoPath: j['photo_path'] is String ? j['photo_path']! as String : null,
      logoPath: j['logo_path'] is String ? j['logo_path']! as String : null,
      socials: TeacherLinks.safe(
        soc is Map ? soc.cast<String, Object?>() : const {},
      ),
      visible: j['visible'] == true,
      hiddenByAdmin: j['hidden_by_admin'] == true,
    );
  }

  Map<String, Object?> socialsJson() => {
    for (final e in socials.entries) e.key.key: e.value,
  };
}

/// Ustoz tahrirlayotgan karta (saqlashdan oldin). Rasm baytlari faqat
/// o‘zgargan bo‘lsa to‘ldiriladi.
@immutable
class TeacherCardDraft {
  const TeacherCardDraft({
    required this.displayName,
    this.workplace = '',
    this.bio = '',
    this.socials = const {},
    this.visible = false,
    this.photo,
    this.logo,
    this.removePhoto = false,
    this.removeLogo = false,
  });

  final String displayName;
  final String workplace;
  final String bio;
  final Map<TeacherSocial, String> socials;
  final bool visible;

  /// Yangi rasm (PNG/JPEG baytlari, ≤ 1 MB).
  final Uint8List? photo;
  final Uint8List? logo;
  final bool removePhoto;
  final bool removeLogo;

  /// Mijoz tomondagi birinchi tekshiruv (server baribir qayta tekshiradi).
  TeacherCardDraftError? get error {
    final n = displayName.trim().length;
    if (n < TeacherCardLimits.nameMin || n > TeacherCardLimits.nameMax) {
      return TeacherCardDraftError.name;
    }
    if (workplace.trim().length > TeacherCardLimits.workplaceMax) {
      return TeacherCardDraftError.workplace;
    }
    if (bio.trim().length > TeacherCardLimits.bioMax) {
      return TeacherCardDraftError.bio;
    }
    if ((photo?.length ?? 0) > TeacherCardLimits.imageBytes ||
        (logo?.length ?? 0) > TeacherCardLimits.imageBytes) {
      return TeacherCardDraftError.image;
    }
    for (final e in socials.entries) {
      if (!TeacherLinks.isAllowed(e.key, e.value)) {
        return TeacherCardDraftError.social;
      }
    }
    return null;
  }
}

enum TeacherCardDraftError { name, workplace, bio, image, social }

/// Xizmat xatolari (server `{ok:false,error}` yoki HTTP holati).
enum TeacherCardFailure {
  notConfigured,
  notSignedIn,
  offline,
  forbidden,
  server,
  invalidName,
  invalidWorkplace,
  invalidBio,
  invalidImage,
  invalidSocial,
  hiddenByAdmin,
  imageTooLarge;

  static TeacherCardFailure fromServer(Object? code) => switch (code) {
    'invalid_name' => invalidName,
    'invalid_workplace' => invalidWorkplace,
    'invalid_bio' => invalidBio,
    'invalid_photo' || 'invalid_logo' => invalidImage,
    'invalid_social' => invalidSocial,
    'hidden_by_admin' => hiddenByAdmin,
    _ => server,
  };
}

@immutable
class TeacherCardResult<T> {
  const TeacherCardResult.ok(T this.value) : failure = null;
  const TeacherCardResult.fail(TeacherCardFailure this.failure) : value = null;

  final T? value;
  final TeacherCardFailure? failure;
  bool get ok => failure == null;
}

/// Rasm turi (bayt boshidan): server faqat jpeg/png/webp qabul qiladi.
enum TeacherImageKind {
  jpeg('jpg', 'image/jpeg'),
  png('png', 'image/png'),
  webp('webp', 'image/webp');

  const TeacherImageKind(this.ext, this.mime);

  final String ext;
  final String mime;

  static TeacherImageKind? of(Uint8List b) {
    if (b.length >= 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return png;
    }
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return jpeg;
    }
    if (b.length >= 12 &&
        b[0] == 0x52 && // R
        b[1] == 0x49 && // I
        b[2] == 0x46 && // F
        b[3] == 0x46 && // F
        b[8] == 0x57 && // W
        b[9] == 0x45 && // E
        b[10] == 0x42 && // B
        b[11] == 0x50) {
      // P
      return webp;
    }
    return null;
  }
}
