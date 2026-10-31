import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/avatar.dart';
import '../../../app/student_card.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/student_card/student_card.dart';
import '../../profile/presentation/avatar_widgets.dart' show AvatarCropScreen;
import '../../teacher_card/teacher_card_image.dart';
import 'student_card_widgets.dart';

/// Profil → «Talaba kartam»: talaba o‘z kartasini tahrirlaydi. Karta DEFAULT
/// hech kimga ko‘rinmaydi: «Guruhdoshlarimga va ustozimga ko‘rsatish» kaliti
/// rozilik matni bilan alohida yoqiladi. Havola/aloqa maydoni YO‘Q.
class StudentCardScreen extends ConsumerStatefulWidget {
  const StudentCardScreen({super.key});

  @override
  ConsumerState<StudentCardScreen> createState() => _StudentCardState();
}

class _StudentCardState extends ConsumerState<StudentCardScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();

  StudentCard? _saved;
  bool _inited = false;
  bool _visible = false;
  bool _busy = false;
  bool _showErrors = false;
  Uint8List? _photo;
  bool _removePhoto = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _init(StudentCard? c) {
    _inited = true;
    _saved = c;
    if (c == null) return;
    _name.text = c.displayName;
    _bio.text = c.bio;
    _visible = c.visible && !c.hiddenByAdmin;
  }

  StudentCardDraft _draft() => StudentCardDraft(
    displayName: _name.text,
    bio: _bio.text,
    visible: _visible,
    photo: _photo,
    removePhoto: _removePhoto,
  );

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    Uint8List? picked;
    try {
      picked = await ref.read(avatarPickerProvider).pick();
    } on Object {
      if (mounted) _snack(l.scdErrImage);
      return;
    }
    if (picked == null || !mounted) return;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => AvatarCropScreen(source: picked!)),
    );
    if (cropped == null || !mounted) return;
    final fitted = await fitTeacherImage(
      cropped,
      maxBytes: StudentCardLimits.imageBytes,
    );
    if (!mounted) return;
    if (fitted == null) {
      _snack(l.scdErrImageLarge);
      return;
    }
    setState(() {
      _photo = fitted;
      _removePhoto = false;
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _showErrors = true);
    final draft = _draft();
    if (draft.error case final e?) {
      _snack(studentCardFailureText(l, StudentCardFailure.fromDraft(e)));
      return;
    }
    setState(() => _busy = true);
    final r = await ref
        .read(studentCardServiceProvider)
        .save(draft, previous: _saved);
    if (!mounted) return;
    setState(() => _busy = false);
    final card = r.value;
    if (card == null) {
      _snack(studentCardFailureText(l, r.failure!));
      return;
    }
    setState(() {
      _saved = card;
      _photo = null;
      _removePhoto = false;
      _visible = card.visible;
    });
    ref.invalidate(myStudentCardProvider);
    _snack(l.scdSaved);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.scdDeleteTitle),
        content: Text(l.scdDeleteBody),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: Text(l.scdCancel)),
          FilledButton(
            key: const Key('scd.deleteYes'),
            onPressed: () => c.pop(true),
            child: Text(l.scdDeleteConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(studentCardServiceProvider).delete();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      _snack(studentCardFailureText(l, r.failure!));
      return;
    }
    ref.invalidate(myStudentCardProvider);
    _snack(l.scdDeleted);
    if (context.canPop()) context.pop();
  }

  Future<void> _preview() async {
    final l = AppLocalizations.of(context);
    final d = _draft();
    final card = StudentCard(
      studentId: '',
      displayName: d.displayName.trim().isEmpty ? '—' : d.displayName.trim(),
      bio: d.bio.trim(),
      photoPath: _removePhoto ? null : _saved?.photoPath,
    );
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            0,
            FeSpace.md,
            FeSpace.md,
          ),
          child: ListView(
            shrinkWrap: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                l.scdPreviewTitle,
                key: const Key('scd.previewTitle'),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: FeSpace.sm),
              StudentCardView(card: card, photoBytes: _photo),
              const SizedBox(height: FeSpace.sm),
              Text(
                l.scdPreviewNote,
                style: Theme.of(ctx).textTheme.bodySmall
                    ?.copyWith(color: FeTheme.of(ctx).textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _nameError(AppLocalizations l) {
    if (!_showErrors && _name.text.trim().isEmpty) return null;
    final n = _name.text.trim();
    if (_showErrors && n.length < StudentCardLimits.nameMin) {
      return l.scdErrName;
    }
    if (!StudentCardText.isClean(n)) return l.scdErrContact;
    return null;
  }

  String? _bioError(AppLocalizations l) =>
      StudentCardText.isClean(_bio.text.trim()) ? null : l.scdErrContact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(myStudentCardProvider);
    final result = async.value;

    Widget body;
    if (result == null) {
      body = FeListSkeleton(semanticLabel: l.scdTitle);
    } else if (!result.ok) {
      body = FeEmptyState(
        key: const Key('scd.loadError'),
        icon: result.failure == StudentCardFailure.forbidden
            ? Icons.lock_outline
            : Icons.cloud_off_outlined,
        body: studentCardFailureText(l, result.failure!),
        actionLabel: l.scdRetry,
        onAction: () => ref.invalidate(myStudentCardProvider),
      );
    } else {
      if (!_inited) _init(result.value);
      final hidden = _saved?.hiddenByAdmin ?? false;
      final shownPhotoPath = _removePhoto ? null : _saved?.photoPath;
      final hasPhoto = _photo != null || shownPhotoPath != null;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.scdLead,
            style: t.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          if (hidden) ...[
            const SizedBox(height: FeSpace.sm),
            FeBanner(
              key: const Key('scd.hiddenBanner'),
              icon: Icons.visibility_off_outlined,
              tone: FeBannerTone.warning,
              text: l.scdAdminHidden,
            ),
          ],
          if ((_saved?.hiddenInGroups ?? 0) > 0) ...[
            const SizedBox(height: FeSpace.sm),
            FeBanner(
              key: const Key('scd.teacherHiddenBanner'),
              icon: Icons.visibility_off_outlined,
              tone: FeBannerTone.warning,
              text: l.scdTeacherHidden,
            ),
          ],
          FeSectionHeader(l.scdPhotoSection),
          Row(
            key: const Key('scd.photoRow'),
            children: [
              StudentPhoto(
                name: _name.text,
                path: shownPhotoPath,
                bytes: _photo,
                size: 72,
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Wrap(
                  spacing: FeSpace.xs,
                  children: [
                    OutlinedButton(
                      key: const Key('scd.photoRow.choose'),
                      onPressed: _busy ? null : _pickPhoto,
                      child: Text(
                        hasPhoto ? l.scdPhotoChange : l.scdPhotoChoose,
                      ),
                    ),
                    if (hasPhoto)
                      TextButton(
                        key: const Key('scd.photoRow.remove'),
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _photo = null;
                                _removePhoto = true;
                              }),
                        child: Text(l.scdPhotoRemove),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.scdPhotoNote,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.md),
          TextField(
            key: const Key('scd.field.name'),
            controller: _name,
            maxLength: StudentCardLimits.nameMax,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: l.scdName,
              helperText: l.scdNameHelper,
              errorText: _nameError(l),
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          TextField(
            key: const Key('scd.field.bio'),
            controller: _bio,
            maxLength: StudentCardLimits.bioMax,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: l.scdBio,
              hintText: l.scdBioHint,
              alignLabelWithHint: true,
              errorText: _bioError(l),
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          FeBanner(
            key: const Key('scd.noContact'),
            icon: Icons.shield_outlined,
            tone: FeBannerTone.info,
            text: l.scdNoContact,
          ),
          const SizedBox(height: FeSpace.sm),
          FeCard(
            padding: const EdgeInsets.all(FeSpace.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  key: const Key('scd.visible'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FeSpace.xs,
                  ),
                  title: Text(l.scdVisibleTitle),
                  subtitle: Text(_visible ? l.scdVisibleOn : l.scdVisibleOff),
                  value: _visible,
                  onChanged: _busy || hidden
                      ? null
                      : (v) => setState(() => _visible = v),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FeSpace.xs,
                    0,
                    FeSpace.xs,
                    FeSpace.xs,
                  ),
                  child: Text(
                    l.scdConsent,
                    key: const Key('scd.consent'),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FeSpace.md),
          OutlinedButton.icon(
            key: const Key('scd.preview'),
            onPressed: _busy ? null : _preview,
            icon: const Icon(Icons.visibility_outlined),
            label: Text(l.scdPreview),
          ),
          const SizedBox(height: FeSpace.xs),
          FilledButton(
            key: const Key('scd.save'),
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.scdSave),
          ),
          if (_saved != null) ...[
            const SizedBox(height: FeSpace.xs),
            TextButton.icon(
              key: const Key('scd.delete'),
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l.scdDelete),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.scdTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('scd.list'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: FeSpace.xs,
            bottom: FeSpace.xl + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [FeContentFrame(child: body)],
        ),
      ),
    );
  }
}
