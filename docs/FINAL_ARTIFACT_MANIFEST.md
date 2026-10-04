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
