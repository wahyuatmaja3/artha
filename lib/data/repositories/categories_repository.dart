import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import '../local/database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'wallets_repository.dart'; // for databaseProvider

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriesRepository(db);
});

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.watchCategories();
});

class CategoriesRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  CategoriesRepository(this._db);

  Stream<List<CategoryModel>> watchCategories() {
    return _db.categoriesDao.watchAllCategories().map((rows) {
      return rows.map((row) => CategoryModel(
        id: row.id,
        name: row.name,
        type: row.type,
        icon: row.icon,
      )).toList();
    });
  }

  Future<void> addCategory(String name, String type, String icon) async {
    final id = _uuid.v4();
    await _db.categoriesDao.insertCategory(CategoriesCompanion.insert(
      id: id,
      name: name,
      type: type,
      icon: icon,
      userId: const drift.Value('local_user'),
    ));
  }

  Future<void> deleteCategory(String id) async {
    await _db.categoriesDao.deleteCategory(id);
  }
}
