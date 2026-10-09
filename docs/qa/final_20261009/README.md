# Yakuniy real-ilova sinovi — 2026-10-09 (birlashtirilgan build)

Linux desktop (haqiqiy Flutter dvigateli, Xvfb), `FE_AUTH_MODE=mock`, HTTP bloklangan,
har yugurish toza `XDG_DATA_HOME` bilan (birinchi ishga tushirish). Commit: 22e1214 + QA tuzatishlari.

| Yugurish | Natija |
|---|---|
| admin | 23/23 PASS |
| citations_en | 6/6 PASS |
| citations_ru_pro | 6/6 PASS |
| citations_uz | 6/6 PASS |
| court_pro | 15/15 PASS |
| court_student | 15/15 PASS |
| expert | 37/37 PASS |
| glossary_en_student | 18/18 PASS |
| glossary_ru_expert | 18/18 PASS |
| glossary_uz_student | 18/18 PASS |
| gmt | 12/12 PASS |
| home | 25/25 PASS |
| reading | 39/39 PASS |
| reagents_pro | 10/10 PASS |
| reagents_student | 10/10 PASS |
| spectro_pro | 11/11 PASS |
| spectro_student | 6/6 PASS |
| student | 49/49 PASS |
| toks | 12/12 PASS |
| tools | 38/38 PASS |

**Jami: 374/374 qadam PASS (20 yugurish).**

Birinchi yugurishda admin 5/23 va reagents_student 9/10 edi — ilova xatosi emas, sinov skriptlari eskirgan:
onboarding oxirgi qadami «Hisobsiz davom etish» → `account.skip` («Boshlash»); Nessler retsepti endi bepul
(egasi qarori). Skriptlar tuzatildi, qayta yugurish: admin 23/23, reagents_student 10/10.

Sinalmagan: haqiqiy iOS/Android qurilma, haqiqiy OTP email, haqiqiy xarid, production Supabase.
Ma’lum ochiq masala (alohida lokalizatsiya loyihasi): o‘zbekcha UI’da ayrim bibliografiya va iqtiboslar
inglizcha ko‘rinadi (masalan, «Sudda so‘roq» kartasida O‘zbekiston JPK inglizcha nom bilan).
