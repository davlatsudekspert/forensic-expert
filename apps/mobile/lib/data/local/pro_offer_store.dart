import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/ports/plan_ports.dart';

/// «Birinchi taklif ko‘rsatildi» belgisi — faqat lokal, Pro huquqi emas.
class SharedPrefsProOfferStore implements ProOfferStore {
  SharedPrefsProOfferStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.pro.first_offer_shown';

  @override
  bool get firstOfferShown => _prefs.getBool(_k) ?? false;

  @override
  Future<void> markFirstOfferShown() async {
    await _prefs.setBool(_k, true);
  }
}
