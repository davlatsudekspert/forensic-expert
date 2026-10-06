import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/ports/referral_ports.dart';
import '../../domain/referral/referral_models.dart';

/// Kutilayotgan taklif kodi — faqat lokal (kontakt yoki shaxsiy ma’lumot
/// saqlanmaydi; kod ommaviy, maxfiy emas).
class SharedPrefsPendingReferralStore implements PendingReferralStore {
  SharedPrefsPendingReferralStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.referral.pending_code';

  @override
  String? read() => ReferralCode.normalize(_prefs.getString(_k));

  @override
  Future<void> write(String? code) async {
    final c = ReferralCode.normalize(code);
    if (c == null) {
      await _prefs.remove(_k);
    } else {
      await _prefs.setString(_k, c);
    }
  }
}
