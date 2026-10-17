import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/qa.dart';
import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/qa/qa_models.dart';
import '../../moderation/presentation/moderation_widgets.dart';
import '../qa_strings.dart';
import 'qa_widgets.dart';

/// Savol berish formasi.
///
/// Maxfiylik ogohlantirishi forma ustida doimo turadi; haqiqiy filtr esa
/// serverda ishlaydi — mijoz tekshiruvi uni almashtirmaydi.
class QaAskScreen extends ConsumerStatefulWidget {
  const QaAskScreen({super.key});

  @override
  ConsumerState<QaAskScreen> createState() => _QaAskScreenState();
}

class _QaAskScreenState extends ConsumerState<QaAskScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _tags = <String>{};
  bool _sending = false;
  QaPostResult? _result;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _valid =>
      _title.text.trim().length >= 10 && _body.text.trim().length >= 30;

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    // Birinchi yozishdan oldin hamjamiyat qoidalari qabul qilinadi.
    if (!await ensureCommunityTerms(context, ref)) return;
    if (!mounted) return;
    setState(() {
      _sending = true;
      _error = null;
      _result = null;
    });
    final lang = QaLang.fromLocale(
      Localizations.localeOf(context).languageCode,
    );
    final out = await ref
        .read(qaServiceProvider)
        .ask(
          lang: lang,
          title: _title.text.trim(),
          body: _body.text.trim(),
          tags: _tags.toList(),
        );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _result = out;
      _error = out == null ? l.qaSendFailed : null;
    });
    if (out != null && !out.held && out.id != null) {
      ref.invalidate(qaFeedProvider);
      if (mounted) context.pushReplacement(Routes.qaQuestion(out.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tags = ref.watch(qaMeProvider).value?.tags ?? const <String>[];
    return QaGate(
      title: l.qaAskTitle,
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.qaAskTitle)),
        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            key: const Key('qa.ask.form'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    const QaPrivacyWarning(),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.qaNoImages,
                      key: const Key('qa.noImages'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: const Key('qa.ask.rules'),
                        onPressed: () => context.push(Routes.qaRules),
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: Text(l.qaRulesOpen),
                      ),
                    ),
                    const SizedBox(height: FeSpace.md),
                    TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      key: const Key('qa.ask.title'),
                      controller: _title,
                      maxLength: 160,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l.qaFieldTitle,
                        errorText:
                            _title.text.isNotEmpty &&
                                _title.text.trim().length < 10
                            ? l.qaTitleTooShort
                            : null,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      key: const Key('qa.ask.body'),
                      controller: _body,
                      maxLines: 8,
                      minLines: 4,
                      maxLength: 4000,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l.qaFieldBody,
                        alignLabelWithHint: true,
                        errorText:
                            _body.text.isNotEmpty &&
                                _body.text.trim().length < 30
                            ? l.qaBodyTooShort
                            : null,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      l.qaFieldTopics,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: FeSpace.xxs),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        for (final tag in tags)
                          FilterChip(
                            key: Key('qa.ask.tag.$tag'),
                            label: Text(l.qaTag(tag)),
                            selected: _tags.contains(tag),
                            onSelected: (on) => setState(() {
                              if (on && _tags.length < 5) {
                                _tags.add(tag);
                              } else {
                                _tags.remove(tag);
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.md),
                    FilledButton(
                      key: const Key('qa.ask.send'),
                      onPressed: _valid && !_sending ? _send : null,
                      child: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.qaSend),
                    ),
                    if (_result?.held ?? false) ...[
                      const SizedBox(height: FeSpace.sm),
                      QaFlagsNotice(_result!.flags),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: FeSpace.sm),
                      Text(_error!, key: const Key('qa.ask.error')),
                    ],
                    const SizedBox(height: FeSpace.xxl),
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
