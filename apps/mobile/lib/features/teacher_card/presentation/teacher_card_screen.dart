import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/avatar.dart';
import '../../../app/teacher_card.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/teacher_card/teacher_card.dart';
import '../../profile/presentation/avatar_widgets.dart' show AvatarCropScreen;
import '../teacher_card_image.dart';
import 'teacher_card_widgets.dart';

/// Profil → «Ustoz kartam»: ustoz o‘z kartasini tahrirlaydi. Karta DEFAULT
/// talabalarga ko‘rinmaydi: «Talabalarimga ko‘rsatish» kaliti rozilik matni
/// bilan alohida yoqiladi.
class TeacherCardScreen extends ConsumerStatefulWidget {
  const TeacherCardScreen({super.key});

  @override
  ConsumerState<TeacherCardScreen> createState() => _TeacherCardState();
}

class _TeacherCardState extends ConsumerState<TeacherCardScreen> {
  final _name = TextEditingController();
  final _work = TextEditingController();
  final _bio = TextEditingController();
  final _social = {
    for (final s in TeacherSocial.values) s: TextEditingController(),
  };

  TeacherCard? _saved;
  bool _inited = false;
  bool _visible = false;
  bool _busy = false;
  bool _showErrors = false;
  Uint8List? _photo;
  Uint8List? _logo;
  bool _removePhoto = false;
  bool _removeLogo = false;

  @override
  void dispose() {
    _name.dispose();
    _work.dispose();
    _bio.dispose();
    for (final c in _social.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _init(TeacherCard? c) {
    _inited = true;
    _saved = c;
    if (c == null) return;
    _name.text = c.displayName;
    _work.text = c.workplace;
    _bio.text = c.bio;
    _visible = c.visible && !c.hiddenByAdmin;
    for (final e in c.socials.entries) {
      _social[e.key]!.text = e.value;
    }
  }

  /// Maydonlardagi matn → normallashtirilgan havolalar (yaroqsiz — `null`).
  Map<TeacherSocial, String?> _normalized() => {
    for (final e in _social.entries)
      e.key: TeacherLinks.normalize(e.key, e.value.text),
  };

  bool get _hasSocialError => _normalized().values.any((v) => v == null);

  TeacherCardDraft _draft() {
    final soc = <TeacherSocial, String>{};
    for (final e in _normalized().entries) {
      final v = e.value;
      if (v != null && v.isNotEmpty) soc[e.key] = v;
    }
    return TeacherCardDraft(
      displayName: _name.text,
      workplace: _work.text,
      bio: _bio.text,
      socials: soc,
      visible: _visible,
      photo: _photo,
      logo: _logo,
      removePhoto: _removePhoto,
      removeLogo: _removeLogo,
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    Uint8List? picked;
    try {
      picked = await ref.read(avatarPickerProvider).pick();
    } on Object {
      if (mounted) _snack(l.tcErrImage);
      return;
    }
    if (picked == null || !mounted) return;
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => AvatarCropScreen(source: picked!)),
    );
    if (cropped == null || !mounted) return;
    final fitted = await fitTeacherImage(cropped);
    if (!mounted) return;
    if (fitted == null) {
      _snack(l.tcErrImageLarge);
      return;
    }
    setState(() {
      _photo = fitted;
      _removePhoto = false;
    });
  }

  Future<void> _pickLogo() async {
    final l = AppLocalizations.of(context);
    Uint8List? picked;
    try {
      picked = await ref.read(avatarPickerProvider).pick();
    } on Object {
      if (mounted) _snack(l.tcErrImage);
      return;
    }
    if (picked == null || !mounted) return;
    final fitted = await fitTeacherImage(picked, sides: const [256, 192, 128]);
    if (!mounted) return;
    if (fitted == null) {
      _snack(l.tcErrImageLarge);
      return;
    }
    setState(() {
      _logo = fitted;
      _removeLogo = false;
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _showErrors = true);
    if (_hasSocialError) {
      _snack(l.tcErrSocial);
      return;
    }
    final draft = _draft();
    if (draft.error case final e?) {
      _snack(
        teacherCardFailureText(l, switch (e) {
          TeacherCardDraftError.name => TeacherCardFailure.invalidName,
          TeacherCardDraftError.workplace =>
            TeacherCardFailure.invalidWorkplace,
          TeacherCardDraftError.bio => TeacherCardFailure.invalidBio,
          TeacherCardDraftError.image => TeacherCardFailure.imageTooLarge,
          TeacherCardDraftError.social => TeacherCardFailure.invalidSocial,
        }),
      );
      return;
    }
    setState(() => _busy = true);
    final r = await ref
        .read(teacherCardServiceProvider)
        .save(draft, previous: _saved);
    if (!mounted) return;
    setState(() => _busy = false);
    final card = r.value;
    if (card == null) {
      _snack(teacherCardFailureText(l, r.failure!));
      return;
    }
    // Maydonlar normallashtirilgan havolalar bilan yangilanadi.
    for (final s in TeacherSocial.values) {
      _social[s]!.text = card.socials[s] ?? '';
    }
    setState(() {
      _saved = card;
      _photo = null;
      _logo = null;
      _removePhoto = false;
      _removeLogo = false;
      _visible = card.visible;
    });
    ref.invalidate(myTeacherCardProvider);
    _snack(l.tcSaved);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.tcDeleteTitle),
        content: Text(l.tcDeleteBody),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: Text(l.tcCancel)),
          FilledButton(
            key: const Key('tc.deleteYes'),
            onPressed: () => c.pop(true),
            child: Text(l.tcDeleteConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(teacherCardServiceProvider).delete();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      _snack(teacherCardFailureText(l, r.failure!));
      return;
    }
    ref.invalidate(myTeacherCardProvider);
    _snack(l.tcDeleted);
    if (context.canPop()) context.pop();
  }

  Future<void> _preview() async {
    final l = AppLocalizations.of(context);
    final d = _draft();
    final card = TeacherCard(
      teacherId: '',
      displayName: d.displayName.trim().isEmpty ? '—' : d.displayName.trim(),
      workplace: d.workplace.trim(),
      bio: d.bio.trim(),
      photoPath: _removePhoto ? null : _saved?.photoPath,
      logoPath: _removeLogo ? null : _saved?.logoPath,
      socials: d.socials,
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
                l.tcPreviewTitle,
                key: const Key('tc.previewTitle'),
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: FeSpace.sm),
              TeacherCardView(card: card, photoBytes: _photo, logoBytes: _logo),
              const SizedBox(height: FeSpace.sm),
              Text(
                l.tcPreviewNote,
                style: Theme.of(ctx).textTheme.bodySmall
                    ?.copyWith(color: FeTheme.of(ctx).textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageRow({
    required String id,
    required Widget preview,
    required bool has,
    required String chooseLabel,
    required String removeLabel,
    required VoidCallback onChoose,
    required VoidCallback onRemove,
  }) {
    return Row(
      key: Key(id),
      children: [
        preview,
        const SizedBox(width: FeSpace.sm),
        Expanded(
          child: Wrap(
            spacing: FeSpace.xs,
            children: [
              OutlinedButton(
                key: Key('$id.choose'),
                onPressed: _busy ? null : onChoose,
                child: Text(chooseLabel),
              ),
              if (has)
                TextButton(
                  key: Key('$id.remove'),
                  onPressed: _busy ? null : onRemove,
                  child: Text(removeLabel),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(myTeacherCardProvider);
    final result = async.value;

    Widget body;
    if (result == null) {
      body = FeListSkeleton(semanticLabel: l.tcTitle);
    } else if (!result.ok) {
      body = FeEmptyState(
        key: const Key('tc.loadError'),
        icon: result.failure == TeacherCardFailure.forbidden
            ? Icons.lock_outline
            : Icons.cloud_off_outlined,
        body: teacherCardFailureText(l, result.failure!),
        actionLabel: l.tcRetry,
        onAction: () => ref.invalidate(myTeacherCardProvider),
      );
    } else {
      if (!_inited) _init(result.value);
      final hidden = _saved?.hiddenByAdmin ?? false;
      final shownPhotoPath = _removePhoto ? null : _saved?.photoPath;
      final shownLogoPath = _removeLogo ? null : _saved?.logoPath;
      final hasPhoto = _photo != null || shownPhotoPath != null;
      final hasLogo = _logo != null || shownLogoPath != null;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.tcLead, style: t.bodyMedium?.copyWith(color: c.textSecondary)),
          if (hidden) ...[
            const SizedBox(height: FeSpace.sm),
            FeBanner(
              key: const Key('tc.hiddenBanner'),
              icon: Icons.visibility_off_outlined,
              tone: FeBannerTone.warning,
              text: l.tcErrHidden,
            ),
          ],
          FeSectionHeader(l.tcPhotoSection),
          _imageRow(
            id: 'tc.photoRow',
            preview: TeacherPhoto(
              name: _name.text,
              path: shownPhotoPath,
              bytes: _photo,
              size: 72,
            ),
            has: hasPhoto,
            chooseLabel: hasPhoto ? l.tcPhotoChange : l.tcPhotoChoose,
            removeLabel: l.tcPhotoRemove,
            onChoose: _pickPhoto,
            onRemove: () => setState(() {
              _photo = null;
              _removePhoto = true;
            }),
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.tcPhotoNote,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.md),
          TextField(
            key: const Key('tc.field.name'),
            controller: _name,
            maxLength: TeacherCardLimits.nameMax,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: l.tcName,
              helperText: l.tcNameHelper,
              errorText:
                  _showErrors &&
                      (_name.text.trim().length < TeacherCardLimits.nameMin)
                  ? l.tcErrName
                  : null,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          TextField(
            key: const Key('tc.field.workplace'),
            controller: _work,
            maxLength: TeacherCardLimits.workplaceMax,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: l.tcWorkplace,
              hintText: l.tcWorkplaceHint,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          FeSectionHeader(l.tcLogoSection),
          _imageRow(
            id: 'tc.logoRow',
            preview: _LogoPreview(path: shownLogoPath, bytes: _logo),
            has: hasLogo,
            chooseLabel: l.tcLogoChoose,
            removeLabel: l.tcLogoRemove,
            onChoose: _pickLogo,
            onRemove: () => setState(() {
              _logo = null;
              _removeLogo = true;
            }),
          ),
          const SizedBox(height: FeSpace.md),
          TextField(
            key: const Key('tc.field.bio'),
            controller: _bio,
            maxLength: TeacherCardLimits.bioMax,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              labelText: l.tcBio,
              hintText: l.tcBioHint,
              alignLabelWithHint: true,
            ),
          ),
          FeSectionHeader(l.tcSocials),
          Text(
            l.tcSocialsHint,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xs),
          for (final s in TeacherSocial.values)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: TextField(
                key: Key('tc.field.social.${s.key}'),
                controller: _social[s],
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                  labelText: teacherSocialName(l, s),
                  hintText: s == TeacherSocial.website
                      ? l.tcSocialHintWeb
                      : l.tcSocialHintUser,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(FeSpace.xs),
                    child: SocialBadge(social: s, size: 28),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  errorText: TeacherLinks.normalize(s, _social[s]!.text) == null
                      ? l.tcSocialInvalid
                      : null,
                  errorMaxLines: 2,
                ),
              ),
            ),
          const SizedBox(height: FeSpace.xs),
          FeCard(
            padding: const EdgeInsets.all(FeSpace.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  key: const Key('tc.visible'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FeSpace.xs,
                  ),
                  title: Text(l.tcVisibleTitle),
                  subtitle: Text(_visible ? l.tcVisibleOn : l.tcVisibleOff),
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
                    l.tcConsent,
                    key: const Key('tc.consent'),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FeSpace.md),
          OutlinedButton.icon(
            key: const Key('tc.preview'),
            onPressed: _busy ? null : _preview,
            icon: const Icon(Icons.visibility_outlined),
            label: Text(l.tcPreview),
          ),
          const SizedBox(height: FeSpace.xs),
          FilledButton(
            key: const Key('tc.save'),
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.tcSave),
          ),
          if (_saved != null) ...[
            const SizedBox(height: FeSpace.xs),
            TextButton.icon(
              key: const Key('tc.delete'),
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l.tcDelete),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.tcTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('tc.list'),
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

class _LogoPreview extends ConsumerWidget {
  const _LogoPreview({this.path, this.bytes});

  final String? path;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = FeTheme.of(context);
    Uint8List? data = bytes;
    if (data == null && path != null) {
      data = ref.watch(teacherCardImageProvider(path!)).value;
    }
    return Container(
      width: 72,
      height: 72,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FeRadius.sm),
        color: c.surfaceSunken,
        border: Border.all(color: c.border),
      ),
      child: data != null
          ? Image.memory(
              data,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  Icon(Icons.business_outlined, color: c.textSecondary),
            )
          : Icon(Icons.business_outlined, color: c.textSecondary),
    );
  }
}
