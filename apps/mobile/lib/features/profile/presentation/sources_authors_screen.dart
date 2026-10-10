import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
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

  /// (sarlavha, [(yorliq, qiymat)]) — tartib: amaliyot yo‘riqnomasi (ABY),
  /// Giyohvand moddalar tahlili, Toksikologik kimyo majmuasi, so‘ng ilova
  /// muallifi. Ro‘yxatga yangi manba faqat egasi tasdiqlagandan keyin
  /// qo‘shiladi.
  static const entries = <(String, List<(String, String)>)>[
    (
      'Sud-tibbiyot ekspertiza (tekshiruv)lari amaliyotlarini bajarish '
          'yo‘riqnomasi (ABY). Toshkent, 2025. 439 bet',
      [
        (
          'Tashkilot',
          'O‘zbekiston Respublikasi Sog‘liqni saqlash vazirligi, '
              'Respublika sud-tibbiy ekspertiza ilmiy-amaliy markazi',
        ),
        (
          'Tuzuvchilar',
          'Sh.I. Ro‘ziev, S.I. Indiaminov, O.I. Xvan, A.S. Umarov, '
              'J.X. Xoshimova, X.I. Primuxamedova, A.M. Hamdamov, '
              'K.I. Ikromov, A.Z. Otamurodov',
        ),
        (
          'Taqrizchilar',
          'Q.A. Maxsumxonov (t.f.d., dotsent), I.I. Baxriev (t.f.n., dotsent), '
              'N. Burankulova (PhD)',
        ),
        (
          'Eslatma',
          'Yo‘riqnoma ilovada manba sifatida keltiriladi: matni ko‘chirilmaydi, '
              'mazmuni o‘z so‘zlarimiz bilan beriladi va har bir yozuvda '
              'yo‘riqnomaning o‘z raqamlash tartibi ko‘rsatiladi '
              '(masalan, «ABY, G bo‘limi, № ABY.G.16.2025, 2.3-band»). '
              'Yozuvlar bepul; ilmiy taqriz kutilmoqda.',
        ),
      ],
    ),
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
    // Sahifa faqat o‘zbek tilida mavjud: matn tarjima qilinmaydi va ro‘yxatdagi
    // manbalar ham boshqa tillarda ko‘rsatilmaydi. Havola ham chiqmaydi, lekin
    // to‘g‘ridan-to‘g‘ri yo‘l bilan kelinsa bo‘sh holat ko‘rsatiladi.
    if (Localizations.localeOf(context).languageCode != languageCode) {
      return Scaffold(
        appBar: AppBar(),
        body: FeEmptyState(
          icon: Icons.inbox_outlined,
          body: AppLocalizations.of(context).knowledgeEmpty,
        ),
      );
    }
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
