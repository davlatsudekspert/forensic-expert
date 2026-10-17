/// Google / Apple bilan kirish (feature-freeze istisnosi, egasi ruxsati).
///
/// Standart **o‘chiq**: Google/Apple konsollari va Supabase provayderlari
/// egasi tomonidan sozlanmaguncha tugmalar ko‘rinmaydi
/// (`docs/SOCIAL_SIGN_IN.md`). Yoqish: `--dart-define=FE_SOCIAL_SIGN_IN=true`
/// (yoki shu konstantani `true` qiling).
const bool kSocialSignIn = bool.fromEnvironment('FE_SOCIAL_SIGN_IN');

/// Ish vaqtidagi qiymat. Faqat testlar uchun o‘zgartiriladi
/// (`socialSignInEnabled = true` — tugmalar ko‘rinadigan holatni sinash).
bool socialSignInEnabled = kSocialSignIn;
