# 22 — Forensic AI: RAG-first xavfsizlik modeli

Umumiy chatbot emas. LLM hozir **ulanmagan** (RG-22); arxitektura va xavfsizlik qatlamlari tayyor va test qilingan (`lib/domain/ai/ai_architecture.dart`).

## Zanjir (`AiRouter`)

1. **Xavfsizlik (savol):** PII (ism, pasport/ID, ish raqami…) → blok; yakuniy o‘lim sababi/turi → blok; huquqiy xulosa (aybdorlik) → blok; **PHASE 6:** rasmiy ekspert xulosasi, o‘lim guvohnomasi, qat’iy zaharlanish/mastlik xulosasi → blok (`SafetyBlock.officialOpinion`).
2. **Yurisdiksiya (PHASE 6):** savol huquqiy/protsessual bo‘lsa (`SafetyPolicy.isJurisdictional`: law, controlled substance, schedule, drink-driving, закон, запрещ…, qonun, taqiqlan…) va yurisdiksiya tanlanmagan (`INT`) bo‘lsa → `jurisdictionRequired`: AI **taxmin qilmaydi**, foydalanuvchidan tanlashni so‘raydi (UI tugmasi tanlovchiga olib boradi).
3. **Retrieval:** faqat lokal, imzolangan kontent paketidan bo‘laklar; bo‘lak yo‘q → «ishonchli javob yo‘q».
4. **Provayder / kvota:** sozlanmagan bo‘lsa — faqat lokal manbalar ko‘rsatiladi va «AI javobi» deb atalmaydi.
5. **Citation:** model faqat shu so‘rovda olingan bo‘lak ID’larini keltira oladi; noma’lum bo‘lak yoki manba → **butun javob rad etiladi**. Citation metama’lumotiga (sarlavha, DOI, holat) **server/ilova egalik qiladi, model emas** — model hech qachon iqtibos to‘qiy olmaydi.
6. **Xavfsizlik (javob):** javob ham PII va yakuniy xulosa uchun tekshiriladi.

## Javob tuzilmasi

Javob · Manbalar (raqamlangan, tier: ichki tasdiqlangan / ichki review qilingan / tashqi tekshirilmagan) · **Dalil holati** · **Yurisdiksiya** · Cheklovlar · **Bog‘liq yozuvlar** · «ekspert xulosasi o‘rnini bosmaydi» eslatmasi · xato haqida xabar berish.

## AI qilmaydi

Rasmiy forensik xulosa, o‘lim sababini sertifikatlash, huquqiy hukm, qat’iy intoksikatsiya xulosasi, rasmiy ekspert fikri. Professional fikrlash va adabiyotda navigatsiyani qo‘llab-quvvatlaydi.

## Maxfiylik

PII ogohlantirishi ekranda doimiy; PII topilsa savol yuborilmaydi. Kelajakdagi analitika/crash logging: `TelemetryPolicy` — faqat ruxsat etilgan kalitlar va ID’siz marshrut shablonlari; qidiruv so‘rovlari, AI savollari, ism, ID, ish raqami, holat tavsifi va biologik natijalar hech qachon yuborilmaydi (test bilan). Qidiruv tarixi, saralanganlar va yaqinda ko‘rilganlar — faqat qurilmada.
