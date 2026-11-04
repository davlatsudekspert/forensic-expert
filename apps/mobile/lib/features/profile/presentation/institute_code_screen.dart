import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/plan.dart';
import '../../../app/promo.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/plan/plan_models.dart';
import '../../../domain/plan/promo_models.dart';
import '../../../domain/ports/plan_ports.dart';

/// «Promokod» qatori qiymati: faol label + sana, aks holda
/// izoh. Matnda «Pro» so‘zi yo‘q (Pro o‘chiq yig‘mada ham ko‘rinadi).
String promoRowValue(AppLocalizations l, BuildContext context, Entitlements e) {
  final text = promoAccessText(l, context, e);
  return text ?? l.promoRowHint;
}

/// Server `label`i («institut: Nomi» / «sovg‘a: Kim») — ko‘rinadigan matn.
String promoLabelText(AppLocalizations l, PromoLabel label) =>
    switch (label.kind) {
      PromoKind.institute => l.promoLabelInstitute(label.name),
      PromoKind.gift => l.promoLabelGift(label.name),
      PromoKind.other => label.name,
    };

/// «Nom, 2027-yil 4-mart gacha» — faol promokod reja bo‘lsa.
String? promoAccessText(
  AppLocalizations l,
  BuildContext context,
  Entitlements e,
) {
  final label = PromoLabel.parse(e.label);
  if (label == null || !e.isActive) return null;
  final head = promoLabelText(l, label);
  final until = e.expiresAt;
  if (until == null) return head;
  return '$head, ${l.promoUntil(feDate(context, until.toLocal()))}';
}

/// Katta harfga o‘tkazadi, harf/raqamdan boshqasini (bo‘shliq, defis) tashlaydi.
class _CodeFormatter extends TextInputFormatter {
  const _CodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = normalizePromoCode(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class InstituteCodeScreen extends ConsumerStatefulWidget {
  const InstituteCodeScreen({super.key});

  @override
  ConsumerState<InstituteCodeScreen> createState() =>
      _InstituteCodeScreenState();
}

class _InstituteCodeScreenState extends ConsumerState<InstituteCodeScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (normalizePromoCode(_code.text).isEmpty) {
      setState(() {
        _success = false;
        _message = l.promoEmpty;
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final r = await redeemPromo(ref, _code.text);
    if (!mounted) return;
    final v = r.value;
    String msg;
    var ok = false;
    if (v == null) {
      msg = switch (r.failure) {
        PlanFailure.offline => l.promoOffline,
        PlanFailure.notSignedIn => l.promoNotSigned,
        _ => l.promoError,
      };
    } else {
      switch (v.result) {
        case PromoResult.ok:
          ok = true;
          final parsed = PromoLabel.parse(v.label);
          msg = (parsed == null || v.until == null)
              ? l.promoOkShort
              : l.promoOk(
                  promoLabelText(l, parsed),
                  feDate(context, v.until!.toLocal()),
                );
        case PromoResult.invalid:
          msg = l.promoInvalid;
        case PromoResult.used:
          msg = l.promoUsed;
        case PromoResult.alreadyYours:
          ok = true;
          msg = l.promoAlreadyYours;
        case PromoResult.expired:
          msg = l.promoExpired;
        case PromoResult.revoked:
          msg = l.promoRevoked;
        case PromoResult.tooMany:
          msg = l.promoTooMany;
        case PromoResult.notSigned:
          msg = l.promoNotSigned;
        case PromoResult.unknown:
          msg = l.promoError;
      }
    }
    setState(() {
      _busy = false;
      _success = ok;
      _message = msg;
      if (ok) _code.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final ent = ref.watch(entitlementsProvider).value ?? Entitlements.none;
    final access = promoAccessText(l, context, ent);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.promoRowTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('promo.list'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    l.promoIntro,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary),
                  ),
                  if (access != null) ...[
                    FeSectionHeader(l.promoActiveTitle),
                    FeBanner(
                      key: const Key('promo.active'),
                      icon: Icons.verified_outlined,
                      text: access,
                      tone: FeBannerTone.review,
                    ),
                  ],
                  const SizedBox(height: FeSpace.md),
                  TextField(
                    key: const Key('promo.field'),
                    controller: _code,
                    enabled: !_busy,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onSubmitted: (_) => _submit(),
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    inputFormatters: const [_CodeFormatter()],
                    decoration: InputDecoration(
                      labelText: l.promoFieldLabel,
                      helperText: l.promoFieldHint,
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  FilledButton(
                    key: const Key('promo.submit'),
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, FeTouch.minTarget),
                    ),
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.promoSubmit),
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.sm),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _message!,
                          key: const Key('promo.message'),
                          style: t.bodyMedium?.copyWith(
                            color: _success ? c.verified : c.danger,
                          ),
                        ),
                      ),
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
