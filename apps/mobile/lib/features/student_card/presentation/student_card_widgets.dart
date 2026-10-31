import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/student_card.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/student_card/student_card.dart';

/// Xizmat xatosining foydalanuvchiga tushunarli matni.
String studentCardFailureText(AppLocalizations l, StudentCardFailure f) =>
    switch (f) {
      StudentCardFailure.notConfigured => l.scdErrNotConfigured,
      StudentCardFailure.notSignedIn => l.scdErrSignIn,
      StudentCardFailure.offline => l.scdErrOffline,
      StudentCardFailure.forbidden => l.scdErrForbidden,
      StudentCardFailure.server => l.scdErrServer,
      StudentCardFailure.invalidName => l.scdErrName,
      StudentCardFailure.invalidBio => l.scdErrBio,
      StudentCardFailure.invalidImage => l.scdErrImage,
      StudentCardFailure.imageTooLarge => l.scdErrImageLarge,
      StudentCardFailure.contactInfo => l.scdErrContact,
      StudentCardFailure.hiddenByAdmin => l.scdAdminHidden,
      StudentCardFailure.limit => l.scdErrLimit,
      StudentCardFailure.notFound => l.scdErrNotFound,
    };

/// Yumaloq talaba rasmi: baytlar yoki Storage yo‘li bo‘yicha; yo‘q bo‘lsa
/// ismning bosh harfi.
class StudentPhoto extends ConsumerWidget {
  const StudentPhoto({
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
      data = ref.watch(studentCardImageProvider(path!)).value;
    }
    final initial = name.trim().isEmpty
        ? '?'
        : String.fromCharCode(name.trim().runes.first).toUpperCase();
    final letter = Text(
      initial,
      style: TextStyle(
        color: c.onAccentContainer,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.42,
        height: 1,
      ),
    );
    return Semantics(
      label: l.scdPhotoSemantics(name),
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
                  errorBuilder: (_, _, _) => letter,
                )
              : letter,
        ),
      ),
    );
  }
}

/// Ixcham «Talaba kartasi»: rasm, ism, «o‘zim haqimda». Havola yoki tugma
/// YO‘Q (amallar [showStudentCardSheet] da).
class StudentCardView extends StatelessWidget {
  const StudentCardView({
    super.key,
    required this.card,
    this.photoBytes,
    this.showLabel = true,
  });

  final StudentCard card;

  /// Tahrirlashda hali yuklanmagan rasm (ko‘rish uchun).
  final Uint8List? photoBytes;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('scd.card'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentPhoto(
                key: const Key('scd.photo'),
                name: card.displayName,
                path: card.photoPath,
                bytes: photoBytes,
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLabel)
                      Text(
                        l.scdLabel,
                        style: t.labelSmall?.copyWith(color: c.textSecondary),
                      ),
                    Text(
                      card.displayName,
                      key: const Key('scd.name'),
                      style: t.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (card.bio.isNotEmpty) ...[
            const SizedBox(height: FeSpace.xs),
            Text(card.bio, key: const Key('scd.bio'), style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Kichik faqat o‘qiladigan karta oynasi: karta + «Shikoyat qilish»,
/// «Bu kartani yashirish» (har bir ko‘ruvchi o‘zi uchun) va — guruh ustozi
/// uchun — «Guruhdan yashirish / qaytarish». Shikoyat mavjud «Taklif va
/// murojaatlar» oqimiga o‘tadi (`related_entity = student_card:<id>`).
Future<void> showStudentCardSheet(
  BuildContext context,
  WidgetRef ref, {
  required StudentCard card,
  required String groupId,
  required bool isTeacher,
}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final service = ref.read(studentCardServiceProvider);
  final action = await showModalBottomSheet<_SheetAction>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final c = FeTheme.of(ctx);
      final t = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            0,
            FeSpace.md,
            FeSpace.md,
          ),
          child: ListView(
            key: const Key('scd.sheet'),
            shrinkWrap: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              StudentCardView(card: card),
              if (isTeacher && card.groupHidden)
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xs),
                  child: Text(
                    l.scdGroupHiddenLabel,
                    key: const Key('scd.groupHiddenLabel'),
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                  ),
                ),
              const SizedBox(height: FeSpace.xs),
              OutlinedButton.icon(
                key: const Key('scd.report'),
                onPressed: () => Navigator.of(ctx).pop(_SheetAction.report),
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.scdSheetReport),
              ),
              const SizedBox(height: FeSpace.xs),
              OutlinedButton.icon(
                key: const Key('scd.hideForMe'),
                onPressed: () => Navigator.of(ctx).pop(_SheetAction.hide),
                icon: const Icon(Icons.visibility_off_outlined),
                label: Text(l.scdSheetHide),
              ),
              Padding(
                padding: const EdgeInsets.only(top: FeSpace.xxs),
                child: Text(
                  l.scdSheetHideNote,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
              if (isTeacher) ...[
                const SizedBox(height: FeSpace.sm),
                OutlinedButton.icon(
                  key: const Key('scd.groupHide'),
                  onPressed: () => Navigator.of(ctx).pop(
                    card.groupHidden
                        ? _SheetAction.groupShow
                        : _SheetAction.groupHide,
                  ),
                  icon: Icon(
                    card.groupHidden
                        ? Icons.visibility_outlined
                        : Icons.block_outlined,
                  ),
                  label: Text(
                    card.groupHidden
                        ? l.scdSheetGroupUnhide
                        : l.scdSheetGroupHide,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xxs),
                  child: Text(
                    l.scdSheetGroupNote,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
  if (action == null) return;
  switch (action) {
    case _SheetAction.report:
      unawaited(
        router.push(
          Routes.supportNewFor(
            category: 'GENERAL',
            entity: 'student_card:${card.studentId}',
            title: card.displayName,
          ),
        ),
      );
    case _SheetAction.hide:
      final r = await service.hideForMe(card.studentId);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            r.ok ? l.scdHiddenToast : studentCardFailureText(l, r.failure!),
          ),
        ),
      );
      ref.invalidate(groupStudentCardsProvider(groupId));
    case _SheetAction.groupHide || _SheetAction.groupShow:
      final hide = action == _SheetAction.groupHide;
      final r = await service.hideInGroup(groupId, card.studentId, hide: hide);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            r.ok
                ? (hide ? l.scdGroupHiddenToast : l.scdGroupShownToast)
                : studentCardFailureText(l, r.failure!),
          ),
        ),
      );
      ref.invalidate(groupStudentCardsProvider(groupId));
  }
}

enum _SheetAction { report, hide, groupHide, groupShow }

/// Guruh sahifasi (talaba ko‘rinishi): ko‘rinadigan guruhdosh kartalari.
/// Karta yo‘q/xato bo‘lsa — hech narsa ko‘rinmaydi (sahifa buzilmaydi).
/// Karta bosilsa kichik oyna ochiladi.
class GroupStudentCards extends ConsumerWidget {
  const GroupStudentCards({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cards = ref.watch(groupStudentCardsProvider(groupId)).value?.value;
    if (cards == null || cards.cards.isEmpty) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.scdGroupSection),
        for (final card in cards.cards)
          Semantics(
            button: true,
            label: l.scdOpenCard(card.displayName),
            excludeSemantics: true,
            child: ListTile(
              key: Key('scd.mate.${card.studentId}'),
              contentPadding: EdgeInsets.zero,
              leading: StudentPhoto(
                name: card.displayName,
                path: card.photoPath,
                size: 40,
              ),
              title: Text(
                card.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: card.bio.isEmpty
                  ? null
                  : Text(
                      card.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showStudentCardSheet(
                context,
                ref,
                card: card,
                groupId: groupId,
                isTeacher: false,
              ),
            ),
          ),
      ],
    );
  }
}

/// Ko‘ruvchi o‘zi yashirgan kartalar («Yashirilgan karta · Qaytarish»);
/// hech qanday shaxsiy ma’lumot ko‘rsatilmaydi. Yashirilgani yo‘q bo‘lsa —
/// bo‘sh joy.
class GroupHiddenStudentCards extends ConsumerWidget {
  const GroupHiddenStudentCards({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cards = ref.watch(groupStudentCardsProvider(groupId)).value?.value;
    if (cards == null || cards.hiddenIds.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.scdHiddenSection),
        for (final id in cards.hiddenIds)
          ListTile(
            key: Key('scd.hidden.$id'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.visibility_off_outlined),
            title: Text(l.scdHiddenItem),
            trailing: TextButton(
              key: Key('scd.restore.$id'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final r = await ref
                    .read(studentCardServiceProvider)
                    .hideForMe(id, hide: false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      r.ok
                          ? l.scdRestored
                          : studentCardFailureText(l, r.failure!),
                    ),
                  ),
                );
                ref.invalidate(groupStudentCardsProvider(groupId));
              },
              child: Text(l.scdRestore),
            ),
          ),
      ],
    );
  }
}
