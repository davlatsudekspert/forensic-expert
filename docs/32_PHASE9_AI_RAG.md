# 32 — PHASE 9: Forensic AI / RAG

> **AI provayderi production’ga ulanmagan.** Production LLM kalitlari yo‘q (RG-22). Ilovada standart holat — `UnconfiguredAiProvider`: faqat manbalar ko‘rsatiladi va «AI javobi» deb atalmaydi. `MockAiProvider` faqat testlarda va javobda «TEST provider» cheklovi bilan.

## Quvur (`lib/domain/ai/rag_pipeline.dart`)

```
SAVOL → xavfsizlik (PII, yakuniy xulosa, huquqiy hukm, rasmiy ekspert xulosasi)
      → niyat/domen (EN/RU/UZ, deterministik) → yurisdiksiya talabi
      → ichki qidiruv (ProvenanceRetrieval) → dalil reytingi
      → provayder → citation tekshiruvi → identifikator yaxlitligi (DOI/PMID)
      → javob xavfsizligi → tuzilgan javob
```

**Ustuvorlik:** 1) review qilingan ichki kontent, 2) manbalar katalogi (manbali, NEEDS_REVIEW), 3) xalqaro standartlar, 4) rasmiy yurisdiksiya qoidalari (faqat tanlangan yurisdiksiya + INT), 5) tashqi tekshirilmagan qidiruv (ulanmagan).

**Chiqarib tashlanadi:** RETRACTED, SUPERSEDED, REJECTED claim’lar — javobda «N ta da’vo chiqarib tashlandi» cheklovi.

**Rad etish:** to‘qilgan bo‘lak ID, havolasiz javob, cited manbalarda yo‘q DOI/PMID, javobdagi yakuniy o‘lim sababi/huquqiy xulosa.

**Javob tuzilmasi (UI):** Javob · Dalil holati (hayot sikli, ziddiyat) · Yurisdiksiya · Cheklovlar (inson tasdiqlamagan, ziddiyat, retraksiya, ekspert talab qilinadi, test provayder) · Bog‘liq yozuvlar.

**Maxfiylik:** PII topilsa savol provayderga yuborilmaydi (test bilan); savol log/telemetriyaga tushmaydi (`TelemetryPolicy.forbiddenKeys`: query, question, text…); qidiruv qurilmada.

**Provayder abstraksiyasi:** `AiProvider` (interfeys) · `UnconfiguredAiProvider` · `MockAiProvider` (`AiProviderMode.mock`) · production: server proksi orqali (kalit faqat serverda) — **ulanmagan**.

## Testlar

`test/unit/rag_pipeline_test.dart` — 24: niyat tasnifi; 12 baholash fixture’i (retrievalOnly / jurisdictionRequired / blocked / noReliableContext — haqiqiy pilot paketda); retraksiya chiqarilishi; ziddiyat cheklovi; mock javob belgisi; to‘qilgan bo‘lak, havolasiz javob, to‘qilgan DOI/PMID, xavfli javob — rad; PII savol provayderga yetmaydi; telemetriya; identifikator yaxlitligi; ustuvorlik tartibi.
`test/widget/phase9_ai_test.dart` — 3: AI ekranida tuzilgan bo‘limlar, retraksiya cheklovi, RU rasmiy xulosa so‘rovi bloklanishi.

## Ochiq

RG-22: server provayderi, ikkinchi xavfsizlik qatlami (LLM moderatsiya), eval to‘plamini kengaytirish (domen ekspertlari bilan), kvota/narx.
