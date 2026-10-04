# «Ridge Spectrum» — logo prototiplari (PHASE 1)

> **PROTOTIP. Yakuniy logo EMAS va QULFLANMAGAN.** Yakuniy tanlov faqat egasining tasdig‘i bilan. Trademark tekshiruvi (WIPO, USPTO, EUIPO, Rospatent, O‘zbekiston IMA) va IP yurist xulosasi logo qulflanishidan oldin majburiy (legal checklist L-10).

## Fayllar

| Yo‘l | Mazmuni |
|---|---|
| `tools/generate_prototypes.py` | SVG generator (100×100 grid). Barcha variantlar bitta manbadan — geometriya takrorlanadi |
| `tools/render_previews.mjs` | Playwright/Chromium orqali 1024 / 180 / 64 / 32 px rasterlash va kontakt varag‘i |
| `prototypes/*.svg` | Har variant uchun: `icon`, `icon-small` (32–64 px optik versiya), `light`, `dark`, `mono`, `mono-small` |
| `previews/*.png` | Rasterlangan app icon va silhouette (1024, 180, 64, 32 px) |
| `previews/contact-sheet.png` | Barcha variantlarni solishtirish varag‘i |

Qayta yaratish:

```bash
python3 design/logo/tools/generate_prototypes.py
NODE_PATH=$(npm root -g) node design/logo/tools/render_previews.mjs
```

## Variantlar

| ID | Nomi | G‘oya |
|---|---|---|
| **A1** | Loop & Spectrum | Chapda ochiq barmoq izi yoylari, o‘ngda spektr cho‘qqilari, umumiy bazaviy chiziq. Dalil (iz) → o‘lchov (spektr) |
| **A2** | Ridge Core Peak | Konsentrik ridge arkalari. Markazida bitta o‘tkir analitik cho‘qqi. Tashqi arkada barmoq izidagi kabi uzilish (ridge ending) |
| **A3** | Nested Peaks | Bazaviy chiziq ustida ichma-ich joylashgan xromatografik cho‘qqilar. Ular bir vaqtda barmoq izi «loop» ridge’lari va spektr cho‘qqilari sifatida o‘qiladi. Eng ichki cho‘qqi — accent |

Barcha variantlarda: tibbiy xoch, bosh suyagi, nishon, tarozi va qon tomchisi **yo‘q**. Ranglar: Deep Navy `#0F1E3D`, oq, Spectral Teal (`#4CC9D6` navy fonda, `#0A6F7A` oq fonda).

## Readability va silhouette testi (1024 / 180 / 64 / 32 px)

Usul: Chromium’da aniq piksel o‘lchamida rasterlash. 64 va 32 px uchun optik soddalashtirilgan `small` versiya ishlatildi (chiziq qalinroq, ridge soni kamroq). Silhouette — bir rangli (qora) versiya. Natijalar `previews/contact-sheet.png` da; 32 px ×8 kattalashtirilgan holatda ham ko‘rib chiqildi.

| Mezon | A1 Loop & Spectrum | A2 Ridge Core Peak | A3 Nested Peaks |
|---|---|---|---|
| 1024 px | Yaxshi, lekin kompozitsiya pastga og‘ir, gorizontal | Yaxshi, toza | Yaxshi, eng muvozanatli |
| 180 px | Yaxshi | Yaxshi | Yaxshi |
| 64 px | Yoylar bir-biriga yaqinlashadi | Aniq | Aniq |
| 32 px | **Zaif**: yoylar qo‘shilib ketadi, cho‘qqilar «o‘t»ga o‘xshaydi | O‘rtacha: «gumbaz»/soyabon silueti | **Eng yaxshi**: siluet aniq, accent ko‘rinadi |
| Silhouette (mono) | Murakkab, kichikda tanib bo‘lmaydi | Tanish, lekin generik «gumbaz» | Kuchli va yagona shakl |
| «Generic fingerprint / medical icon» xavfi | Past (o‘ziga xos kombinatsiya) | O‘rta (Wi-Fi / soyabon / gumbaz assotsiatsiyasi) | O‘rta (tog‘ yoki «A» harfi assotsiatsiyasi) |
| Barmoq izi ma’nosi | Kuchli | O‘rta–kuchli | O‘rta (ichma-ich «loop» orqali) |
| Ilmiy (spektr) ma’nosi | Kuchli | O‘rta | Kuchli (xromatografik cho‘qqilar) |
| Android adaptive icon (markaziy xavfsiz zona) | Zaif (gorizontal) | Yaxshi | Yaxshi |

### Xulosa va tavsiya (qulflanmagan)

1. **A3 «Nested Peaks»** kichik o‘lchamda eng yaxshi natija berdi. Shu sababli ilovadagi `BrandMark` vaqtinchalik prototip sifatida A3 dan foydalanadi (`apps/mobile/lib/core/widgets/brand_mark.dart`).
2. **A1** g‘oya jihatidan eng boy, lekin 32 px’da o‘qilmaydi. Uni faqat katta o‘lchamdagi marketing belgisi sifatida ko‘rib chiqish mumkin.
3. **A2** kichikda generik «gumbaz» bo‘lib qoladi — tavsiya etilmaydi.
4. A3 ning asosiy xavfi — tog‘ yoki «A» harfi bilan assotsiatsiya va «barmoq izi» ma’nosining sustligi. Keyingi iteratsiya uchun takliflar:
   - ichki cho‘qqilar orasidagi masofani ridge oralig‘iga yaqinlashtirish;
   - tashqi cho‘qqining bir tomonida barmoq izidagi kabi kichik ridge uzilishi qo‘shish;
   - turli shriftli wordmark bilan lockup sinovi.

## Yakuniy logo uchun ochiq qadamlar

- [ ] Egasining yo‘nalish tanlovi (A1 / A2 / A3 yoki iteratsiya).
- [ ] 5 nafar foydalanuvchi bilan 32 px «2 soniyada topish» testi (`docs/00_ARXITEKTURA_REJASI.md`, 27.2).
- [ ] Trademark qidiruvi (tasviriy belgi: Vena tasnifi — grafik/diagramma, to‘lqin chiziqlar) + IP yurist.
- [ ] Wordmark («FORENSIC EXPERT», Inter SemiBold, keng harf oralig‘i) va gorizontal/vertikal lockup.
- [ ] iOS (light/dark/tinted) va Android (adaptive + themed monochrome) icon to‘plamlari — faqat tasdiqdan keyin.
