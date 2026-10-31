import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/teacher_card.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/teacher_card/teacher_card.dart';

/// Tarmoqning mahalliy nomi.
String teacherSocialName(AppLocalizations l, TeacherSocial s) => switch (s) {
  TeacherSocial.telegram => l.tcNetTelegram,
  TeacherSocial.instagram => l.tcNetInstagram,
  TeacherSocial.youtube => l.tcNetYoutube,
  TeacherSocial.facebook => l.tcNetFacebook,
  TeacherSocial.linkedin => l.tcNetLinkedin,
  TeacherSocial.tiktok => l.tcNetTiktok,
  TeacherSocial.website => l.tcNetWebsite,
};

/// Xizmat xatosining foydalanuvchiga tushunarli matni.
String teacherCardFailureText(AppLocalizations l, TeacherCardFailure f) =>
    switch (f) {
      TeacherCardFailure.notConfigured => l.tcErrNotConfigured,
      TeacherCardFailure.notSignedIn => l.tcErrSignIn,
      TeacherCardFailure.offline => l.tcErrOffline,
      TeacherCardFailure.forbidden => l.tcErrForbidden,
      TeacherCardFailure.server => l.tcErrServer,
      TeacherCardFailure.invalidName => l.tcErrName,
      TeacherCardFailure.invalidWorkplace => l.tcErrWorkplace,
      TeacherCardFailure.invalidBio => l.tcErrBio,
      TeacherCardFailure.invalidImage => l.tcErrImage,
      TeacherCardFailure.imageTooLarge => l.tcErrImageLarge,
      TeacherCardFailure.invalidSocial => l.tcErrSocial,
      TeacherCardFailure.hiddenByAdmin => l.tcErrHidden,
    };

/// Tarmoq belgisi: rangli yumaloq + oddiy ikonka yoki harf. Brend
/// logotiplari ishlatilmaydi (litsenziyasiz) — faqat Material ikonkalari
/// va bosh harflar.
class SocialBadge extends StatelessWidget {
  const SocialBadge({super.key, required this.social, this.size = 36});

  final TeacherSocial social;
  final double size;

  static Color colorOf(TeacherSocial s) => switch (s) {
    TeacherSocial.telegram => const Color(0xFF1C7FB2),
    TeacherSocial.instagram => const Color(0xFFB03275),
    TeacherSocial.youtube => const Color(0xFFC62A20),
    TeacherSocial.facebook => const Color(0xFF1767D2),
    TeacherSocial.linkedin => const Color(0xFF0A5A9C),
    TeacherSocial.tiktok => const Color(0xFF202124),
    TeacherSocial.website => const Color(0xFF4B6584),
  };

  @override
  Widget build(BuildContext context) {
    final letter = switch (social) {
      TeacherSocial.facebook => 'f',
      TeacherSocial.linkedin => 'in',
      _ => null,
    };
    final icon = switch (social) {
      TeacherSocial.telegram => Icons.send_rounded,
      TeacherSocial.instagram => Icons.photo_camera_outlined,
      TeacherSocial.youtube => Icons.play_arrow_rounded,
      TeacherSocial.tiktok => Icons.music_note_rounded,
      _ => Icons.language,
    };
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorOf(social),
          shape: BoxShape.circle,
        ),
        child: letter != null
            ? Text(
                letter,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.42,
                  height: 1,
                ),
              )
            : Icon(icon, color: Colors.white, size: size * 0.56),
      ),
    );
  }
}

/// Yumaloq ustoz rasmi: baytlar yoki Storage yo‘li bo‘yicha; yo‘q bo‘lsa
/// ismning bosh harfi.
class TeacherPhoto extends ConsumerWidget {
  const TeacherPhoto({
    super.key,
    required this.name,
    this.path,
    this.bytes,
    this.size = 56,
  });

  final String name;
  final String? path;
  final Uint8List? bytes;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    Uint8List? data = bytes;
    if (data == null && path != null) {
      data = ref.watch(teacherCardImageProvider(path!)).value;
    }
    final initial = name.trim().isEmpty
        ? '?'
        : String.fromCharCode(name.trim().runes.first).toUpperCase();
    return Semantics(
      label: l.tcPhotoSemantics(name),
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accentContainer,
            border: Border.all(color: c.border),
          ),
          child: data != null
              ? Image.memory(
                  data,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => _Initial(initial, size),
                )
              : _Initial(initial, size),
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial(this.letter, this.size);

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Text(
      letter,
      style: TextStyle(
        color: c.onAccentContainer,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.42,
        height: 1,
      ),
    );
  }
}

/// Ixcham «Ustoz kartasi» (talaba ko‘rinishi): rasm, ism, ish joyi (+logo),
/// «o‘zim haqimda», tarmoq belgilari. Belgi bosilganda havola tashqi ilovada
/// ochiladi — faqat ruxsat etilgan domen ([TeacherLinks.openable]).
class TeacherCardView extends ConsumerWidget {
  const TeacherCardView({
    super.key,
    required this.card,
    this.photoBytes,
    this.logoBytes,
    this.onReport,
  });

  final TeacherCard card;

  /// Tahrirlashda hali yuklanmagan rasm (ko‘rish uchun).
  final Uint8List? photoBytes;
  final Uint8List? logoBytes;

  /// `null` — shikoyat tugmasi ko‘rsatilmaydi (ustozning o‘z ko‘rinishi).
  final VoidCallback? onReport;

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    TeacherSocial s,
    String url,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final uri = TeacherLinks.openable(s, url);
    var ok = false;
    if (uri != null) {
      try {
        ok = await ref.read(teacherLinkOpenerProvider)(uri);
      } on Object {
        ok = false;
      }
    }
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(l.tcLinkOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final socials = [
      for (final s in TeacherSocial.values)
        if (card.socials[s] case final url?) (s, url),
    ];
    final hasLogo = card.logoPath != null || logoBytes != null;
    const photoSize = 88.0;
    const bandHeight = 64.0;
    return FeCard(
      key: const Key('tc.card'),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FeRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium sarlavha: brend rangidagi tasma, ustiga yumaloq rasm.
            SizedBox(
              height: bandHeight + photoSize / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: bandHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            c.brand,
                            Color.lerp(c.brand, c.accent, 0.35)!,
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (onReport != null)
                    Positioned(
                      top: FeSpace.xxs,
                      right: FeSpace.xxs,
                      child: IconButton(
                        key: const Key('tc.report'),
                        tooltip: l.tcReport,
                        visualDensity: VisualDensity.compact,
                        color: c.textOnBrand,
                        icon: const Icon(Icons.flag_outlined),
                        onPressed: onReport,
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: bandHeight - photoSize / 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.surfaceRaised,
                          border: Border.all(color: c.accent, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TeacherPhoto(
                          key: const Key('tc.photo'),
                          name: card.displayName,
                          path: card.photoPath,
                          bytes: photoBytes,
                          size: photoSize - 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FeSpace.md,
                FeSpace.xs,
                FeSpace.md,
                FeSpace.md,
              ),
              child: Column(
                children: [
                  Text(
                    l.tcStudentLabel.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: t.labelSmall?.copyWith(
                      color: c.accent,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    card.displayName,
                    key: const Key('tc.name'),
                    textAlign: TextAlign.center,
                    style: t.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (card.workplace.isNotEmpty || hasLogo) ...[
                    const SizedBox(height: FeSpace.xxs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasLogo) ...[
                          _Logo(path: card.logoPath, bytes: logoBytes),
                          const SizedBox(width: FeSpace.xs),
                        ],
                        if (card.workplace.isNotEmpty)
                          Flexible(
                            child: Text(
                              card.workplace,
                              key: const Key('tc.workplace'),
                              textAlign: TextAlign.center,
                              style: t.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (card.bio.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.sm),
                    Container(
                      width: 36,
                      height: 2,
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      card.bio,
                      key: const Key('tc.bio'),
                      textAlign: TextAlign.center,
                      style: t.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (socials.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.sm),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xs,
                      children: [
                        for (final (s, url) in socials)
                          Semantics(
                            button: true,
                            label: l.tcOpenLink(teacherSocialName(l, s)),
                            child: Tooltip(
                              message: l.tcOpenLink(teacherSocialName(l, s)),
                              child: InkResponse(
                                key: Key('tc.social.${s.key}'),
                                radius: 28,
                                onTap: () => _open(context, ref, s, url),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: Center(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: SocialBadge.colorOf(s)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: SocialBadge(social: s, size: 42),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends ConsumerWidget {
  const _Logo({this.path, this.bytes});

  final String? path;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    Uint8List? data = bytes;
    if (data == null && path != null) {
      data = ref.watch(teacherCardImageProvider(path!)).value;
    }
    if (data == null) return const SizedBox(width: 22, height: 22);
    return Semantics(
      label: l.tcLogoSemantics,
      image: true,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            data,
            key: const Key('tc.logo'),
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox(width: 22, height: 22),
          ),
        ),
      ),
    );
  }
}

/// Guruh sahifasi tepasidagi ustoz kartasi (talaba ko‘rinishi). Karta yo‘q,
/// yashirin yoki yuklanmasa — bo‘sh joy (sahifa buzilmaydi). «Shikoyat
/// qilish» mavjud «Taklif va murojaatlar» oqimiga o‘tadi (UGC talabi): ustoz
/// identifikatori murojaatga `teacher_card:<id>` sifatida biriktiriladi.
class GroupTeacherCard extends ConsumerWidget {
  const GroupTeacherCard({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(groupTeacherCardProvider(groupId)).value?.value;
    if (card == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: TeacherCardView(
        card: card,
        onReport: () => context.push(
          Routes.supportNewFor(
            category: 'GENERAL',
            entity: 'teacher_card:${card.teacherId}',
            title: card.displayName,
          ),
        ),
      ),
    );
  }
}
