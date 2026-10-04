# 16 — Student Mode va Forensic AI / AI Tutor arxitekturasi (PHASE 4)

## 1. Student Mode

| Imkoniyat | Amalga oshirilishi |
|---|---|
| Darajalar | Boshlang‘ich / O‘rta / Yuqori — kurs filtri |
| Kurslar | Kontent paketidagi manbali yozuvlardan avtomatik quriladi. Yangi ilmiy matn yozilmaydi; dars manbadagi asl jumlani ko‘rsatadi. Kurs statusi — eng zaif yozuv statusi (NEEDS_REVIEW) |
| Progress va tarix | Tugatilgan darslar va yaqinda o‘qilganlar — faqat qurilmada (SharedPreferences) |
| Xatcho‘plar | Yulduzcha bilan belgilangan mavzular |
| Imtihon rejimi | Natija va izohlar faqat topshirgandan keyin chiqadi. Savollar **avtomatik yaratilmaydi**: reviewer tasdiqlagan savollar kelguncha production’da bo‘sh holat ko‘rsatiladi |
| Holatlar | Har birida «SIMULYATSIYA QILINGAN HOLAT — real ish emas» belgisi |
| Bepul demo | 1 kurs |

## 2. Forensic AI arxitekturasi (`lib/domain/ai`)

Zanjir: savol → `SafetyPolicy` (PII, yakuniy o‘lim sababi/turi, huquqiy xulosa) → `RetrievalProvider` (lokal, offline) → `AiProvider` (ulanmagan) → `UsageQuota` → `CitationResolver` → javob xavfsizligi.

- **Provider’dan mustaqil.** `AiProvider` — interfeys; vendor SDK yoki API kaliti ilovada yo‘q. Kelajakda faqat server orqali ulanadi.
- **RAG-first.** Kontekst topilmasa — «ishonchli javob yo‘q».
- **Citation.** Javob qabul qilinishi uchun model ko‘rsatgan bo‘lak shu so‘rovda olingan bo‘lishi va uning manbasi paketda bo‘lishi shart. Rad etish holatlari:
  - noma’lum bo‘lak;
  - paketda yo‘q manba;
  - havolasiz javob.
- **Kvota.** AI Lifetime’ga «cheksiz» kirmaydi (`AiEntitlement`); kvota yo‘q bo‘lsa LLM chaqirilmaydi.
- **Ikki tajriba.** Professional (qisqa, manbali) va Tutor (bosqichma-bosqich).
- **Hozirgi UI.** «Manbalarni oflayn topish» lokal qidiruv natijalarini manbasi bilan ko‘rsatadi va ularni «AI javobi emas» deb aniq belgilaydi.
- **Testlar.** To‘qilgan havola rad etiladi; xulosa so‘rovlari EN/RU/UZ tillarida bloklanadi; LLM’siz marshrut javob yaratmaydi.

## 3. Cheklovlar

- Kalit so‘zli xavfsizlik — birinchi qatlam; server tarafda ikkinchi qatlam kerak.
- Lokal qidiruv so‘z kesishmasiga asoslangan (embedding yo‘q).
- Real LLM, server, narx va kvota siyosati — RG-16 va keyingi bosqichlar.
