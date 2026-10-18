/// Suzuvchi («Instagram uslubidagi») pastki menyu (egasi topshirig‘i,
/// 2026-10-17, feature-freeze istisnosi).
///
/// `true`  — yangi menyu: 5 bo‘lim (Asosiy · Kutubxona · AI · Vositalar · Profil),
///           suzuvchi shisha pill, skrollda ixchamlashadi; markaziy AI ko‘tarilgan;
///           Asosiy ekrandagi Kutubxona tugmasi ham saqlanadi.
/// `false` — eski 5 tabli `NavigationBar` (o‘zgarishsiz saqlangan).
const bool kFloatingNav = true;

/// Ish vaqtidagi qiymat. Faqat testlar uchun o‘zgartiriladi
/// (`floatingNavEnabled = false` — eski menyuni sinash).
bool floatingNavEnabled = kFloatingNav;

/// Menyu orqasidagi xiralashtirish (`BackdropFilter`). Past qurilmalarda
/// unumdorlik muammosi bo‘lsa — shu bayroqni `false` qiling: pill yarim
/// shaffof, xiralashtirishsiz chiziladi.
const bool kFloatingNavBlur = true;

/// Ish vaqtidagi qiymat (testlar uchun).
bool floatingNavBlurEnabled = kFloatingNavBlur;
