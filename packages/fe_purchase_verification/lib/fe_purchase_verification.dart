/// RG-18: server tomonida xaridni tekshirish arxitekturasi.
///
/// **Faqat server** uchun. Store kalitlari (App Store Connect API `.p8`,
/// Google service account JSON) bu repozitoriyda yo‘q va bo‘lmaydi —
/// server muhitidan o‘qiladi. Bu paketdagi `testing.dart` mock’lari haqiqiy
/// tekshiruv EMAS; production’da taqiqlangan.
library;

export 'src/models.dart';
export 'src/ports.dart';
export 'src/service.dart';
export 'src/testing.dart';
