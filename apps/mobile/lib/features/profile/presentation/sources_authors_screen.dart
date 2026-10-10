import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';

/// «Manbalar va mualliflar» (Profil → Ilova haqida). Sokin, rasmiy sahifa:
/// bitta minnatdorchilik jumlasi, qolgani faktlar. Faqat o‘zbek tilida
/// ko‘rsatiladi (ruscha/inglizcha interfeysda sahifaga havola ham chiqmaydi);
/// matn hujjat nomlari va ismlardan iborat — ular tarjima qilinmaydi.
/// Barcha foydalanuvchilar uchun bepul (paywall yo‘q).
class SourcesAuthorsScreen extends StatelessWidget {
  const SourcesAuthorsScreen({super.key});

  /// Havola faqat shu tilda ko‘rsatiladi.
  static const languageCode = 'uz';

  /// Sahifa va havola sarlavhasi.
  static const title = 'Manbalar va mualliflar';

  /// Bitta qisqa minnatdorchilik jumlasi.
  static const intro =
      'Ilovadagi ma’lumotlarning bir qismi quyidagi mualliflarning '
      'mehnati asosida tayyorlangan; ularga minnatdorchilik bildiramiz.';

  /// (sarlavha, [(yorliq, qiymat)]) — tartib: Giyohvand moddalar tahlili,
  /// Toksikologik kimyo majmuasi, so‘ng ilova muallifi. Ro‘yxatga yangi
  /// manba faqat egasi tasdiqlagandan keyin qo‘shiladi.
  static const entries = <(String, List<(String, String)>)>[
    (
      '«Giyohvand moddalar tahlili» (o‘quv qo‘llanma, 2024)',
      [
        (
          'Mualliflar',
          'Z.A. Yuldashev, D.A. Zulfikariyeva, Z.U. Usmanaliyeva, M.I. Nurmatova',
        ),
        ('Eslatma', 'Muallifning yozma ruxsati bilan foydalanilgan.'),
      ],
    ),
    (
      '«Toksikologik kimyo» (o‘quv-uslubiy majmua, 2025)',
      [
        (
          'Tashkilot',
          'Toshkent farmatsevtika instituti, toksikologik kimyo kafedrasi',
        ),
        (
          'Tuzuvchilar',
          'Z.A. Yuldashev (professor, farm.f.d.), G.Q. Umarova (assistent, PhD)',
        ),
        ('Eslatma', 'Muallifning yozma ruxsati bilan foydalanilgan.'),
      ],
    ),
    (
      'Ilova muallifi',
      [('Muallif', 'Yo‘ldashali Abduraxmonov Toshtemirovich')],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(SourcesAuthorsScreen.title)),
      body: SafeArea(
        child: ListView(
          key: const Key('sourcesAuthors.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    SourcesAuthorsScreen.intro,
                    key: const Key('sourcesAuthors.intro'),
                    style: t.bodyMedium,
                  ),
                  for (final (title, rows) in entries) ...[
                    FeSectionHeader(title),
                    FeCard(
                      padding: const EdgeInsets.all(FeSpace.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (label, value) in rows)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: FeSpace.xxs,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: t.labelMedium?.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                  Text(value, style: t.bodyMedium),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
