import 'package:flutter/widgets.dart';

/// Skroll siljishining faqat ro‘yxat chegaralari (`minScrollExtent..
/// maxScrollExtent`) ICHIDAGI qismi.
///
/// iOS’da (BouncingScrollPhysics) ro‘yxat oxiridan cho‘zilgan (overscroll)
/// holat qo‘yib yuborilgach fizika uni orqaga qaytaradi — bu teskari
/// `scrollDelta` lar, lekin foydalanuvchi yuqoriga surmagan. Ularni
/// «yuqoriga skroll» deb hisoblab sarlavha yoki panelni o‘zgartirish
/// LabGuide’da kontentni pastga «tushirib» yuborgan (snap-back). Shuning
/// uchun yo‘nalish faqat shu funksiya bilan aniqlanadi.
double inBoundsScrollDelta(ScrollMetrics m, double scrollDelta) {
  double clamp(double p) => p.clamp(m.minScrollExtent, m.maxScrollExtent);
  return clamp(m.pixels) - clamp(m.pixels - scrollDelta);
}

/// Yo‘nalish gisterezisi: chegaralar ichida [threshold] px bir tomonga
/// surilgandagina holat almashadi (titrash yo‘q). `true` — ixcham
/// (kontent pastga surildi), `false` — to‘liq.
class ScrollCompactHysteresis {
  ScrollCompactHysteresis({this.threshold = 12});

  final double threshold;
  double _acc = 0;

  /// Yangi holat (o‘zgarmasa — `null`).
  bool? update(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return null;
    if (n is ScrollUpdateNotification) {
      final d = inBoundsScrollDelta(n.metrics, n.scrollDelta ?? 0);
      if (d == 0) return null;
      if (d.sign != _acc.sign) _acc = 0;
      _acc += d;
      if (_acc >= threshold) {
        _acc = 0;
        return true;
      }
      if (_acc <= -threshold) {
        _acc = 0;
        return false;
      }
    }
    // Sahifa tepasida (yoki yangi sahifa ochilganda) — doim to‘liq.
    if ((n is ScrollUpdateNotification || n is ScrollMetricsNotification) &&
        n.metrics.pixels <= n.metrics.minScrollExtent) {
      _acc = 0;
      return false;
    }
    return null;
  }
}
