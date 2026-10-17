/// ABY 2025 mazmunini foydalanuvchiga ko‘rsatish (egasi qarori, 2026-10-17:
/// hozircha yashiriladi, ma’lumotlar o‘chirilmaydi, bundle o‘zgarmaydi).
///
/// Qayta yoqish: shu `false` ni `true` ga o‘zgartiring.
const bool kShowAbyContent = false;

/// Ish vaqtidagi qiymat. Faqat testlar uchun o‘zgartiriladi
/// (`abyContentEnabled = true` — ABY yozuvlari ko‘rinadigan holatni sinash).
bool abyContentEnabled = kShowAbyContent;

const abySourceId = 'SRC-ABY-2025';

/// Claim ABY’dan olinganmi: `C-ABY-` / `C-ABYX-` prefiksi yoki
/// `SRC-ABY-2025` manbasi.
bool isAbyClaim(String claimId, Iterable<String> sourceIds) =>
    claimId.startsWith('C-ABY') || sourceIds.contains(abySourceId);
