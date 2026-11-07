/// Ilova sozlamalari (markaziy).
///
/// [kEnableProPaywall] — Pro to‘lov/qulf tizimining bosh o‘chirgichi
/// (egasi, 2026-11-06). `false` (hozir): sinov va do‘kon tekshiruvi davomida
/// HAMMA funksiya va kontent hamma uchun 100% bepul va ochiq; Pro rejasi
/// ekrani, qulf belgilari va xarid taklifi ko‘rinmaydi. Obuna do‘kon
/// tasdig‘idan keyin shu qiymatni `true` qilish va (xarid sinalgach)
/// `--dart-define=FE_PRO=true` bilan yoqiladi — ikkalasi ham kerak.
const bool kEnableProPaywall = false;
