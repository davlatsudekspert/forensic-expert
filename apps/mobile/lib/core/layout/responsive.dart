import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Ekran kengligi toifalari (dp).
enum FeWidthClass { compact, medium, expanded }

abstract final class FeBreakpoints {
  /// Eng kichik qo‘llab-quvvatlanadigan kenglik — overflow testi shu yerda.
  static const double minSupportedWidth = 320;
  static const double medium = 600;
  static const double expanded = 900;

  /// O‘qish uchun qulay maksimal kontent kengligi.
  static const double maxContentWidth = 720;

  static FeWidthClass of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= expanded) return FeWidthClass.expanded;
    if (w >= medium) return FeWidthClass.medium;
    return FeWidthClass.compact;
  }

  static double gutter(BuildContext context) =>
      of(context) == FeWidthClass.compact ? FeSpace.md : FeSpace.lg;
}

/// Kontentni markazlashtiradi, maksimal kenglikni cheklaydi va
/// standart chekka bo‘shliqni (16/24 dp) beradi.
class FeContentFrame extends StatelessWidget {
  const FeContentFrame({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final g = FeBreakpoints.gutter(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? FeBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: g),
          child: child,
        ),
      ),
    );
  }
}

/// Har qanday matn o‘lchamida overflow bo‘lmasligi uchun: kontent
/// sig‘masa skroll bo‘ladi, sig‘sa ekran balandligini to‘ldiradi.
class FeScrollableBody extends StatelessWidget {
  const FeScrollableBody({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: FeContentFrame(child: child),
        ),
      ),
    );
  }
}
