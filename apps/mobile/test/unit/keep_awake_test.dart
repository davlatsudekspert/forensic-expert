// Ref-hisoblangan «ekran o‘chmasin»: egalar bir-birini bekor qilmaydi.
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/keep_awake.dart';

class _Awake implements ClassScreenAwake {
  int enabled = 0;
  int disabled = 0;

  @override
  Future<void> enable() async => enabled++;

  @override
  Future<void> disable() async => disabled++;
}

void main() {
  test('birinchi ega ushlaydi, oxirgisi bo‘shatadi', () {
    final a = _Awake();
    final k = KeepAwake(a);
    final x = Object();
    final y = Object();
    k.acquire('projector', x);
    expect((a.enabled, a.disabled), (1, 0));
    k.acquire('listen', y);
    expect(a.enabled, 1, reason: 'ikkinchi ega qayta yoqmaydi');
    expect(k.holders, 2);
    k.release('projector', x);
    expect(a.disabled, 0, reason: 'tinglash hali ushlab turibdi');
    expect(k.held, isTrue);
    k.release('listen', y);
    expect((a.enabled, a.disabled), (1, 1));
    expect(k.held, isFalse);
  });

  test(
    'takroriy acquire/release zararsiz, begona release hech narsa qilmaydi',
    () {
      final a = _Awake();
      final k = KeepAwake(a);
      final x = Object();
      k.release('listen', x);
      expect(a.disabled, 0);
      k.acquire('auto', x);
      k.acquire('auto', x);
      expect(k.holders, 1);
      expect(a.enabled, 1);
      k.release('auto', x);
      k.release('auto', x);
      expect(a.disabled, 1);
      // Bir sababli ikki xil ega alohida hisoblanadi.
      final y = Object();
      k.acquire('listen', x);
      k.acquire('listen', y);
      k.release('listen', x);
      expect(k.held, isTrue);
      k.release('listen', y);
      expect(k.held, isFalse);
      expect((a.enabled, a.disabled), (2, 2));
    },
  );
}
