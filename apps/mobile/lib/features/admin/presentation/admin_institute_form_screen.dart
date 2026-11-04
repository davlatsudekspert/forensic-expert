import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/institutes.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/admin/institute_models.dart';
import 'admin_codes_widgets.dart';
import 'admin_gate.dart';

/// «Yangi tashkilot» formasi: nom, o‘rinlar, muddat (oy), boshlanish sanasi.
/// Saqlangach promokodlar chiqadi.
class AdminInstituteFormScreen extends ConsumerStatefulWidget {
  const AdminInstituteFormScreen({super.key});

  @override
  ConsumerState<AdminInstituteFormScreen> createState() =>
      _AdminInstituteFormScreenState();
}

class _AdminInstituteFormScreenState
    extends ConsumerState<AdminInstituteFormScreen> {
  final _name = TextEditingController();
  final _seats = TextEditingController();
  final _months = TextEditingController();
  DateTime? _termStart;
  bool _busy = false;
  String? _error;
  IssuedCodes? _issued;

  @override
  void dispose() {
    for (final c in [_name, _seats, _months]) {
      c.dispose();
    }
    super.dispose();
  }

  InstituteDraft _draft() => InstituteDraft(
    name: _name.text.trim(),
    seats: int.tryParse(_seats.text.trim()) ?? 0,
    months: int.tryParse(_months.text.trim()) ?? 0,
    termStart: _termStart,
  );

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final d = _draft();
    if (!d.isValid) {
      setState(() => _error = l.instFInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(adminInstituteServiceProvider).create(d);
    if (!mounted) return;
    ref.invalidate(adminInstitutesProvider);
    setState(() {
      _busy = false;
      _issued = r.value;
      if (r.value == null) _error = l.instFError;
    });
  }

  Future<DateTime?> _pick(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  Widget _field(
    String key,
    TextEditingController c,
    String label, {
    TextInputType? type,
    ValueChanged<String>? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: FeSpace.xs),
    child: TextField(
      key: Key('adminInstForm.$key'),
      controller: c,
      enabled: !_busy,
      keyboardType: type,
      onChanged: onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget _dateButton(
    String key,
    String label,
    DateTime? value,
    ValueChanged<DateTime> onPicked,
  ) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: OutlinedButton.icon(
        key: Key('adminInstForm.$key'),
        onPressed: _busy
            ? null
            : () async {
                final d = await _pick(value);
                if (d != null) onPicked(d);
              },
        icon: const Icon(Icons.event_outlined),
        label: Text(
          '$label: ${value == null ? l.instFPickDate : feDate(context, value)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final issued = _issued;
    return AdminGate(
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.instNew)),
        body: SafeArea(
          child: ListView(
            key: const Key('adminInstForm.list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    if (issued != null) ...[
                      FeBanner(
                        key: const Key('adminInstForm.created'),
                        icon: Icons.check_circle_outline,
                        text: l.instCreated(issued.codes.length),
                        tone: FeBannerTone.review,
                      ),
                      CreatedCodesView(
                        codes: issued.codes,
                        keyPrefix: 'adminInstForm.codes',
                      ),
                      const SizedBox(height: FeSpace.sm),
                      if (issued.instituteId != null)
                        FilledButton(
                          key: const Key('adminInstForm.open'),
                          onPressed: () => context.pushReplacement(
                            Routes.adminInstitute(issued.instituteId!),
                          ),
                          child: Text(l.instOpen),
                        ),
                    ] else ...[
                      _field(
                        'name',
                        _name,
                        l.instFName,
                        onChanged: (_) => setState(() {}),
                      ),
                      _field(
                        'seats',
                        _seats,
                        l.instFSeats,
                        type: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      _field(
                        'months',
                        _months,
                        l.instFMonths,
                        type: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      _dateButton(
                        'termStart',
                        l.instFTermStart,
                        _termStart,
                        (v) => setState(() => _termStart = v),
                      ),
                      FilledButton(
                        key: const Key('adminInstForm.save'),
                        onPressed: _busy ? null : _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, FeTouch.minTarget),
                        ),
                        child: _busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l.instFSave),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: FeSpace.xs),
                          child: Text(
                            _error!,
                            key: const Key('adminInstForm.error'),
                            style: t.bodyMedium?.copyWith(color: c.danger),
                          ),
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
