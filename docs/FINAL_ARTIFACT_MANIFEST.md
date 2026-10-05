# FINAL ARTIFACT MANIFEST — FORENSIC EXPERT

Sana: 2026-10-04. Faqat haqiqatan yaratilgan va tekshirilgan artefaktlar. Imzo holati yashirilmaydi.

## Manba
| | |
|---|---|
| Branch | `claude/phase-8-12-final-release` |
| Artefaktlar qurilgan commit | `a937da422c378147a51b1166b62d21ff72ca5566` |
| Ilova versiyasi | `0.1.0+1` (versionName 0.1.0, build 1) |
| Flutter / Dart | 3.47.6 / 3.13.5 |
| Kontent paketi | `2026.10.6` (`fe-bundle/4`; scientific 2026.10.6, jurisdiction 2026.10.5, research 2026.10.3), development kanal |
| DB sxemasi | v6 |

## Android
| | AAB | APK |
|---|---|---|
| CI fayl | `forensic-expert-DEBUG-SIGNED-not-for-store.aab` | `forensic-expert-DEBUG-SIGNED-not-for-store.apk` |
| Hajm (CI) | 69 587 724 B | 71 606 888 B |
| SHA-256 (CI) | `c55524ecb11242fcd93f9bf4198fe6f789388ab018d9a847dccd2517bc7f15df` | `f59b27d2ffaa07e16143df1c012bd835bc57fc68b42c2a00630ae974957f9d0b` |
| Lokal (VM) yo‘l | `apps/mobile/build/app/outputs/bundle/release/app-release.aab` | `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` |
| Lokal hajm / SHA-256 | 69 587 401 B / `6fcf8185…2a35f4` | 71 606 888 B / `26560736…ec99b1d` |
| Imzo | **DEBUG** (RG-20) | **DEBUG** — `apksigner`: `CN=Android Debug` (lokal) |

* applicationId `uz.forensicexpert.forensic_expert`, minSdk 24, target 36.
* Lokal va CI SHA farqi kutilgan (har xil mashina, debug kalit va build vaqti).
* **Tarqatish:** GitHub Actions artefakti (repozitoriy private; faqat ruxsatli foydalanuvchilar):
  `https://github.com/davlatsudekspert/forensic-expert/actions/runs/37239093623/artifacts/11316698805`
  (artefakt ID 11316698805, zip 104 747 126 B, zip SHA-256 `6d749db42b330f9cd954bc99293f996e67b1bfecdc87bbdfda3ebe68a3731355`, muddati 2026-11-03).
  Tekshiruv: autentifikatsiyasiz so‘rov → 403 (private, kutilgan); autentifikatsiyalangan API `…/artifacts/11316698805/zip` → 302 (yuklab olish mavjud). Ommaviy havola yaratilmagan.
* **Store uchun yaroqsiz** — upload keystore yo‘q; Play’ga yuborilmagan.

## iOS
| | |
|---|---|
| CI | `Release build` run 37239093623, job `iOS (compile + archive)`, macos-15 — **success** |
| Kompilyatsiya | `flutter build ios --release --no-codesign` — muvaffaqiyatli |
| Arxiv | `flutter build ipa --release --no-codesign` → `Runner.xcarchive` — **IMZOSIZ** |
| Artefakt | `ios-UNSIGNED-archive-a937da4…` (ID 11316539373, 53 190 756 B, zip SHA-256 `920a4e04999bdd75f8286ab7da74a963253b5f12a51fa213c8882aee3455debb`) — `https://github.com/davlatsudekspert/forensic-expert/actions/runs/37239093623/artifacts/11316539373` |
| Imzo | **yo‘q** (Apple sertifikat / provisioning yo‘q) |
| Build raqami | 1 (`0.1.0+1`); TestFlight yo‘lida `GITHUB_RUN_NUMBER` |
| Bundle ID | `uz.forensicexpert.forensicExpert`, iOS 15.0 |
| TestFlight | **TESTFLIGHT UPLOAD BLOCKED BY CREDENTIALS** — kerak: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`, `APPLE_TEAM_ID` va App Store Connect’da ilova yozuvi |
| App Review | yuborilmagan |
| Real qurilma | sinalmagan (RG-10 / RG-24) |

## Ilmiy kontent (2026.10.6)
| Ko‘rsatkich | Qiymat |
|---|---|
| Claim | 497 (hammasi NEEDS_REVIEW) |
| VERIFIED / **HUMAN VERIFIED** | 0 / **0** |
| Reviewerlar / review harakatlari | 0 / 0 |
| Manbalar | 457 (RETRACTED 1) |
| Moddalar | 137 |
| Mavzular | 45 |
| Metodlar / ekspress testlar / retseptlar | 18 / 7 / 4 |
| Standartlar | 7 |
| Ziddiyatlar | 4 |
| Namunalar / metabolit munosabatlari | 12 / 24 |
| Huquqiy hujjatlar / qoidalar | 8 / 98 (INT, GB, US, DE, UZ — NEEDS LEGAL REVIEW) |
| Research yozuvlari / rasmlar | 883 / 156 |
| Review paketlari / navbat | 153 / 888 |
| Production validator | rad — faqat FE008 (633), kutilgan |

## Testlar
| To‘plam | PASS | FAIL | SKIP |
|---|---|---|---|
| Ilova (`flutter test`, lokal) | 1002 | 0 | 1 |
| Paketlar (7 ta, `dart test`) | 251 | 0 | 0 |
| **Jami** | **1253** | **0** | **1** |

## CI
| Workflow | Run | Commit | Natija |
|---|---|---|---|
| CI | 37239093611 | a937da4 | ✅ success |
| Release build | 37239093623 | a937da4 | ✅ success (Android DEBUG-imzo; iOS imzosiz) |

Yakuniy hujjatlar commit’idagi CI natijasi `FINAL_RELEASE_REPORT.md` da.

## Release completion (2026-10-05) — akkaunt va obunalar qo‘shilgandan keyin

Lokal toza build (`flutter clean`, Linux VM), commit `d4e7d6a` asosida:

| | AAB | APK |
|---|---|---|
| Yo‘l | `apps/mobile/build/app/outputs/bundle/release/app-release.aab` | `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` |
| Versiya / versionCode | 0.1.0 / 1 | 0.1.0 / 1 |
| Hajm | 70 059 979 B | 72 151 457 B |
| SHA-256 | `cf7a8505cfd854144dc88f13936d922c2c1a536b22ce0b0b2cf53e83ed49e42a` | `5316716ca3db570ac8ff2e5f83ea01de3b0acf6abbdc3d9a0967639693796af9` |
| Imzo | **DEBUG** (RG-20) | **DEBUG** — `apksigner`: `CN=Android Debug` |
| Ruxsatlar | — | `INTERNET`, `com.android.vending.BILLING`, `ACCESS_NETWORK_STATE` (plagin), dinamik receiver |

CI artefaktlari va iOS natijasi — pastdagi «Yakuniy CI» bo‘limida.

Testlar: ilova **1159 PASS / 0 FAIL / 1 SKIP**, paketlar **256 PASS** (calc 32, content_package 15, pipeline 23, schema 122, database 26, purchase_verification 17, search 21) → **1415 PASS, 0 FAIL, 1 SKIP**. OSV: 148 paket, zaiflik yo‘q. gitleaks (to‘liq tarix): sir yo‘q.

### Yakuniy CI (commit `d4e7d6a`)

| Workflow | Run | Natija |
|---|---|---|
| CI (analyze & test, gitleaks, OSV) | 37248664689 | ✅ success |
| Release build — Android | 37248664707 | ✅ success; artefakt `android-DEBUG-SIGNED-not-for-store-d4e7d6a…` (ID 11320541095, zip 105 431 674 B, SHA-256 `1d97bd7b11473deaa580ab18c5a5ad06db7f30cf34f9e67082b7d240cb95126a`) — **DEBUG imzo** |
| Release build — iOS (macos-15) | 37248664707 | ✅ `flutter build ios --release --no-codesign` + imzosiz `Runner.xcarchive` (193.0 MB; zip SHA-256 `703147fe207fcf00f5ba13f3c48e5432af3e10f9c58546de2bbef70f45d601af`); artefakt ID 11320800185 (53 502 676 B). Version 0.1.0, build 1, bundle `uz.forensicexpert.forensicExpert`, iOS 15.0. **IPA yaratilmadi (imzo yo‘q). TESTFLIGHT UPLOAD BLOCKED BY CREDENTIALS.** |

Artefakt havolalari (repo private — faqat ruxsatli foydalanuvchilar; ommaviy URL yo‘q):
`https://github.com/davlatsudekspert/forensic-expert/actions/runs/37248664707/artifacts/11320541095` (Android),
`https://github.com/davlatsudekspert/forensic-expert/actions/runs/37248664707/artifacts/11320800185` (iOS).

Flutter ogohlantirishi: iOS launch image — standart placeholder (brend launch rasmi kerak, dizayn).

