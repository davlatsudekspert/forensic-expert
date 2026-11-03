import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/oral_group.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/oral_group/oral_group_models.dart'
    show OralGroupLink, OralGroupParticipant;
import '../../anti_cheat/presentation/anti_cheat_widgets.dart'
    show AntiCheatFlags;
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show classFailureText;

/// Guruh og‘zaki imtihoni xatosi → foydalanuvchiga tushunarli matn. Umumiy
/// tarmoq/server xatolari «Guruh testi» matnlari bilan bir xil.
String oralFailureText(AppLocalizations l, ClassFailure f) => switch (f) {
  ClassFailure.notFound => l.oralErrNotFound,
  ClassFailure.finished => l.oralErrFinished,
  ClassFailure.full => l.oralErrFull,
  ClassFailure.kicked => l.oralErrKicked,
  ClassFailure.nickLength => l.oralErrNameLength,
  ClassFailure.nickChars => l.oralErrNameChars,
  ClassFailure.nickBlocked => l.oralErrNameBlocked,
  ClassFailure.rateLimited => l.oralErrRateLimited,
  ClassFailure.ownSession => l.oralErrOwnSession,
  ClassFailure.invalidSettings => l.oralErrInvalidSettings,
  ClassFailure.tooManySessions => l.oralErrTooMany,
  _ => classFailureText(l, f),
};

/// `mm:ss` (soat kerak bo‘lsa `h:mm:ss`).
String oralClock(Duration d) {
  String two(int x) => x.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Mahalliy soat `HH:mm`.
String oralHm(DateTime t) {
  String two(int x) => x.toString().padLeft(2, '0');
  final d = t.toLocal();
  return '${two(d.hour)}:${two(d.minute)}';
}

/// Demo rejim belgisi (ma’lumot faqat shu qurilmada).
class OralGroupDemoBanner extends ConsumerWidget {
  const OralGroupDemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(oralGroupServiceProvider).isDemo) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FeBanner(
        key: const Key('oralgroup.demoBanner'),
        icon: Icons.science_outlined,
        text: l.classDemoBanner,
        tone: FeBannerTone.warning,
      ),
    );
  }
}

/// «Davom etish: Bilet № X» — oxirgi imtihon ochiq va talaba hali unda bo‘lsa.
/// Imtihon yakunlangan, talaba chiqarilgan yoki unda emas bo‘lsa — yashirinadi
/// va eslab qolingan yozuv o‘chiriladi.
class OralResumeCard extends ConsumerWidget {
  const OralResumeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(oralResumeProvider);
    if (r == null) return const SizedBox.shrink();
    final async = ref.watch(oralGroupMyStateProvider(r.sessionId));
    final res = async.value;
    final snap = res?.value;
    if (res != null && res.failure != null) {
      const gone = {
        ClassFailure.notJoined,
        ClassFailure.notFound,
        ClassFailure.kicked,
        ClassFailure.forbidden,
      };
      if (gone.contains(res.failure)) {
        Future.microtask(() => ref.read(oralResumeProvider.notifier).clear());
      }
      return const SizedBox.shrink();
    }
    if (snap == null) return const SizedBox.shrink();
    if (!snap.state.session.isOpen) {
      Future.microtask(() => ref.read(oralResumeProvider.notifier).clear());
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FeCard(
        key: const Key('oralgroup.resume'),
        onTap: () => context.push(Routes.oralPlay(r.sessionId)),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: c.accent),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Text(
                l.oralResumeCard(snap.state.ticketNo),
                style: t.titleSmall,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// Skanerlangan matn oral imtihon havolasi bo‘lsa — yo‘naltiradi va `true`
/// qaytaradi. Ikkala skaner (Guruh testi va Guruhlar) shu yagona yo‘ldan
/// foydalanadi. [popResult] — chaqiruvchi ekranga `oral:<kod>` qaytariladi
/// (oral qo‘shilish ekranidan skanerlanganda ekran takrorlanmasin); aks holda
/// skaner ekrani oral qo‘shilish ekrani bilan almashtiriladi.
bool routeOralScan(
  BuildContext context,
  String? raw, {
  bool popResult = false,
}) {
  final code = OralGroupLink.codeFromScanned(raw);
  if (code == null) return false;
  if (popResult) {
    context.pop('${OralGroupLink.scanPrefix}$code');
  } else {
    context.pushReplacement(Routes.oralJoinWith(code));
  }
  return true;
}

/// Ustoz ekranlarida (navbat, baholash): talaba ilovadan necha marta chiqqani
/// va oxirgi vaqti. Doskada ishlatilmaydi. Chiqish bo‘lmasa — joy egallamaydi.
class OralLeaveFlag extends StatelessWidget {
  const OralLeaveFlag({super.key, required this.participant});

  final OralGroupParticipant participant;

  @override
  Widget build(BuildContext context) {
    final p = participant;
    if (p.leaveCount <= 0) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final last = p.lastLeftAt;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        AntiCheatFlags(
          leaveCount: p.leaveCount,
          tooFast: false,
          idSuffix: '.${p.id}',
        ),
        if (last != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l.oralGroupLeftAt(oralHm(last)),
              key: Key('oralgroup.leftAt.${p.id}'),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: FeTheme.of(context).textSecondary),
            ),
          ),
      ],
    );
  }
}
