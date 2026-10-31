import 'package:flutter/foundation.dart';

/// «Talaba kartasi» (1-bosqich): talaba guruhdoshlari va ustoziga ko‘rsatadigan
/// ixtiyoriy qisqa tanishtiruv (rasm, ism/taxallus, «o‘zim haqimda»).
/// HAVOLA, ijtimoiy tarmoq, layk, obuna va ommaviy ko‘rinish YO‘Q (talabalar
/// voyaga yetmagan bo‘lishi mumkin). Chegaralar va matn filtri
/// `supabase/migrations/20261031040000_student_card.sql` bilan bir xil;
/// asosiy to‘siq — SERVER, bu yerdagi tekshiruv foydalanuvchiga tez va
/// tushunarli xato berish uchun.
abstract final class StudentCardLimits {
  static const nameMin = 2;
  static const nameMax = 40;
  static const bioMax = 150;

  /// Rasm hajmi (Storage bucket cheklovi bilan bir xil).
  static const imageBytes = 1024 * 1024;
}

/// Maxfiy aloqa ma’lumoti filtri (server `private.student_card_text_ok`
/// nusxasi): havola (http, www, domen, t.me), `@` (email / @username),
/// ijtimoiy tarmoq nomlari va telefon raqami rad etiladi. Sodda filtr:
/// so‘z bilan yozilgan raqamni ushlamaydi — qolgan himoya shikoyat,
/// yashirish va moderatsiya.
abstract final class StudentCardText {
  static final _at = RegExp('[@＠]');
  static final _link = RegExp(r'http|://|\bwww\b|www\.');
  static final _domain = RegExp(
    r'[a-z0-9-]\s?\.\s?(com|net|org|uz|ru|me|io|ly|tv|gg|info|biz|xyz|app|dev|co|kz|tj|kg|edu|gov|by|ua|link|site|online|store|shop|page)\b',
  );
  static final _network = RegExp(
    r'telegram|instagram|whatsapp|tiktok|snapchat|facebook|youtube|телеграм|инстаграм|ватсап|вацап|вайбер|фейсбук|тикток|ютуб|\b(insta|viber|discord|wechat|skype|snap|tg|t\.me)\b',
  );
  static final _plus = RegExp(r'\+\s*\(?\s*[0-9]');
  static final _run = RegExp(r'[0-9][0-9 ().-]*[0-9]');
  static final _control = RegExp(r'[\u0001-\u001f\u007f]');
  static final _controlNoNl = RegExp(r'[\u0001-\u0009\u000b-\u001f\u007f]');

  /// `true` — matn aloqa ma’lumoti/havola o‘z ichiga olmaydi.
  static bool isClean(String text) {
    final t = text.toLowerCase();
    if (t.isEmpty) return true;
    if (_at.hasMatch(t) || _link.hasMatch(t) || _domain.hasMatch(t)) {
      return false;
    }
    if (_network.hasMatch(t) || _plus.hasMatch(t)) return false;
    for (final m in _run.allMatches(t)) {
      final run = m.group(0)!;
      final digits = run.replaceAll(RegExp('[^0-9]'), '').length;
      final groups = run.trim().split(RegExp('[^0-9]+')).length;
      if (digits >= 9 || (digits >= 7 && groups != 2)) return false;
    }
    return true;
  }

  static bool nameHasControl(String s) => _control.hasMatch(s);
  static bool bioHasControl(String s) => _controlNoNl.hasMatch(s);
}

String _str(Object? v, [String d = '']) => v is String ? v : d;

/// Serverdagi karta (ko‘ruvchi ko‘rinishi + egasi/ustoz uchun qo‘shimcha
/// maydonlar).
@immutable
class StudentCard {
  const StudentCard({
    required this.studentId,
    required this.displayName,
    this.bio = '',
    this.photoPath,
    this.visible = false,
    this.hiddenByAdmin = false,
    this.hiddenInGroups = 0,
    this.groupHidden = false,
    this.memberId,
  });

  factory StudentCard.fromJson(Map<String, Object?> j) => StudentCard(
    studentId: _str(j['student_id']),
    displayName: _str(j['display_name']),
    bio: _str(j['bio']),
    photoPath: j['photo_path'] is String ? j['photo_path']! as String : null,
    visible: j['visible'] == true,
    hiddenByAdmin: j['hidden_by_admin'] == true,
    hiddenInGroups: j['hidden_in_groups'] is num
        ? (j['hidden_in_groups']! as num).toInt()
        : 0,
    groupHidden: j['group_hidden'] == true,
    memberId: j['member_id'] is String ? j['member_id']! as String : null,
  );

  final String studentId;
  final String displayName;
  final String bio;

  /// Storage yo‘li (`<uid>/photo-<uuid>.png`); baytlar alohida yuklanadi.
  final String? photoPath;

  /// Faqat egasining o‘z javobida ma’noli.
  final bool visible;
  final bool hiddenByAdmin;

  /// Egasiga: ustoz(lar) kartani nechta guruhdan yashirgan.
  final int hiddenInGroups;

  /// Ustoz ko‘rinishida: karta shu guruhdan yashirilgan (moderatsiya).
  final bool groupHidden;

  /// Ustoz ko‘rinishida: `class_group_members.id` (a’zolar ro‘yxatiga moslash).
  final String? memberId;
}

/// Guruh kartalari: ko‘rinadiganlari + ko‘ruvchi o‘zi yashirganlarning id lari
/// (mazmunsiz).
@immutable
class StudentGroupCards {
  const StudentGroupCards({this.cards = const [], this.hiddenIds = const []});

  factory StudentGroupCards.fromJson(Map<String, Object?> j) {
    final cs = j['cards'];
    final hs = j['hidden_ids'];
    return StudentGroupCards(
      cards: [
        if (cs is List)
          for (final c in cs)
            if (c is Map) StudentCard.fromJson(c.cast<String, Object?>()),
      ],
      hiddenIds: [
        if (hs is List)
          for (final h in hs)
            if (h is String) h,
      ],
    );
  }

  final List<StudentCard> cards;
  final List<String> hiddenIds;

  bool get isEmpty => cards.isEmpty && hiddenIds.isEmpty;

  StudentCard? byMember(String memberId) {
    for (final c in cards) {
      if (c.memberId == memberId) return c;
    }
    return null;
  }
}

/// Talaba tahrirlayotgan karta (saqlashdan oldin).
@immutable
class StudentCardDraft {
  const StudentCardDraft({
    required this.displayName,
    this.bio = '',
    this.visible = false,
    this.photo,
    this.removePhoto = false,
  });

  final String displayName;
  final String bio;
  final bool visible;

  /// Yangi rasm (PNG/JPEG/WebP baytlari, ≤ 1 MB).
  final Uint8List? photo;
  final bool removePhoto;

  /// Mijoz tomondagi birinchi tekshiruv (server baribir qayta tekshiradi).
  StudentCardDraftError? get error {
    final name = displayName.trim();
    if (name.length < StudentCardLimits.nameMin ||
        name.length > StudentCardLimits.nameMax ||
        StudentCardText.nameHasControl(name)) {
      return StudentCardDraftError.name;
    }
    final b = bio.trim();
    if (b.length > StudentCardLimits.bioMax ||
        StudentCardText.bioHasControl(b)) {
      return StudentCardDraftError.bio;
    }
    if ((photo?.length ?? 0) > StudentCardLimits.imageBytes) {
      return StudentCardDraftError.image;
    }
    if (!StudentCardText.isClean(name)) {
      return StudentCardDraftError.contactName;
    }
    if (!StudentCardText.isClean(b)) return StudentCardDraftError.contactBio;
    return null;
  }
}

enum StudentCardDraftError { name, bio, image, contactName, contactBio }

/// Xizmat xatolari (server `{ok:false,error}` yoki HTTP holati).
enum StudentCardFailure {
  notConfigured,
  notSignedIn,
  offline,
  forbidden,
  server,
  invalidName,
  invalidBio,
  invalidImage,
  imageTooLarge,
  contactInfo,
  hiddenByAdmin,
  limit,
  notFound;

  static StudentCardFailure fromServer(Object? code) => switch (code) {
    'invalid_name' => invalidName,
    'invalid_bio' => invalidBio,
    'invalid_photo' => invalidImage,
    'contact_info' => contactInfo,
    'hidden_by_admin' => hiddenByAdmin,
    'limit' => limit,
    'not_found' => notFound,
    _ => server,
  };

  static StudentCardFailure fromDraft(StudentCardDraftError e) => switch (e) {
    StudentCardDraftError.name => invalidName,
    StudentCardDraftError.bio => invalidBio,
    StudentCardDraftError.image => imageTooLarge,
    StudentCardDraftError.contactName ||
    StudentCardDraftError.contactBio => contactInfo,
  };
}

@immutable
class StudentCardResult<T> {
  const StudentCardResult.ok(T this.value) : failure = null;
  const StudentCardResult.fail(StudentCardFailure this.failure) : value = null;

  final T? value;
  final StudentCardFailure? failure;
  bool get ok => failure == null;
}
