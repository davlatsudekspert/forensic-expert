import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/publications.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/publications/publication_models.dart';
import '../../disciplines/discipline_strings.dart';
import '../publication_strings.dart';
import 'publication_widgets.dart';

/// Maqola yuborish: barcha maydonlar, shaxsiy ma’lumot ogohlantirishi va
/// uchta majburiy tasdiq. Qoralama saqlash yoki moderatsiyaga yuborish.
/// Server ham xuddi shu shartlarni tekshiradi (`submit_publication`).
class SubmitPublicationScreen extends ConsumerStatefulWidget {
  const SubmitPublicationScreen({super.key, this.initial});

  /// Tahrirlanadigan o‘z qoralamasi (DRAFT yoki REJECTED).
  final Publication? initial;

  @override
  ConsumerState<SubmitPublicationScreen> createState() =>
      _SubmitPublicationScreenState();
}

class _SubmitPublicationScreenState
    extends ConsumerState<SubmitPublicationScreen> {
  late final PublicationDraft _init = widget.initial == null
      ? const PublicationDraft()
      : PublicationDraft.fromPublication(widget.initial!);
  late final _title = TextEditingController(text: _init.title);
  late final _abstract = TextEditingController(text: _init.abstract);
  late final _keywords = TextEditingController(text: _init.keywords.join(', '));
  late final _authors = TextEditingController(text: _init.coauthors.join('\n'));
  late final _affiliation = TextEditingController(text: _init.affiliation);
  late final _doi = TextEditingController(text: _init.doi);
  late final _references = TextEditingController(text: _init.referenceList);
  late final _url = TextEditingController(text: _init.externalUrl);
  late String? _id = _init.id;
  late PublicationLanguage _language = _init.language;
  late String? _discipline = _init.disciplineCode;
  late bool _rights = _init.rightsConfirmed;
  late bool _consent = _init.publicationConsent;
  late bool _noPii = _init.noPersonalDataConfirmed;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _title,
      _abstract,
      _keywords,
      _authors,
      _affiliation,
      _doi,
      _references,
      _url,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  PublicationDraft get _draft => PublicationDraft(
    id: _id,
    title: _title.text,
    abstract: _abstract.text,
    keywords: PublicationDraft.splitKeywords(_keywords.text),
    language: _language,
    disciplineCode: _discipline,
    coauthors: PublicationDraft.splitLines(_authors.text),
    affiliation: _affiliation.text,
    doi: _doi.text,
    referenceList: _references.text,
    externalUrl: _url.text,
    rightsConfirmed: _rights,
    publicationConsent: _consent,
    noPersonalDataConfirmed: _noPii,
  );

  Future<void> _save({required bool submit}) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final svc = ref.read(publicationServiceProvider);
    setState(() => _busy = true);
    final id = await svc.saveDraft(_draft);
    String message;
    var done = false;
    if (id == null) {
      message = l.pubActionFailed;
    } else {
      _id = id;
      if (!submit) {
        message = l.pubDraftSaved;
      } else {
        final r = await svc.submit(id);
        done = r == SubmitResult.submitted;
        message = switch (r) {
          SubmitResult.submitted => l.pubSubmitted,
          SubmitResult.confirmationsRequired ||
          SubmitResult.incomplete => l.pubSubmitRejected,
          SubmitResult.invalidState => l.pubInvalidTransition,
          _ => l.pubActionFailed,
        };
      }
    }
    ref.invalidate(myPublicationsProvider);
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
    if (done) context.pushReplacement(Routes.publicationsMine);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final signedIn = ref.watch(authStateProvider).signedIn;
    final title = widget.initial == null ? l.pubSubmit : l.pubEditTitle;
    return PublicationsGate(
      title: title,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: signedIn
              ? _form(context, l)
              : const Center(child: PublicationsSignInPrompt()),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final canSubmit = !_busy && _draft.submitIssues.isEmpty;
    void changed(String _) => setState(() {});
    Widget gap() => const SizedBox(height: FeSpace.sm);
    final disciplines = [...ForensicDiscipline.values]
      ..sort((a, b) => l.disciplineName(a).compareTo(l.disciplineName(b)));
    return ListView(
      key: const Key('submit.form'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              gap(),
              const PublicationNotice(),
              gap(),
              FeBanner(
                key: const Key('submit.pii'),
                icon: Icons.privacy_tip_outlined,
                tone: FeBannerTone.critical,
                text: l.pubPiiWarning,
              ),
              gap(),
              TextField(
                key: const Key('submit.title'),
                controller: _title,
                maxLength: 300,
                onChanged: changed,
                decoration: InputDecoration(
                  labelText: l.pubFormTitle,
                  helperText: l.pubRequired,
                ),
              ),
              gap(),
              TextField(
                key: const Key('submit.abstract'),
                controller: _abstract,
                maxLength: 5000,
                minLines: 4,
                maxLines: 12,
                onChanged: changed,
                decoration: InputDecoration(
                  labelText: l.pubAbstract,
                  helperText: l.pubRequired,
                  alignLabelWithHint: true,
                ),
              ),
              gap(),
              DropdownButtonFormField<String>(
                key: const Key('submit.discipline'),
                initialValue: _discipline,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l.pubDiscipline,
                  helperText: l.pubRequired,
                ),
                items: [
                  for (final d in disciplines)
                    DropdownMenuItem(
                      value: d.code,
                      child: Text(
                        l.disciplineName(d),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _discipline = v),
              ),
              gap(),
              DropdownButtonFormField<PublicationLanguage>(
                key: const Key('submit.language'),
                initialValue: _language,
                decoration: InputDecoration(labelText: l.pubLanguage),
                items: [
                  for (final x in PublicationLanguage.values)
                    DropdownMenuItem(value: x, child: Text(l.pubLang(x))),
                ],
                onChanged: (v) => setState(() => _language = v ?? _language),
              ),
              gap(),
              TextField(
                key: const Key('submit.keywords'),
                controller: _keywords,
                decoration: InputDecoration(labelText: l.pubFormKeywords),
              ),
              gap(),
              TextField(
                key: const Key('submit.authors'),
                controller: _authors,
                minLines: 2,
                maxLines: 6,
                decoration: InputDecoration(labelText: l.pubFormAuthors),
              ),
              gap(),
              TextField(
                key: const Key('submit.affiliation'),
                controller: _affiliation,
                maxLength: 300,
                decoration: InputDecoration(labelText: l.pubAffiliation),
              ),
              gap(),
              TextField(
                key: const Key('submit.doi'),
                controller: _doi,
                autocorrect: false,
                decoration: InputDecoration(labelText: l.pubFormDoi),
              ),
              gap(),
              TextField(
                key: const Key('submit.url'),
                controller: _url,
                autocorrect: false,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: l.pubFormUrl),
              ),
              gap(),
              TextField(
                key: const Key('submit.references'),
                controller: _references,
                minLines: 3,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: l.pubReferences,
                  alignLabelWithHint: true,
                ),
              ),
              FeSectionHeader(l.pubConfirmationsTitle),
              CheckboxListTile(
                key: const Key('submit.confirm.rights'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _rights,
                onChanged: (v) => setState(() => _rights = v ?? false),
                title: Text(l.pubConfirmRights),
              ),
              CheckboxListTile(
                key: const Key('submit.confirm.consent'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                title: Text(l.pubConfirmConsent),
              ),
              CheckboxListTile(
                key: const Key('submit.confirm.noPii'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _noPii,
                onChanged: (v) => setState(() => _noPii = v ?? false),
                title: Text(l.pubConfirmNoPii),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                '${l.pubSubmitHint} ${l.pubPaidNote}',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              gap(),
              Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xs,
                children: [
                  OutlinedButton(
                    key: const Key('submit.saveDraft'),
                    onPressed: _busy ? null : () => _save(submit: false),
                    child: Text(l.pubSaveDraft),
                  ),
                  FilledButton(
                    key: const Key('submit.send'),
                    onPressed: canSubmit ? () => _save(submit: true) : null,
                    child: Text(l.pubSubmitForModeration),
                  ),
                ],
              ),
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}
