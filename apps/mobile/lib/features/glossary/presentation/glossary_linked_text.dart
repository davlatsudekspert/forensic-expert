import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/glossary.dart';
import '../../../core/design/theme.dart';
import '../../../domain/glossary/glossary.dart';
import 'glossary_screens.dart';

/// Matn ichidagi kanonik qisqartmalar (PMI, PMR, GC-MS, LC-MS/MS, HPLC, TLC,
/// Rf, Vd, COHb) — bosiladigan havola: lug‘atdagi qisqa izoh varag‘i
/// ([showGlossaryTermSheet]) ochiladi. Izohi yo‘q qisqartma oddiy matn.
class GlossaryLinkedText extends ConsumerStatefulWidget {
  const GlossaryLinkedText(
    this.text, {
    super.key,
    this.style,
    this.selectable = false,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final bool selectable;
  final TextAlign? textAlign;

  /// [text] dagi qisqartmalar (tartibda; testlar va hisobot uchun).
  static List<String> abbreviationsIn(String text, Glossary glossary) => [
    for (final m
        in _pattern(glossary)?.allMatches(text) ?? const <RegExpMatch>[])
      m[1]!,
  ];

  static RegExp? _pattern(Glossary glossary) {
    final abbrs = glossary.abbreviations.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    if (abbrs.isEmpty) return null;
    // «GC-MS/MS» ichidagi «GC-MS» havola emas; so‘z ichidagi harflar ham.
    return RegExp(
      '(?<![A-Za-z0-9/-])(${abbrs.map(RegExp.escape).join('|')})'
      r'(?![A-Za-z0-9-]|/[A-Za-z])',
    );
  }

  @override
  ConsumerState<GlossaryLinkedText> createState() => _GlossaryLinkedTextState();
}

class _GlossaryLinkedTextState extends ConsumerState<GlossaryLinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final glossary = ref.watch(glossaryProvider);
    final c = FeTheme.of(context);
    final pattern = GlossaryLinkedText._pattern(glossary);
    final text = widget.text;
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in pattern?.allMatches(text) ?? const <RegExpMatch>[]) {
      final term = glossary.byAbbreviation(m[1]!);
      if (term == null) continue;
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final r = TapGestureRecognizer()
        ..onTap = () => showGlossaryTermSheet(context, term);
      _recognizers.add(r);
      spans.add(
        TextSpan(
          text: m[1],
          recognizer: r,
          style: TextStyle(
            color: c.accent,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: c.accent,
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    final span = TextSpan(style: widget.style, children: spans);
    return widget.selectable
        ? SelectableText.rich(span, textAlign: widget.textAlign)
        : Text.rich(span, textAlign: widget.textAlign);
  }
}
