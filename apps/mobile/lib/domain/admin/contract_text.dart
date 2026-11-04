/// Litsenziya shartnomasi matni (egasi tasdiqlagan shablon, 2026-11-04) va
/// 1-ilova. Matn shablondan aynan ko‘chirilgan: [qavs] ichidagi va `____`
/// bo‘sh joylar PDF’da ham qoladi; FAQAT institut ma’lumotlari (nomi, manzil,
/// STIR, bank, hisob, MFO, rahbar, tel., shartnoma raqami/sanasi, o‘rinlar,
/// oylar, boshlanish/tugash sanasi, narx, jami) forma qiymati bilan to‘ldiriladi.
/// Litsenziar rekvizitlari kodda YO‘Q: [LicensorProfile] orqali (admin
/// qurilmasidagi sozlama) qo‘yiladi.
library;

import 'institute_models.dart';

/// Bo‘sh chiziq (qo‘lda to‘ldirish uchun).
const kBlank = '________________';
const _longBlank = '____________________';
const _nameBlank = '____________________________';

/// Shartnoma uchun kirish ma’lumotlari.
class ContractData {
  const ContractData({
    required this.institute,
    this.licensor = LicensorProfile.empty,
  });

  final InstituteDetail institute;
  final LicensorProfile licensor;
}

/// PDF’ga o‘tkaziladigan blok turlari.
enum ContractBlockKind {
  title,
  subtitle,
  spread,
  heading,
  paragraph,
  parties,
  labeled,
  table,
  signatures,
  note,
  pageBreak,
}

class ContractBlock {
  const ContractBlock(
    this.kind, [
    this.text = '',
    this.text2 = '',
    this.rows = const [],
  ]);

  final ContractBlockKind kind;

  /// `labeled` da — qalin sarlavha; `spread`/`parties` da — chap qism.
  final String text;

  /// `labeled` da — oddiy matn; `spread`/`parties` da — o‘ng qism.
  final String text2;

  /// `table` da birinchi qator — sarlavha.
  final List<List<String>> rows;
}

/// «4» noyabr 2026-yil; sana yo‘q bo‘lsa — shablondagi bo‘sh joy.
String contractDate(DateTime? d) {
  if (d == null) return '«___» ____________ 20___-yil';
  return '«${d.day}» ${_months[d.month - 1]} ${d.year}-yil';
}

const _months = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktabr',
  'noyabr',
  'dekabr',
];

String _or(String v, [String blank = kBlank]) => v.trim().isEmpty ? blank : v;

/// Shartnoma asosiy matni (1–11 bandlar) + 1-ilova (kodlarsiz).
List<ContractBlock> buildContractBlocks(ContractData cd) {
  final i = cd.institute;
  final l = cd.licensor;
  const b = kBlank;
  final seats = i.seats > 0 ? '${i.seats}' : b;
  final months = i.months > 0 ? '${i.months}' : b;
  final price = i.pricePerSeat > 0 ? formatSom(i.pricePerSeat) : b;
  final total = i.seats > 0 && i.months > 0 && i.pricePerSeat > 0
      ? formatSom(i.total)
      : b;
  final no = _or(i.contractNo);
  final director = _or(i.director);
  final name = _or(i.name, _nameBlank);
  final sections = <(String, List<String>)>[
    (
      '1. SHARTNOMA PREDMETI VA LITSENZIYA DOIRASI',
      [
        '1.1. Litsenziar “Forensic Expert” mobil ilovasining (Android va iOS; keyingi o‘rinlarda «Ilova») huquq egasi hisoblanadi. Litsenziar Buyurtmachiga Ilovaning «Ustoz Pro» funksiyalaridan ushbu shartnomada belgilangan muddat, hudud va o‘rinlar soni doirasida foydalanish uchun oddiy (nomutlaq) litsenziya beradi. Ilovaga nisbatan Litsenziarga tegishli mutlaq mulkiy huquqlar Litsenziarda qoladi va ushbu shartnoma bo‘yicha Buyurtmachiga o‘tmaydi.',
        '1.2. Foydalanish doirasi. Litsenziya Ilovada «Ustoz Pro» deb belgilangan funksiyalardan foydalanishni qamrab oladi. Funksiyalar ro‘yxati shartnoma imzolangan sanadagi Ilova versiyasi bo‘yicha 1-ilovaning 4-bandida ko‘rsatiladi: [ro‘yxat to‘ldiriladi]. Ilova rivojlantirilganda funksiyalar tarkibi o‘zgarishi mumkin; [«Ustoz Pro»ning asosiy funksiyalari shartnoma muddati davomida mazmunan kamaytirilmaydi — kelishiladi].',
        '1.3. Foydalanish hududi: $b [taklif: O‘zbekiston Respublikasi hududi]. Litsenziyadan faqat Buyurtmachining shartnomada ko‘rsatilgan ustozlari, ularning ta’lim faoliyati doirasida foydalanadi. Litsenziya Android va iOS’dagi Ilova uchun amal qiladi.',
        '1.4. O‘rinlar soni: $seats ta. Har bir o‘rin bitta jismoniy shaxsga (ustozga) tegishli bo‘lib, uning Ilovadagi hisobiga (elektron pochta manziliga) bog‘lanadi. Bir hisobdan bir vaqtda foydalanish mumkin bo‘lgan qurilmalar soni uchtagacha (3). O‘rin bir hisobdan boshqasiga faqat 4.5-bandda ko‘rsatilgan tartibda o‘tkaziladi.',
        '1.5. Talabalar uchun bepul funksiyalar. Ustozlarning guruhidagi talabalar Ilovadan ushbu shartnoma doirasida quyidagi funksiyalardan bepul foydalanadi: ustoz tomonidan berilgan testni yechish; QR-kod orqali o‘tkaziladigan og‘zaki bilet va savollarga javob berish; o‘z natijasini hamda to‘g‘ri javoblarni ko‘rish; Ilovadagi mavzular va dars materiallarini o‘qish; kutubxonalardan («Usullar» bo‘limidan tashqari) foydalanish. Talabalar soni shartnomada cheklanmaydi. Talabaning o‘zini o‘zi tayyorlashga mo‘ljallangan funksiyalari (masalan, matnni tinglash, mustaqil test banki, kartochkalar, imtihon rejimi, xatolar tahlili, sun’iy intellekt yordamchisi, oflayn yuklash) ushbu shartnoma bilan berilmaydi va talaba tomonidan alohida, Ilovaning amaldagi shartlari bo‘yicha olinadi. [Funksiyalarning bepul/pullik bo‘linishi Ilovada joriy qilingan holat bilan 1-ilovaning 4-bandida tasdiqlanadi.]',
        '1.6. Qayta sotish va sublitsenziya. Buyurtmachi litsenziyani, kodlarni yoki ulardan olingan huquqlarni uchinchi shaxslarga sotishi, berishi, ijaraga yoki sublitsenziyaga topshirishi mumkin emas.',
        '1.7. Litsenziya bir martalik kodlar (promokodlar) orqali beriladi. Kodlarni topshirish tartibi 2-bo‘limda va 1-ilovada belgilangan. Ustoz kodni Ilovaning «Profil» bo‘limida kiritadi; tizim kodni qabul qilgach, ustoz hisobiga «Ustoz Pro» ochiladi va profilda Buyurtmachi nomi hamda muddat ko‘rsatiladi.',
      ],
    ),
    (
      '2. MUDDAT VA ISHLARNING BOSQICHLARI',
      [
        '2.1. Shartnoma imzolangan kundan kuchga kiradi va tomonlar majburiyatlarini to‘liq bajarguncha amal qiladi.',
        '2.2. Bajarilish bosqichlari alohida bo‘lib, quyidagi tartibda amalga oshiriladi: (a) Buyurtmachi to‘lovni amalga oshiradi va u Litsenziar hisobiga tushadi (3-bo‘lim); (b) Litsenziar kodlarni topshiradi — to‘lov tushgan kundan keyin $b ish kuni ichida, Buyurtmachi vakiliga, 1-ilovada ko‘rsatilgan yopiq kanal orqali; (c) ustozlar kodlarni Ilovada o‘zlari faollashtiradi — Buyurtmachi bu haqida ustozlarga xabar beradi.',
        '2.3. Litsenziya muddati: kodlar topshirilgan sanadan boshlab $months oy [yoki $b dan $b gacha — bittasini qoldiring]. Muddat boshlanishi kodlarning topshirilish sanasi bilan belgilanadi va ustozlar kodni qachon faollashtirishiga bog‘liq emas. Kodlarning faollashtirish muddati litsenziya muddati tugagunga qadar. Kodlarni topshirish sanasi tomonlar tomonidan yozma (elektron xabar bilan) tasdiqlanadi.',
        '2.4. Muddat tugagach, ustozlarning «Ustoz Pro» imkoniyatlari yopiladi. Hisoblar, guruhlar va natijalar bilan nima bo‘lishi 6.7-bandda belgilangan. Muddat tomonlarning yozma kelishuvi bilan uzaytiriladi.',
      ],
    ),
    (
      '3. NARX VA TO‘LOV TARTIBI',
      [
        '3.1. Litsenziya narxi $total (so‘z bilan: ____________________) so‘mni tashkil etadi. Narx hisob-kitobi: bitta o‘rin narxi ($price so‘m/oy) × o‘rinlar soni ($seats) × oylar soni ($months). Soliq to‘lash tartibi amaldagi qonunchilikka muvofiq belgilanadi: [soliq va QQS bandi tasdiqlangach to‘ldiriladi].',
        '3.2. Buyurtmachi to‘lovni shartnoma imzolangan kundan boshlab $b bank kuni ichida pul o‘tkazish yo‘li bilan, Litsenziarning 11-bo‘limda ko‘rsatilgan rekvizitlariga amalga oshiradi. To‘lov maqsadida shartnoma raqami va sanasi ko‘rsatiladi.',
        '3.3. To‘lov Litsenziarning hisobiga pul tushgan sanadan boshlab to‘langan hisoblanadi. Kodlarni topshirish muddati (2.2-band «b» bosqichi) to‘lov tushgan sanadan boshlanadi. Litsenziar to‘lov tushganini va kodlar topshirilganini Buyurtmachiga yozma xabar qiladi; Buyurtmachi kodlarni qabul qilganini $b kun ichida yozma tasdiqlaydi.',
      ],
    ),
    (
      '4. TOMONLARNING HUQUQ VA MAJBURIYATLARI',
      [
        '4.1. Litsenziar: to‘lov tushgach, kodlarni 2.2-bandda ko‘rsatilgan muddatda va tartibda topshiradi; Ilovaning shartnoma muddati davomida ishlashi uchun oqilona choralarni ko‘radi; rejalashtirilgan texnik ishlar haqida iloji boricha oldindan xabar beradi.',
        '4.2. Litsenziar Ilovaning uzluksiz va xatosiz ishlashini, shuningdek tashqi tizimlar (ilova do‘konlari, aloqa, server xizmatlari) ishlashini kafolatlamaydi, lekin aniqlangan nosozliklarni oqilona muddatda bartaraf etishga harakat qiladi. Nosozlik $b ketma-ket kundan ortiq davom etsa, 8.2-band qo‘llanadi.',
        '4.3. Buyurtmachi: kodlarni faqat o‘z ustozlariga beradi; kodlarni uchinchi shaxslarga bermaydi, sotmaydi va ommaga e’lon qilmaydi; har bir hisob bitta shaxs tomonidan foydalaniladi; 1.6-bandni buzmaydi.',
        '4.4. Bir hisobdan uchtadan ortiq qurilmada bir vaqtda foydalanish cheklanadi. Qoida buzilsa, Litsenziar hisobni vaqtincha cheklash huquqiga ega, bu haqida Buyurtmachiga xabar beradi.',
        '4.5. Ustoz ishdan ketsa yoki almashsa, Buyurtmachi Litsenziarga xabar beradi; Litsenziar o‘rinni bo‘shatib, boshqa ustozga beradi (litsenziya muddati doirasida va o‘rinlar soni oshmagan holda). Almashtirish soni: $b marta [kelishiladi].',
        '4.6. Materiallardan foydalanish chegarasi. Ilovadagi o‘quv materiallaridan (matn, slayd, savol, tasvir, audio) ustozlar va talabalar Ilovaning o‘zida, ta’lim jarayoni doirasida foydalanadi; auditoriyada namoyish qilish (proyektor, ekran orqali) uchun foydalanish mumkin. Quyidagilar taqiqlanadi: materiallarni Ilovadan tashqarida ko‘paytirish, nusxalash, ommaviy tarqatish (jumladan messenjerlar, ijtimoiy tarmoqlar, sayt, bosma nashr), qayta sotish, o‘zgartirib nashr etish, avtomatik yuklab olish yoki boshqa tizimlarga (jumladan sun’iy intellekt tizimlariga) o‘rgatish uchun foydalanish. Ilovaning o‘z funksiyalari (guruhga qo‘shish, QR-kod, test) orqali ulashish ushbu taqiqqa kirmaydi. Uchinchi tomon materiallari bo‘yicha 5.2-bandda belgilangan qo‘shimcha cheklovlar qo‘llanadi.',
      ],
    ),
    (
      '5. INTELLEKTUAL MULK VA MATERIALLAR',
      [
        '5.1. Litsenziarga tegishli huquqlar. Ilovaning dasturiy kodi, interfeysi va dizayni, ma’lumotlar tuzilishi, Ilova nomi va belgilari, shuningdek Litsenziar tomonidan yaratilgan materiallar bo‘yicha mutlaq mulkiy huquqlar Litsenziarga tegishli. Buyurtmachiga faqat 1-bo‘limda belgilangan doirada foydalanish huquqi beriladi.',
        '5.2. Uchinchi tomon materiallari. Ilovada mualliflar va boshqa huquq egalariga tegishli materiallar (masalan, kitoblar, o‘quv-uslubiy majmualar, tashqi manbalardan iqtiboslar) bo‘lishi mumkin. Ular huquq egasining ruxsati, ochiq litsenziya yoki qonunda ruxsat etilgan boshqa asos bilan joylashtiriladi; manba Ilovada ko‘rsatiladi. Ushbu shartnoma uchinchi tomon materiallariga bo‘lgan huquqni Buyurtmachiga o‘tkazmaydi va Litsenziar bu materiallar bo‘yicha huquq egalarining huquqlarini cheklamaydi. Huquq egasi talab qilsa yoki qonunga muvofiq zarur bo‘lsa, Litsenziar tegishli materialni Ilovadan olib tashlashi, o‘zgartirishi yoki almashtirishi mumkin; bu shartnomani buzish hisoblanmaydi. Agar bu Ustoz Pro’ning muhim qismiga ta’sir qilsa, tomonlar narxni qayta ko‘rib chiqish masalasini kelishadilar [kelishiladi].',
      ],
    ),
    (
      '6. SHAXSGA DOIR MA’LUMOTLAR',
      [
        '6.1. Tomonlar shaxsga doir ma’lumotlarni qayta ishlashda O‘zbekiston Respublikasining amaldagi shaxsga doir ma’lumotlar to‘g‘risidagi qonunchiligiga amal qiladilar.',
        '6.2. Qayta ishlovchi va maqsad. Foydalanuvchilar (ustozlar va talabalar) ma’lumotlarini Litsenziar Ilovani yuritish maqsadida qayta ishlaydi: tizimga kirish va hisobni yuritish; guruh va testlarni o‘tkazish; «Ustoz Pro» huquqini tekshirish; xavfsizlik va texnik qo‘llab-quvvatlash. Ma’lumotlar bulutli server xizmati provayderlarida saqlanadi [provayderlar va serverlar joylashuvi aniqlashtiriladi]. Ma’lumotlar reklama maqsadida uchinchi shaxslarga berilmaydi.',
        '6.3. Qayta ishlanadigan ma’lumotlar: elektron pochta manzili, Ilovadagi ism, guruh a’zoligi, test natijalari va javoblari, kirish va qurilma bo‘yicha texnik ma’lumotlar [ro‘yxat Ilovaning amaldagi tuzilishi bo‘yicha tasdiqlanadi].',
        '6.4. Natijalarni kim ko‘radi. Talaba natijasini o‘zi ko‘radi; guruh ustozi o‘z guruhi talabalarining natijalarini ko‘radi; Litsenziar tizim ma’muri sifatida texnik qo‘llab-quvvatlash va xavfsizlik uchun zarur doirada ma’lumotlarga kirish huquqiga ega. Buyurtmachi (muassasa ma’muriyati) ustozlarning shaxsiy ma’lumotlariga va talabalarning individual natijalariga ushbu shartnoma bo‘yicha kirish huquqiga ega emas; unga faqat jamlangan hisobotlar (masalan, faol ustozlar soni, o‘tkazilgan testlar soni) taqdim etilishi mumkin [individual natijalarni taqdim etish talab qilinsa, alohida kelishuv va foydalanuvchining roziligi/qonuniy asosi bilan].',
        '6.5. Buyurtmachi ustozlarni, ustozlar esa talabalarni Ilovada ma’lumotlar qayta ishlanishi to‘g‘risida xabardor qiladi. Roziliklar Ilovada [rozilik oynasi va maxfiylik siyosati — tekshiriladi] orqali olinadi.',
        '6.6. Xavfsizlik. Litsenziar ma’lumotlarni ruxsatsiz kirish va yo‘qolishdan oqilona himoya qiladi. Ma’lumotlar xavfsizligi buzilgan holda Litsenziar Buyurtmachini $b kun ichida xabardor qiladi [muddat kelishiladi].',
        '6.7. Saqlash va muddat tugagandan keyin. Muddat tugagach, ustoz hisobi, guruhlar va test natijalari $b oy saqlanadi [saqlash muddati Ilovaning amaldagi sozlamasi bo‘yicha aniqlanadi], foydalanuvchi so‘rovi bilan hisob va ma’lumotlar o‘chirilishi mumkin [Ilovada hisobni o‘chirish usuli tasdiqlanadi]. Buyurtmachi so‘rasa, shartnoma tugagandan keyin $b kun ichida ma’lumotlarni qayta ishlash to‘xtatiladi yoki qonunda ruxsat etilgan hollarda anonimlashtiriladi.',
      ],
    ),
    (
      '7. JAVOBGARLIK',
      [
        '7.1. Ilova ta’lim va ma’lumot maqsadlariga mo‘ljallangan. Uning materiallari sud-tibbiy yoki sud-kimyoviy ekspertiza xulosasi, tibbiy tashxis yoki davolash bo‘yicha rasmiy ko‘rsatma o‘rnini bosmaydi. Ilovadan olingan ma’lumot asosida qabul qilingan qarorlar uchun Litsenziar javobgar emas.',
        '7.2. Tomonlar shartnoma majburiyatlarini buzganlik uchun amaldagi qonunchilikka muvofiq javobgar bo‘ladilar. Litsenziarning javobgarligi, qonunda boshqacha tartib nazarda tutilmagan bo‘lsa, Buyurtmachi to‘lagan shartnoma qiymati doirasida cheklanadi.',
        '7.3. Tomonlar o‘zlariga bog‘liq bo‘lmagan favqulodda holatlar (fors-major) sababli majburiyatlarni bajara olmasa, javobgardan ozod qilinadi va bu haqida ikkinchi tomonga imkon qadar tezroq xabar beradi.',
      ],
    ),
    (
      '8. PULNI QAYTARISH, SHARTNOMANI O‘ZGARTIRISH VA BEKOR QILISH',
      [
        '8.1. Kirish berilmasa. Litsenziar kodlarni 2.2-bandda ko‘rsatilgan muddatda topshirmasa (Buyurtmachi aybisiz), Buyurtmachi $b kunlik qo‘shimcha muddat belgilaydi. Shu muddatda ham kodlar topshirilmasa, Buyurtmachi shartnomani bekor qilib, to‘langan summani to‘liq qaytarishni talab qilishi mumkin; Litsenziar summani $b bank kuni ichida qaytaradi.',
        '8.2. Litsenziya muddatidan oldin to‘xtasa. Litsenziar aybi bilan Ilova 4.2-bandda ko‘rsatilgan muddatdan ortiq mavjud bo‘lmasa yoki «Ustoz Pro» imkoniyatlari Buyurtmachi aybisiz muddatidan oldin to‘xtasa, Litsenziar qolgan to‘liq oylarga mutanosib summani qaytaradi yoki muddatni tegishli ravishda uzaytiradi (Buyurtmachi tanlovi bilan).',
        '8.3. Buyurtmachi tashabbusi bilan bekor qilish. Buyurtmachi shartnomani Litsenziarga $b kun oldin yozma xabar berib bekor qilishi mumkin. Pul qaytarish tartibi: kodlar topshirilgunga qadar — to‘langan summaning $b %; kodlar topshirilgandan keyin — [variant: qaytarilmaydi / foydalanilmagan to‘liq oylarga mutanosib — kelishiladi]. Faollashtirilgan kodlar bekor qilingan kundan to‘xtatiladi.',
        '8.4. Buyurtmachi 1.6 yoki 4.3-bandlarni buzsa, Litsenziar tegishli kodlarni bekor qilishga va shartnomani bir tomonlama bekor qilishga haqli; bu holda to‘lov qaytarilmaydi, qonunda boshqacha belgilangan hollar bundan mustasno.',
        '8.5. Shartnomaga o‘zgartirish va qo‘shimchalar faqat yozma shaklda, ikkala tomon imzolagan holda kiritiladi.',
      ],
    ),
    (
      '9. NIZOLARNI HAL QILISH',
      [
        '9.1. Nizolar avvalo muzokaralar yo‘li bilan hal qilinadi. Kelishuvga erishilmasa, nizo O‘zbekiston Respublikasi qonunchiligiga muvofiq tegishli sudda ko‘riladi.',
      ],
    ),
    (
      '10. YAKUNIY QOIDALAR',
      [
        '10.1. Shartnoma ikki nusxada, bir xil yuridik kuchga ega holda tuziladi, har bir tomonda bittadan.',
        '10.2. 1-ilova (o‘rinlar, muddat va kodlarni topshirish tartibi) shartnomaning ajralmas qismi hisoblanadi.',
      ],
    ),
  ];
  return [
    ContractBlock(ContractBlockKind.title, 'LITSENZIYA SHARTNOMASI № $no'),
    const ContractBlock(
      ContractBlockKind.subtitle,
      '(“Forensic Expert” mobil ilovasining «Ustoz Pro» funksiyalaridan foydalanish uchun oddiy (nomutlaq) litsenziya berish to‘g‘risida)',
    ),
    ContractBlock(
      ContractBlockKind.spread,
      'Andijon shahri',
      contractDate(i.contractDate),
    ),
    ContractBlock(
      ContractBlockKind.paragraph,
      'Abduraxmonov Yo‘ldashali Toshtemirovich, “Forensic Expert” mobil ilovasining huquq egasi, o‘zini o‘zi band qilgan shaxs sifatida soliq organlarida ro‘yxatdan o‘tgan (ma’lumotnoma № 0014296407, 24.08.2026), keyingi o‘rinlarda «Litsenziar» deb ataladi, bir tomondan, va $b (nomi: $name), keyingi o‘rinlarda «Buyurtmachi» deb ataladi, rahbari $director (F.I.O.) shaxsida, $b asosida harakat qiluvchi, ikkinchi tomondan, quyidagilar haqida ushbu shartnomani tuzdilar:',
    ),
    for (final (h, items) in sections) ...[
      ContractBlock(ContractBlockKind.heading, h),
      for (final t in items) ContractBlock(ContractBlockKind.paragraph, t),
    ],
    const ContractBlock(
      ContractBlockKind.heading,
      '11. TOMONLARNING REKVIZITLARI VA IMZOLARI',
    ),
    ContractBlock(
      ContractBlockKind.parties,
      'LITSENZIAR\n'
          'Abduraxmonov Yo‘ldashali Toshtemirovich\n'
          '(o‘zini o‘zi band qilgan shaxs, ma’lumotnoma № 0014296407, 24.08.2026)\n'
          'Manzil: ${_or(l.address, _longBlank)}\n'
          'Tel.: ${_or(l.phone, _longBlank)}\n'
          'JShShIR: $_longBlank\n'
          'Shaxsni tasdiqlovchi hujjat: $_longBlank\n'
          'Bank: ${_or(l.bank, _longBlank)}, MFO ${_or(l.mfo, _longBlank)}\n'
          'Qabul qiluvchi hisobi: ${_or(l.account, _longBlank)}\n'
          'Yuridik shaxslar uchun tranzit hisobi: ${_or(l.transitAccount, _longBlank)}\n'
          '\n'
          'Imzo: $_longBlank',
      'BUYURTMACHI\n'
          'Nomi: ${_or(i.name, _longBlank)}\n'
          'Manzil: ${_or(i.address, _longBlank)}\n'
          'STIR: ${_or(i.stir, _longBlank)}\n'
          'Bank: ${_or(i.bank, _longBlank)}\n'
          'Hisob raqam: ${_or(i.account, _longBlank)}\n'
          'MFO: ${_or(i.mfo, _longBlank)}\n'
          'Tel.: ${_or(i.phone, _longBlank)}\n'
          'Rahbar F.I.O.: ${_or(i.director, _longBlank)}\n'
          'Asos (ustav/ishonchnoma): $_longBlank\n'
          '\n'
          'Imzo / Muhr: $_longBlank',
    ),
    const ContractBlock(ContractBlockKind.pageBreak),
    const ContractBlock(ContractBlockKind.title, '1-ILOVA'),
    ContractBlock(
      ContractBlockKind.title,
      'Shartnoma № ${i.contractNo.trim().isEmpty ? '______' : i.contractNo} dan ${contractDate(i.contractDate)} ga',
    ),
    ContractBlock(
      ContractBlockKind.labeled,
      '1. Buyurtmachi:',
      '${_or(i.name)}.',
    ),
    ContractBlock(
      ContractBlockKind.labeled,
      '2. O‘rinlar soni:',
      '$seats ta (1.4-band).',
    ),
    ContractBlock(
      ContractBlockKind.labeled,
      '3. Litsenziya muddati:',
      'kodlar topshirilgan sanadan boshlab $months oy; boshlanishi: ${contractDate(i.termStart)}; tugashi: ${contractDate(i.termEnd)} (2.3-band).',
    ),
    const ContractBlock(
      ContractBlockKind.labeled,
      '4. Funksiyalar ro‘yxati (1.2 va 1.5-bandlar):',
      '«Ustoz Pro»: [Litsenziar to‘ldiradi]. Talabalar uchun bepul: [Litsenziar to‘ldiradi].',
    ),
    const ContractBlock(
      ContractBlockKind.labeled,
      '5. Kodlarni topshirish tartibi:',
      'Litsenziar to‘lov tushgandan keyin $b ish kuni ichida kodlarni Buyurtmachi vakiliga yopiq kanal orqali yuboradi. Kodlarning o‘zi shartnomaga va ushbu ilovaga yozilmaydi.',
    ),
    const ContractBlock(
      ContractBlockKind.labeled,
      '   Buyurtmachi vakili:',
      'F.I.O. $_longBlank; lavozimi $_longBlank; aloqa kanali (elektron pochta/telefon) $_longBlank.',
    ),
    const ContractBlock(
      ContractBlockKind.labeled,
      '   Kodlar topshirilgan sana va tasdiqlash:',
      '«___» ____________ 20___; qabul qilganini tasdiqlagan: $_longBlank.',
    ),
    const ContractBlock(
      ContractBlockKind.heading,
      '6. Kodlar bo‘yicha hisob (kodning o‘zi emas, faqat ichki raqam):',
    ),
    ContractBlock(ContractBlockKind.table, '', '', [
      const [
        '№',
        'Kod raqami (ichki)',
        'Faollashtirilgan sana',
        'Ustoz (F.I.O. yoki pochta)',
      ],
      for (var n = 1; n <= i.seats; n++) ['$n', '$n', '', ''],
    ]),
    const ContractBlock(
      ContractBlockKind.signatures,
      'Imzolar:  Litsenziar $_longBlank        Buyurtmachi $_longBlank',
    ),
    const ContractBlock(
      ContractBlockKind.note,
      'Eslatma: ushbu hujjat blanka (namunaviy shablon). Imzolashdan oldin uni yurist va soliq maslahatchisi ko‘rib chiqishi tavsiya etiladi.',
    ),
  ];
}

/// «Kodlar varag‘i» — alohida hujjat: kodlar shartnomaga yozilmaydi, faqat
/// vakilga yopiq kanal orqali yuboriladi.
List<ContractBlock> buildCodesSheetBlocks(
  InstituteDetail inst,
  List<InstituteCode> codes,
) => [
  const ContractBlock(ContractBlockKind.title, 'KODLAR VARAG‘I'),
  const ContractBlock(
    ContractBlockKind.subtitle,
    'Faqat vakilga yopiq kanal orqali yuboriladi',
  ),
  ContractBlock(ContractBlockKind.labeled, 'Buyurtmachi:', _or(inst.name)),
  ContractBlock(
    ContractBlockKind.labeled,
    'Shartnoma:',
    '№ ${inst.contractNo.trim().isEmpty ? '______' : inst.contractNo}, ${contractDate(inst.contractDate)}',
  ),
  ContractBlock(
    ContractBlockKind.labeled,
    'Muddat:',
    '${contractDate(inst.termStart)} dan ${contractDate(inst.termEnd)} gacha',
  ),
  const ContractBlock(
    ContractBlockKind.paragraph,
    'Kodni ustoz Ilovaning «Profil» bo‘limidagi «Institut kodi / promokod» qatorida kiritadi. Har bir kod bir martalik. Kodlarni uchinchi shaxslarga bermang va ommaga e’lon qilmang.',
  ),
  ContractBlock(ContractBlockKind.table, '', '', [
    const ['№', 'Kod'],
    for (var n = 0; n < codes.length; n++) ['${n + 1}', codes[n].code],
  ]),
];
