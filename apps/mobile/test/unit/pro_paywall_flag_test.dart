import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app_config.dart';
import 'package:forensic_expert/app/plan.dart';

void main() {
  test('Pro to‘lov bayrog‘i o‘chiq: hamma narsa bepul (sinov va do‘kon '
      'tekshiruvi)', () {
    expect(kEnableProPaywall, isFalse);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(proEnabledProvider), isFalse);
    expect(c.read(proStrictProvider), isFalse);
  });
}
