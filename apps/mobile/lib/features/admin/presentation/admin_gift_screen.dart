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
