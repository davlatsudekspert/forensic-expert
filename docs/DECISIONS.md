# DECISIONS (qarorlar jurnali)

| Sana | Qaror | Kim | Asos |
|---|---|---|---|
| 2026-10-06 | Feature-freeze `cf049d8`; keyin egasi master topshiriq bilan yangi bosqichni ochdi | Egasi | CLAUDE.md |
| 2026-10-08 | Biznes modeli FREE + PRO (oylik/yillik); sinov narxlari $4.99 / $39.99; lifetime faollashtirilmaydi | Egasi | master topshiriq |
| 2026-10-08 | ABY 2025: yopiq/admin integratsiya, Variant B — katalog faqat admin qurilmasida (repo, CI, Supabase, AI yo‘q) | Egasi | ABY qarori |
| 2026-10-08 | Umumiy bo‘lim nomi «Yo‘riqnomalar»; mustaqil kartalar ABY’dan alohida, provenance ichki | Egasi | |
| 2026-10-08 | Manbasiz AI matni foydalanuvchiga ko‘rsatilmaydi; o‘rniga «manbalar savolni qamramaydi» | Muhandis | ilmiy ishonchlilik; test `rag_pipeline_test` |
| 2026-10-08 | Har savolga bitta server so‘rovi (AiRouter + RAG ikki chaqiruvi bekor qilindi) | Muhandis | kvota isrofi (audit) |
| 2026-10-08 | Offline retrieval: IDF + bo‘sag‘a + umumiy so‘zlar filtri | Muhandis | BlueStacks YuQX hodisasi |
| 2026-10-08 | Iqtibos kalitlari (muallif+yil) gitleaks allowlist’ida | Muhandis | soxta signal |
| 2026-10-08 | Kartalar holati faylda nima yozilsa ham ekspert ko‘rigisiz NEEDS_REVIEW | Muhandis | kod `GuidelineCard._status` |
| 2026-10-08 | `ai-answer` v5 production’ga deploy | Egasi ruxsat berdi | vaqt byudjeti tuzatishlari |

## 2026-10-09 — Yuldashev Z.A. materiallaridan foydalanish ruxsati
- Muallif (Yuldashev Z.A., TFI) Telegram orqali 2026-10-09 14:19 da yozma ruxsat berdi:
  «Қанча манба керак бўлса фойдаланаверинглар» (egasi skrinshotini sessiyada ko‘rsatdi).
- Qamrov: «Toksikologik kimyo» va «ДВССМ» o‘quv-uslubiy majmualari (2025-26), «Giyohvand moddalar tahlili» o‘quv qo‘llanmasi (2024).
- Qoidalar: matn so‘zma-so‘z ko‘chirilmaydi — faktlar o‘z tuzilmamizda; har kartada manba «Yuldashev Z.A. va boshq., asar, yil»;
  topilgan xatolar (etanol letal dozasi, morfin pH, petidin formulasi, TGK foizlari, muvozanatsiz tenglamalar) tuzatiladi;
  holat NEEDS_REVIEW; muallifga ilmiy taqrizchi bo‘lish taklif qilingan.
- Egasining reaktivlar to‘plami (o‘zi jamlagan) — egasi ruxsati bilan (2026-10-09).
