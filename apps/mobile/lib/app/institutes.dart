import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin/institute_models.dart';
import '../domain/ports/institute_ports.dart';

/// Admin: institutlar va sovg‘a promokodlari. Bootstrap’da Supabase bo‘lsa
/// almashtiriladi; aks holda ulanmagan (admin bo‘limi ko‘rinmaydi).
final adminInstituteServiceProvider = Provider<AdminInstituteService>(
  (ref) => const UnconfiguredAdminInstituteService(),
);

final adminInstitutesProvider =
    FutureProvider.autoDispose<List<InstituteSummary>?>((ref) async {
      final r = await ref.watch(adminInstituteServiceProvider).list();
      return r.value;
    });

/// Bitta institut: to‘liq ma’lumot + kodlar. Xato — `null`.
class InstituteBundle {
  const InstituteBundle(this.detail, this.codes);

  final InstituteDetail detail;
  final List<InstituteCode> codes;
}

final adminInstituteProvider = FutureProvider.autoDispose
    .family<InstituteBundle?, String>((ref, id) async {
      final svc = ref.watch(adminInstituteServiceProvider);
      final d = await svc.get(id);
      final c = await svc.codes(id);
      final detail = d.value;
      final codes = c.value;
      if (detail == null || codes == null) return null;
      return InstituteBundle(detail, codes);
    });
