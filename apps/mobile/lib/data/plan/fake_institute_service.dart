import '../../domain/admin/institute_models.dart';
import '../../domain/plan/plan_models.dart';
import '../../domain/ports/institute_ports.dart';
import '../../domain/ports/plan_ports.dart';

/// Test/demo admin xizmati: institutlar va kodlar xotirada.
class FakeAdminInstituteService implements AdminInstituteService {
  FakeAdminInstituteService({this.failure});

  PlanFailure? failure;

  /// Faqat arxiv/uzaytirish amallari uchun xato (o‘qish ishlayveradi).
  PlanFailure? actionFailure;
  final calls = <String>[];
  final _details = <String, InstituteDetail>{};
  final _codes = <String, List<InstituteCode>>{};
  final _archived = <String>{};
  var _seq = 0;

  /// Berilgan institut (testlar uchun tayyor ma’lumot).
  void seed(InstituteDetail d, List<InstituteCode> codes) {
    _details[d.id] = d;
    _codes[d.id] = [...codes];
  }

  @override
  bool get isConfigured => true;

  @override
  Future<PlanResult<IssuedCodes>> create(InstituteDraft draft) async {
    calls.add('create:${draft.name}:${draft.seats}');
    if (failure != null) return PlanResult.fail(failure!);
    if (!draft.isValid) return const PlanResult.fail(PlanFailure.invalid);
    final id = 'inst-${++_seq}';
    final start = draft.termStart ?? DateTime.now();
    _details[id] = InstituteDetail(
      id: id,
      name: draft.name.trim(),
      seats: draft.seats,
      months: draft.months,
      termStart: start,
      termEnd: DateTime(start.year, start.month + draft.months, start.day),
    );
    final codes = [
      for (var i = 1; i <= draft.seats; i++)
        InstituteCode(
          n: i,
          code:
              'FAKE${_seq.toString().padLeft(2, '0')}${i.toString().padLeft(4, '0')}',
          revoked: false,
        ),
    ];
    _codes[id] = codes;
    return PlanResult.ok(
      IssuedCodes(instituteId: id, codes: [for (final c in codes) c.code]),
    );
  }

  @override
  Future<PlanResult<List<InstituteSummary>>> list() async {
    calls.add('list');
    if (failure != null) return PlanResult.fail(failure!);
    return PlanResult.ok([
      for (final d in _details.values)
        InstituteSummary(
          id: d.id,
          name: d.name,
          seats: d.seats,
          redeemed: _codes[d.id]!
              .where((c) => c.status == InstituteCodeStatus.redeemed)
              .length,
          revoked: _codes[d.id]!.where((c) => c.revoked).length,
          termStart: d.termStart,
          termEnd: d.termEnd,
          archived: _archived.contains(d.id),
        ),
    ]);
  }

  @override
  Future<PlanResult<InstituteDetail>> get(String id) async {
    calls.add('get:$id');
    if (failure != null) return PlanResult.fail(failure!);
    final d = _details[id];
    return d == null
        ? const PlanResult.fail(PlanFailure.server)
        : PlanResult.ok(d);
  }

  @override
  Future<PlanResult<List<InstituteCode>>> codes(String id) async {
    calls.add('codes:$id');
    if (failure != null) return PlanResult.fail(failure!);
    return PlanResult.ok([...?_codes[id]]);
  }

  @override
  Future<PlanResult<IssuedCodes>> createGiftCodes({
    required String from,
    required int count,
    required int days,
    required Plan plan,
  }) async {
    calls.add('gift:$from:$count:$days:${plan.name}');
    if (failure != null) return PlanResult.fail(failure!);
    if (from.trim().length < 2 ||
        count < 1 ||
        count > 50 ||
        days < 1 ||
        days > 1100) {
      return const PlanResult.fail(PlanFailure.invalid);
    }
    return PlanResult.ok(
      IssuedCodes(codes: [for (var i = 1; i <= count; i++) 'GIFT000$i']),
    );
  }

  @override
  Future<PlanResult<bool>> revokeCode(String code) async {
    calls.add('revoke:$code');
    if (failure != null) return PlanResult.fail(failure!);
    for (final list in _codes.values) {
      for (var i = 0; i < list.length; i++) {
        final c = list[i];
        if (c.code == code && c.status == InstituteCodeStatus.free) {
          list[i] = InstituteCode(n: c.n, code: c.code, revoked: true);
          return const PlanResult.ok(true);
        }
      }
    }
    return const PlanResult.ok(false);
  }

  @override
  Future<PlanResult<bool>> setArchived(
    String id, {
    required bool archived,
  }) async {
    calls.add('archive:$id:$archived');
    if (actionFailure != null) return PlanResult.fail(actionFailure!);
    if (failure != null) return PlanResult.fail(failure!);
    if (!_details.containsKey(id)) {
      return const PlanResult.fail(PlanFailure.invalid);
    }
    archived ? _archived.add(id) : _archived.remove(id);
    return PlanResult.ok(archived);
  }

  @override
  Future<PlanResult<InstituteExtension>> extend(String id, int months) async {
    calls.add('extend:$id:$months');
    if (actionFailure != null) return PlanResult.fail(actionFailure!);
    if (failure != null) return PlanResult.fail(failure!);
    final d = _details[id];
    if (d == null || months < 1 || months > 60) {
      return const PlanResult.fail(PlanFailure.invalid);
    }
    final end = d.termEnd ?? DateTime.now();
    final next = DateTime(end.year, end.month + months, end.day);
    _details[id] = InstituteDetail(
      id: d.id,
      name: d.name,
      seats: d.seats,
      months: d.months + months,
      termStart: d.termStart,
      termEnd: next,
    );
    final used = _codes[id]!
        .where((c) => c.status == InstituteCodeStatus.redeemed)
        .length;
    return PlanResult.ok(
      InstituteExtension(termEnd: next, plansExtended: used),
    );
  }
}
