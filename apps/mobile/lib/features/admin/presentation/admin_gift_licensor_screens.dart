import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/institutes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/admin/institute_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../pro/presentation/pro_gate.dart' show proPlanName;
import 'admin_codes_widgets.dart';
import 'admin_gate.dart';

/// Admin → «Sovg‘a promokod»: kim bergan, soni (1–50), kunlar, reja → kodlar.
class AdminGiftCodesScreen extends ConsumerStatefulWidget {
  const AdminGiftCodesScreen({super.key});

  @override
  ConsumerState<AdminGiftCodesScreen> createState() =>
      _AdminGiftCodesScreenState();
}

class _AdminGiftCodesScreenState extends ConsumerState<AdminGiftCodesScreen> {
  final _from = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _days = TextEditingController(text: '30');
  Plan _plan = Plan.teacher;
  bool _busy = false;
  String? _error;
  IssuedCodes? _issued;

  @override
  void dispose() {
    _from.dispose();
    _count.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final count = int.tryParse(_count.text.trim()) ?? 0;
    final days = int.tryParse(_days.text.trim()) ?? 0;
    if (_from.text.trim().length < 2 ||
        count < 1 ||
        count > 50 ||
        days < 1 ||
        days > 1100) {
      setState(() => _error = l.instGiftInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _issued = null;
    });
    final r = await ref
        .read(adminInstituteServiceProvider)
        .createGiftCodes(
          from: _from.text.trim(),
          count: count,
          days: days,
          plan: _plan,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _issued = r.value;
      if (r.value == null) {
        _error = r.failure?.name == 'invalid'
            ? l.instGiftInvalid
            : l.instGiftError;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final issued = _issued;
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.instGift)),
        body: SafeArea(
          child: ListView(
            key: const Key('adminGift.list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('adminGift.from'),
                      controller: _from,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(labelText: l.instGiftFrom),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('adminGift.count'),
                            controller: _count,
                            keyboardType: TextInputType.number,
                            onTapOutside: (_) =>
                                FocusScope.of(context).unfocus(),
                            decoration: InputDecoration(
                              labelText: l.instGiftCount,
                            ),
                          ),
                        ),
                        const SizedBox(width: FeSpace.xs),
                        Expanded(
                          child: TextField(
                            key: const Key('adminGift.days'),
                            controller: _days,
                            keyboardType: TextInputType.number,
                            onTapOutside: (_) =>
                                FocusScope.of(context).unfocus(),
                            decoration: InputDecoration(
                              labelText: l.instGiftDays,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.sm),
                    Text(l.instGiftPlan, style: t.labelLarge),
                    const SizedBox(height: FeSpace.xxs),
                    Wrap(
                      spacing: FeSpace.xs,
                      children: [
                        for (final p in Plan.values)
                          ChoiceChip(
                            key: Key('adminGift.plan.${p.name}'),
                            label: Text(proPlanName(l, p)),
                            selected: _plan == p,
                            onSelected: (_) => setState(() => _plan = p),
                          ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.md),
                    FilledButton(
                      key: const Key('adminGift.create'),
                      onPressed: _busy ? null : _create,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, FeTouch.minTarget),
                      ),
                      child: Text(l.instGiftCreate),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xs),
                        child: Text(
                          _error!,
                          key: const Key('adminGift.error'),
                          style: t.bodyMedium?.copyWith(color: c.danger),
                        ),
                      ),
                    if (issued != null) ...[
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        l.instGiftDone(issued.codes.length),
                        key: const Key('adminGift.done'),
                        style: t.titleSmall,
                      ),
                      CreatedCodesView(
                        codes: issued.codes,
                        keyPrefix: 'adminGift.codes',
                      ),
                    ],
                    const SizedBox(height: FeSpace.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin → «Litsenziar rekvizitlari»: faqat shu qurilmada saqlanadi.
class AdminLicensorScreen extends ConsumerStatefulWidget {
  const AdminLicensorScreen({super.key});

  @override
  ConsumerState<AdminLicensorScreen> createState() =>
      _AdminLicensorScreenState();
}

class _AdminLicensorScreenState extends ConsumerState<AdminLicensorScreen> {
  late final _address = TextEditingController(
    text: ref.read(licensorProfileProvider).address,
  );
  late final _phone = TextEditingController(
    text: ref.read(licensorProfileProvider).phone,
  );
  late final _bank = TextEditingController(
    text: ref.read(licensorProfileProvider).bank,
  );
  late final _mfo = TextEditingController(
    text: ref.read(licensorProfileProvider).mfo,
  );
  late final _account = TextEditingController(
    text: ref.read(licensorProfileProvider).account,
  );
  late final _transit = TextEditingController(
    text: ref.read(licensorProfileProvider).transitAccount,
  );
  bool _saved = false;

  @override
  void dispose() {
    for (final c in [_address, _phone, _bank, _mfo, _account, _transit]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(licensorProfileProvider.notifier)
        .save(
          LicensorProfile(
            address: _address.text.trim(),
            phone: _phone.text.trim(),
            bank: _bank.text.trim(),
            mfo: _mfo.text.trim(),
            account: _account.text.trim(),
            transitAccount: _transit.text.trim(),
          ),
        );
    if (mounted) setState(() => _saved = true);
  }

  Widget _field(String key, TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: FeSpace.xs),
    child: TextField(
      key: Key('adminLic.$key'),
      controller: c,
      onChanged: (_) => setState(() => _saved = false),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(labelText: label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.instLicensor)),
        body: SafeArea(
          child: ListView(
            key: const Key('adminLic.list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.privacy_tip_outlined,
                      text: l.instLicNote,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    _field('address', _address, l.instFAddress),
                    _field('phone', _phone, l.instFPhone),
                    _field('bank', _bank, l.instFBank),
                    _field('mfo', _mfo, l.instFMfo),
                    _field('account', _account, l.instLicAccount),
                    _field('transit', _transit, l.instLicTransit),
                    const SizedBox(height: FeSpace.xs),
                    FilledButton(
                      key: const Key('adminLic.save'),
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, FeTouch.minTarget),
                      ),
                      child: Text(l.instLicSave),
                    ),
                    if (_saved)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xs),
                        child: Text(
                          l.instLicSaved,
                          key: const Key('adminLic.saved'),
                          style: t.bodyMedium,
                        ),
                      ),
                    const SizedBox(height: FeSpace.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
