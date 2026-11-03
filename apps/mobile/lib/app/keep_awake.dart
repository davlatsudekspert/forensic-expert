import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'class_quiz.dart' show ClassScreenAwake, classScreenAwakeProvider;

/// Ekranni o‘chirmaslik: bir nechta egasi (proyektor, avto-varaqlash,
/// «Tinglash») bir-birining ushlab turishini bekor qilmaydi. Egasi
/// ([reason] + [owner]) bo‘yicha hisoblanadi: birinchi egasi olganda ekran
/// ushlanadi, oxirgisi qo‘yib yuborganda bo‘shatiladi. Takroriy `acquire` /
/// `release` zararsiz (idempotent).
class KeepAwake {
  KeepAwake(this._awake);

  final ClassScreenAwake _awake;
  final _holders = <(String, int)>{};

  /// Hozir ushlab turganlar soni.
  int get holders => _holders.length;

  bool get held => _holders.isNotEmpty;

  (String, int) _key(String reason, Object? owner) =>
      (reason, owner == null ? 0 : identityHashCode(owner));

  void acquire(String reason, [Object? owner]) {
    final wasEmpty = _holders.isEmpty;
    if (_holders.add(_key(reason, owner)) && wasEmpty) _awake.enable();
  }

  void release(String reason, [Object? owner]) {
    if (_holders.remove(_key(reason, owner)) && _holders.isEmpty) {
      _awake.disable();
    }
  }
}

final keepAwakeProvider = Provider<KeepAwake>(
  (ref) => KeepAwake(ref.watch(classScreenAwakeProvider)),
);
