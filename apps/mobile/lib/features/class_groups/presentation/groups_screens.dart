import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/class_groups.dart';
import '../../../app/class_quiz.dart' show classScannerAvailableProvider;
import '../../../app/professional.dart' show localProfileProvider;
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'group_widgets.dart';

/// O‘qish bo‘limidagi kirish kartasi: «Guruhlar va mavzu testlari».
class GroupsEntryCard extends StatelessWidget {
  const GroupsEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('learn.groups'),
      onTap: () => context.push(Routes.groups),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.accentContainer,
              borderRadius: BorderRadius.circular(FeRadius.md),
            ),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(Icons.assignment_outlined, color: c.accent),
            ),
          ),
          const SizedBox(width: FeSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.grpTitle, style: t.titleSmall),
                const SizedBox(height: 2),
                Text(
                  l.grpEntrySubtitle,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.textSecondary),
        ],
      ),
    );
  }
}

/// Hisobga kirish kartasi: anonim qo‘shilish yo‘q.
class GroupSignInCard extends ConsumerWidget {
  const GroupSignInCard({super.key, this.onBeforeSignIn});

  /// Kirish oynasiga o‘tishdan oldin (masalan, taklifni eslab qolish).
  final VoidCallback? onBeforeSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('grp.signInCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.grpSignInTitle, style: t.titleMedium),
          const SizedBox(height: FeSpace.xxs),
          Text(l.grpSignInBody, style: t.bodyMedium),
          const SizedBox(height: FeSpace.sm),
          FilledButton.icon(
            key: const Key('grp.signInButton'),
            onPressed: () {
              onBeforeSignIn?.call();
              context.push(Routes.accountEmailCode);
            },
            icon: const Icon(Icons.login),
            label: Text(l.grpSignInAction),
          ),
        ],
      ),
    );
  }
}

/// «Guruhlar va mavzu testlari»: ustozning guruhlari va talaba a’zo bo‘lgan
/// guruhlar; kod yoki QR bilan qo‘shilish.
class GroupsHomeScreen extends ConsumerWidget {
  const GroupsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final svc = ref.watch(classGroupsServiceProvider);
    final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
    final async = ref.watch(groupListProvider);
    final data = async.value?.value;
    final failure = async.value?.failure;
    final scanner = ref.watch(classScannerAvailableProvider);

    Widget groupTile(GroupInfo g, {required bool teaching}) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('grp.group.${g.id}'),
        onTap: () => context.push(Routes.group(g.id)),
        child: Row(
          children: [
            Icon(
              teaching ? Icons.school_outlined : Icons.groups_outlined,
              color: c.accent,
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.name, style: t.titleSmall),
                  Text(
                    teaching
                        ? l.grpMembersCount(g.memberCount, g.memberLimit)
                        : l.grpMyNickname(g.nickname ?? ''),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(groupListProvider),
        child: ListView(
          key: const Key('grp.home'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: FeSpace.xs,
            bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GroupDemoBanner(),
                  Text(
                    l.grpIntro,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.md),
                  if (!svc.isConfigured)
                    FeNote(
                      icon: Icons.cloud_off_outlined,
                      text: l.grpErrNotConfigured,
                    )
                  else if (!signedIn)
                    const GroupSignInCard()
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('grp.joinButton'),
                            onPressed: () => context.push(Routes.groupJoin),
                            icon: const Icon(Icons.keyboard_outlined),
                            label: Text(l.grpJoinByCode),
                          ),
                        ),
                        if (scanner) ...[
                          const SizedBox(width: FeSpace.xs),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const Key('grp.scanButton'),
                              onPressed: () async {
                                final inv = await context.push<GroupInvite>(
                                  Routes.groupScan,
                                );
                                if (inv != null && context.mounted) {
                                  await context.push<void>(
                                    Routes.groupJoinWith(
                                      inv.code,
                                      assignmentId: inv.assignmentId,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              label: Text(l.grpScanAction),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (async.isLoading && data == null)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.lg),
                        child: FeListSkeleton(semanticLabel: l.grpTitle),
                      )
                    else if (failure != null)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.md),
                        child: FeNote(
                          key: const Key('grp.homeError'),
                          icon: Icons.cloud_off_outlined,
                          text: groupFailureText(l, failure),
                        ),
                      )
                    else if (data != null) ...[
                      if (data.isTeacher) ...[
                        FeSectionHeader(l.grpTeachingSection),
                        OutlinedButton.icon(
                          key: const Key('grp.createButton'),
                          onPressed: () => context.push(Routes.groupNew),
                          icon: const Icon(Icons.add),
                          label: Text(l.grpCreateAction),
                        ),
                        const SizedBox(height: FeSpace.sm),
                        if (data.teaching.isEmpty)
                          FeEmptyState(
                            icon: Icons.school_outlined,
                            body: l.grpTeachingEmpty,
                            compact: true,
                          ),
                        for (final g in data.teaching)
                          groupTile(g, teaching: true),
                      ],
                      FeSectionHeader(l.grpMemberSection),
                      if (data.member.isEmpty)
                        FeEmptyState(
                          key: const Key('grp.memberEmpty'),
                          icon: Icons.groups_outlined,
                          body: l.grpMemberEmpty,
                          compact: true,
                        ),
                      for (final g in data.member)
                        groupTile(g, teaching: false),
                    ],
                  ],
                  const SizedBox(height: FeSpace.md),
                  FeNote(
                    icon: Icons.privacy_tip_outlined,
                    text: l.grpPrivacyNote,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ustoz: yangi guruh (faqat nom). Yaratilgach guruh sahifasi ochiladi.
class GroupCreateScreen extends ConsumerStatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  ConsumerState<GroupCreateScreen> createState() => _GroupCreateState();
}

class _GroupCreateState extends ConsumerState<GroupCreateScreen> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.length < GroupRules.nameMin) {
      setState(() => _error = l.grpErrBadName);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(classGroupsServiceProvider).create(name);
    if (!mounted) return;
    final g = r.value;
    if (g == null) {
      setState(() {
        _busy = false;
        _error = groupFailureText(l, r.failure!, r.extra);
      });
      return;
    }
    ref.invalidate(groupListProvider);
    // Yaratish sahifasi root navigatorda: `go` — guruh sahifasi stekka bir
    // marta qo‘shiladi (duplicate page key yo‘q).
    context.go(Routes.group(g.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpCreateTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('grp.nameField'),
                    controller: _name,
                    autofocus: true,
                    maxLength: GroupRules.nameMax,
                    textInputAction: TextInputAction.done,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l.grpNameLabel,
                      helperText: l.grpNameHelper,
                      helperMaxLines: 2,
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  FilledButton(
                    key: const Key('grp.createSubmit'),
                    onPressed: _busy ? null : _submit,
                    child: Text(l.grpCreateAction),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR / havola / kod → (birinchi marta taxallus) → test.
///
/// * Kirmagan — kirish taklifi; taklif diskda saqlanadi va kirgach shu
///   sahifa yana ochiladi (yangi o‘rnatilgan ilovada ham).
/// * Ustoz o‘z kodini ochsa — «Siz bu guruhning ustozisiz» paneli va
///   «Talaba ko‘rinishida sinash» (hech narsa serverga yuborilmaydi).
class GroupJoinScreen extends ConsumerStatefulWidget {
  const GroupJoinScreen({super.key, this.initialCode, this.assignmentId});

  final String? initialCode;
  final String? assignmentId;

  @override
  ConsumerState<GroupJoinScreen> createState() => _GroupJoinState();
}

class _GroupJoinState extends ConsumerState<GroupJoinScreen> {
  late final TextEditingController _code;
  final _nick = TextEditingController();
  String? _assignmentId;
  bool _busy = false;
  bool _askNick = false;
  String? _groupName;
  String? _codeError;
  String? _nickError;
  String? _error;
  GroupJoinInfo? _teacher;

  @override
  void initState() {
    super.initState();
    final pending = ref.read(pendingGroupInviteProvider);
    final initial = GroupCode.clean(widget.initialCode).isNotEmpty
        ? GroupCode.clean(widget.initialCode)
        : pending?.code ?? '';
    _assignmentId =
        widget.assignmentId ??
        (pending?.code == initial ? pending?.assignmentId : null);
    _code = TextEditingController(text: initial);
    final inv = GroupCode.normalize(initial);
    if (inv != null) {
      // Kirish/ro‘yxatdan o‘tish davomida taklif yo‘qolmasin.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(pendingGroupInviteProvider.notifier)
            .remember(
              GroupInvite(code: inv, assignmentId: _assignmentId),
              autoOpen: false,
            );
        if (ref.read(authStateProvider).signedIn) _submit();
      });
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _nick.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final codeCheck = GroupCode.check(_code.text);
    String? nick;
    if (_askNick) {
      nick = ClassNickname.clean(_nick.text);
      final nc = ClassNickname.check(nick);
      if (nc != NicknameCheck.ok) {
        setState(
          () => _nickError = switch (nc) {
            NicknameCheck.length => l.grpErrNickLength,
            NicknameCheck.chars => l.grpErrNickChars,
            _ => l.grpErrNickBlocked,
          },
        );
        return;
      }
    }
    setState(() {
      _codeError = switch (codeCheck) {
        GroupCodeCheck.ok => null,
        GroupCodeCheck.ambiguous => l.grpErrCodeAmbiguous,
        GroupCodeCheck.bad => l.grpErrBadCode,
      };
      _nickError = null;
      _error = null;
    });
    if (codeCheck != GroupCodeCheck.ok) return;
    setState(() => _busy = true);
    final r = await ref
        .read(classGroupsServiceProvider)
        .join(
          code: GroupCode.clean(_code.text),
          nickname: nick,
          assignmentId: _assignmentId,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    final info = r.value;
    if (info == null) {
      final f = r.failure!;
      setState(() {
        if (f == GroupFailure.nicknameRequired) {
          _askNick = true;
          _groupName = r.extra['group_name'] as String?;
          _prefillNick();
        } else if (f.isNickname) {
          _nickError = groupFailureText(l, f, r.extra);
        } else if (f.isCode) {
          _codeError = groupFailureText(l, f, r.extra);
        } else {
          _error = groupFailureText(l, f, r.extra);
        }
      });
      return;
    }
    if (info.isTeacher) {
      setState(() => _teacher = info);
      return;
    }
    ref.read(pendingGroupInviteProvider.notifier).clear();
    ref.invalidate(groupListProvider);
    final aid = info.assignmentId;
    // Root sahifadan `go`: stek «Guruhlar → guruh → test» bo‘lib quriladi.
    context.go(
      aid == null
          ? Routes.group(info.group.id)
          : Routes.groupTest(info.group.id, aid),
    );
  }

  /// Talaba o‘z ISMI bilan qo‘shiladi: maydon profil ismi (fullName) bilan
  /// avtomatik to‘ldiriladi (o‘zgartirsa bo‘ladi; taxallus filtri saqlanadi).
  /// Profil ismi yaroqsiz yoki bo‘sh bo‘lsa — oldingi guruhdagi ism.
  void _prefillNick() {
    if (_nick.text.isNotEmpty) return;
    final p = ref.read(localProfileProvider);
    final fromProfile = ClassNickname.fromProfileName(
      p.student?.fullName ?? p.professional?.fullName,
    );
    if (fromProfile.isNotEmpty) {
      _nick.text = fromProfile;
      return;
    }
    final groups = ref.read(groupListProvider).value?.value?.member;
    final last = groups?.where((g) => g.nickname != null).firstOrNull;
    if (last != null) _nick.text = last.nickname!;
  }

  Future<void> _scan() async {
    final inv = await context.push<GroupInvite>(Routes.groupScan);
    if (inv == null || !mounted) return;
    setState(() {
      _code.text = inv.code;
      _assignmentId = inv.assignmentId;
    });
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final svc = ref.watch(classGroupsServiceProvider);
    final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
    final scanner = ref.watch(classScannerAvailableProvider);
    final teacher = _teacher;
    // Shu sahifadan kirish oynasiga o‘tib qaytilsa — davom etadi.
    ref.listen<bool>(authStateProvider.select((s) => s.signedIn), (p, n) {
      if (n && !(p ?? false) && GroupCode.normalize(_code.text) != null) {
        ref.read(pendingGroupInviteProvider.notifier).takeAutoOpen();
        _submit();
      }
    });

    final Widget content;
    if (!svc.isConfigured) {
      content = FeNote(
        icon: Icons.cloud_off_outlined,
        text: l.grpErrNotConfigured,
      );
    } else if (!signedIn) {
      content = GroupSignInCard(
        onBeforeSignIn: () =>
            ref.read(pendingGroupInviteProvider.notifier).reopenAfterSignIn(),
      );
    } else if (teacher != null) {
      final aid = teacher.assignmentId;
      content = FeCard(
        key: const Key('grp.ownerPanel'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: c.accent),
                const SizedBox(width: FeSpace.xs),
                Expanded(child: Text(l.grpOwnerTitle, style: t.titleMedium)),
              ],
            ),
            const SizedBox(height: FeSpace.xs),
            Text(l.grpOwnerBody(teacher.group.name), style: t.bodyMedium),
            const SizedBox(height: FeSpace.sm),
            if (aid != null) ...[
              FilledButton.icon(
                key: const Key('grp.ownerPreview'),
                onPressed: () =>
                    context.go(Routes.groupPreview(teacher.group.id, aid)),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l.grpPreviewAction),
              ),
              const SizedBox(height: FeSpace.xs),
            ],
            OutlinedButton.icon(
              key: const Key('grp.ownerOpen'),
              onPressed: () {
                ref.read(pendingGroupInviteProvider.notifier).clear();
                context.go(
                  aid == null
                      ? Routes.group(teacher.group.id)
                      : Routes.groupAssignment(teacher.group.id, aid),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: Text(l.grpOwnerOpen),
            ),
            const SizedBox(height: FeSpace.xs),
            FeNote(icon: Icons.info_outline, text: l.grpOwnerOtherAccount),
          ],
        ),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_askNick && _groupName != null) ...[
            Text(
              l.grpJoinGroupName(_groupName!),
              key: const Key('grp.joinGroupName'),
              style: t.titleMedium,
            ),
            const SizedBox(height: FeSpace.sm),
          ],
          TextField(
            key: const Key('grp.codeField'),
            controller: _code,
            enabled: !_askNick,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            maxLength: 9,
            inputFormatters: [GroupCodeInputFormatter()],
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: t.titleLarge?.copyWith(
              fontFamily: 'JetBrainsMono',
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              labelText: l.grpCodeLabel,
              helperText: l.grpCodeHelper,
              helperMaxLines: 2,
              counterText: '',
              errorText: _codeError,
              errorMaxLines: 3,
            ),
          ),
          if (_askNick) ...[
            const SizedBox(height: FeSpace.sm),
            TextField(
              key: const Key('grp.nickField'),
              controller: _nick,
              autofocus: true,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l.grpNickLabel,
                helperText: l.grpNickHelper,
                helperMaxLines: 3,
                errorText: _nickError,
                errorMaxLines: 3,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: FeSpace.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                key: const Key('grp.joinError'),
                style: t.bodyMedium?.copyWith(color: c.danger),
              ),
            ),
          ],
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('grp.joinSubmit'),
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_askNick ? l.grpJoinAction : l.grpContinue),
          ),
          if (scanner && !_askNick) ...[
            const SizedBox(height: FeSpace.xs),
            OutlinedButton.icon(
              key: const Key('grp.joinScan'),
              onPressed: _busy ? null : _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l.grpScanAction),
            ),
          ],
          const SizedBox(height: FeSpace.md),
          FeNote(icon: Icons.privacy_tip_outlined, text: l.grpPrivacyNote),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpJoinTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [const GroupDemoBanner(), content],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR skaner: guruh havolasi yoki kod. Kamera ruxsati rad etilsa — qo‘lda.
class GroupScanScreen extends StatefulWidget {
  const GroupScanScreen({super.key});

  @override
  State<GroupScanScreen> createState() => _GroupScanState();
}

class _GroupScanState extends State<GroupScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      final inv = GroupCode.fromText(b.rawValue);
      if (inv != null) {
        _done = true;
        context.pop(inv);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpScanTitle)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_outlined, size: 40),
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      error.errorCode == MobileScannerErrorCode.permissionDenied
                          ? l.classScanPermission
                          : l.classScanUnavailable,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(l.classScanManual),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(FeSpace.md),
                padding: const EdgeInsets.all(FeSpace.sm),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(FeRadius.md),
                ),
                child: Text(
                  l.grpScanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
