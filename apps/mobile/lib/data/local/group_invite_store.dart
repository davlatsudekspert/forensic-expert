import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/class_groups/class_groups_models.dart';
import '../../domain/ports/class_groups_ports.dart';

/// QR orqali kelgan, hali ishlatilmagan guruh taklifi — faqat lokal (kod
/// ommaviy, maxfiy emas). Yangi o‘rnatilgan ilovada onboarding va
/// ro‘yxatdan o‘tish davomida yo‘qolmasligi uchun diskda saqlanadi.
class SharedPrefsPendingGroupInviteStore implements PendingGroupInviteStore {
  SharedPrefsPendingGroupInviteStore(this._prefs);

  final SharedPreferences _prefs;

  static const _k = 'fe.groups.pending_invite';

  @override
  GroupInvite? read() {
    final raw = _prefs.getString(_k);
    final uri = raw == null ? null : Uri.tryParse(raw);
    return uri == null ? null : GroupCode.fromUri(uri);
  }

  @override
  Future<void> write(GroupInvite? invite) async {
    if (invite == null) {
      await _prefs.remove(_k);
    } else {
      await _prefs.setString(
        _k,
        GroupCode.link(
          invite.code,
          assignmentId: invite.assignmentId,
        ).toString(),
      );
    }
  }
}
