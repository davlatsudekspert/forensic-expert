import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Google / Apple bilan kirish (feature-freeze istisnosi, egasi ruxsati).
///
/// **Faqat build vaqtida** belgilanadi (Apple 2.5.19: yashirin yoki masofadan
/// yoqiladigan bayroq yo‘q). Standart **o‘chiq**: Google/Apple konsollari va
/// Supabase provayderlari egasi tomonidan sozlanmaguncha tugmalar
/// ko‘rinmaydi va ilovada ham, serverda ham ularni yoqadigan joy yo‘q.
/// Yoqish — faqat yangi build bilan:
/// `--dart-define=FE_SOCIAL_SIGNIN=true` (`docs/SOCIAL_SIGN_IN.md`).
const bool kSocialSignIn = bool.fromEnvironment(
  'FE_SOCIAL_SIGNIN',
  defaultValue: false,
);

/// Ilova ichida o‘qiladigan qiymat — har doim [kSocialSignIn] (kompilyatsiya
/// vaqti konstantasi). Ish vaqtida o‘zgartiriladigan global yo‘q; faqat
/// widget testlari `ProviderScope` override orqali boshqa qiymat beradi.
final socialSignInEnabledProvider = Provider<bool>((_) => kSocialSignIn);
