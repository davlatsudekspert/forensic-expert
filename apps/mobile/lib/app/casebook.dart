import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/casebook/casebook_models.dart';

/// Bootstrap’da SharedPreferences bilan override qilinadi (faqat lokal).
final casebookStoreProvider = Provider<CasebookStore>(
  (ref) => InMemoryCasebookStore(),
);

final casebookProvider =
    NotifierProvider<CasebookController, List<CasebookEntry>>(
      CasebookController.new,
    );

/// Ekspert ish daftari. Hamma amal faqat qurilmadagi omborga yoziladi.
class CasebookController extends Notifier<List<CasebookEntry>> {
  static int _seq = 0;

  @override
  List<CasebookEntry> build() {
    final items = [...ref.read(casebookStoreProvider).load()];
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  String newId() =>
      'cb${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_seq++}';

  CasebookEntry? byId(String id) {
    for (final e in state) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> _commit(List<CasebookEntry> next) async {
    final sorted = [...next]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = List.unmodifiable(sorted);
    await ref.read(casebookStoreProvider).save(state);
  }

  /// Yangi yozuv; ID qaytaradi.
  Future<String> create({
    String title = '',
    String caseRef = '',
    DateTime? date,
    String body = '',
    List<CasebookLink> links = const [],
  }) async {
    final now = DateTime.now();
    final e = CasebookEntry(
      id: newId(),
      title: title.trim(),
      caseRef: caseRef.trim(),
      date: date ?? now,
      body: body,
      links: links,
      createdAt: now,
      updatedAt: now,
    );
    await _commit([...state, e]);
    return e.id;
  }

  Future<void> update(CasebookEntry entry) async {
    if (byId(entry.id) == null) return;
    final saved = entry.copyWith(updatedAt: DateTime.now());
    await _commit([
      for (final e in state)
        if (e.id == saved.id) saved else e,
    ]);
  }

  Future<void> addBlock(String entryId, CasebookBlock block) async {
    final e = byId(entryId);
    if (e == null) return;
    await update(e.copyWith(blocks: [...e.blocks, block]));
  }

  Future<void> removeBlock(String entryId, String blockId) async {
    final e = byId(entryId);
    if (e == null) return;
    await update(
      e.copyWith(
        blocks: [
          for (final b in e.blocks)
            if (b.id != blockId) b,
        ],
      ),
    );
  }

  Future<void> delete(String entryId) => _commit([
    for (final e in state)
      if (e.id != entryId) e,
  ]);

  /// Butun daftarni qurilmadan o‘chiradi (qaytarib bo‘lmaydi).
  Future<void> clearAll() async {
    state = const [];
    await ref.read(casebookStoreProvider).clear();
  }
}
