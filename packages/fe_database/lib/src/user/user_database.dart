import 'package:drift/drift.dart';

part 'user_database.g.dart';

/// Foydalanuvchi bookmark’lari. Kontent paketidan mustaqil — paket
/// yangilanganda o‘chmaydi.
class Bookmarks extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}

/// Yaqinda ishlatilgan vositalar (Professional dashboard uchun).
class RecentItems extends Table {
  TextColumn get itemType => text()();
  TextColumn get itemId => text()();
  DateTimeColumn get usedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemType, itemId};
}

/// user.db — qurilmadagi foydalanuvchi ma’lumotlari (skelet).
/// Sezgir qaydlar (secure notes) PHASE 2+ da maydon darajasida shifrlanadi.
@DriftDatabase(tables: [Bookmarks, RecentItems])
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  Future<void> addBookmark(String type, String id, DateTime now) =>
      into(bookmarks).insertOnConflictUpdate(
        BookmarksCompanion.insert(
          entityType: type,
          entityId: id,
          createdAt: now,
        ),
      );

  Future<List<Bookmark>> allBookmarks() => (select(
    bookmarks,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
}
