import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import 'qa_widgets.dart';

/// «Savol-javob» hamjamiyati qoidalari.
///
/// Ikki narsa ajratilgan: maxfiylik (ish materiali yozilmaydi) va
/// qonuniylik (xulosani buzishga, dalilni yashirishga yoki zarar
/// yetkazishga qaratilgan iltimoslar taqiqlanadi). Matn uch tilda teng.
class QaRulesScreen extends StatelessWidget {
  const QaRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;

    Widget bullet(String text, {Color? color, IconData? icon}) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon ?? Icons.check_circle_outline,
              size: 18,
              color: color ?? c.verified,
            ),
          ),
          const SizedBox(width: FeSpace.xs),
          Expanded(child: Text(text, style: t.bodyMedium)),
        ],
      ),
    );

    return QaGate(
      title: l.qaRulesTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.qaRulesTitle)),
        body: SafeArea(
          child: ListView(
            key: const Key('qa.rules'),
            children: [
              FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    Text(l.qaRulesIntro, style: t.bodyMedium),
                    FeSectionHeader(l.qaRulesPurposeTitle),
                    Text(l.qaRulesPurposeBody, style: t.bodyMedium),
                    FeSectionHeader(l.qaRulesGoodTitle),
                    bullet(l.qaRulesGood1),
                    bullet(l.qaRulesGood2),
                    bullet(l.qaRulesGood3),
                    bullet(l.qaRulesGood4),
                    FeSectionHeader(l.qaRulesForbiddenTitle),
                    // Taqiqlar boshqa ikonka va rang bilan — ro‘yxat
                    // ko‘rinishidanoq ajralib tursin.
                    bullet(
                      l.qaRulesForbidden1,
                      icon: Icons.block,
                      color: c.danger,
                    ),
                    bullet(
                      l.qaRulesForbidden2,
                      icon: Icons.block,
                      color: c.danger,
                    ),
                    bullet(
                      l.qaRulesForbidden3,
                      icon: Icons.block,
                      color: c.danger,
                    ),
                    bullet(
                      l.qaRulesForbidden4,
                      icon: Icons.block,
                      color: c.danger,
                    ),
                    bullet(
                      l.qaRulesForbidden5,
                      icon: Icons.block,
                      color: c.danger,
                    ),
                    bullet(
                      l.qaRulesForbidden6,
                      icon: Icons.block,
                      color: c.danger,
                    ),
                    FeSectionHeader(l.qaRulesAnswerTitle),
                    bullet(l.qaRulesAnswer1),
                    bullet(l.qaRulesAnswer2),
                    bullet(l.qaRulesAnswer3),
                    FeSectionHeader(l.qaRulesEnforceTitle),
                    FeBanner(
                      key: const Key('qa.rules.enforcement'),
                      icon: Icons.gavel_outlined,
                      tone: FeBannerTone.warning,
                      text: l.qaRulesEnforceBody,
                    ),
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
