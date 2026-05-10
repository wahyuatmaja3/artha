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
  repo.ensureDefaultCategories();
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

  Future<void> ensureDefaultCategories() async {
    final existing = await _db.categoriesDao.getAllCategories();
    if (existing.isNotEmpty) return;

    const dailyExpenseCategories = [
      ('Makan', '🍽️'),
      ('Bensin', '⛽'),
      ('Listrik', '💡'),
      ('Air', '🚰'),
      ('Internet', '🌐'),
      ('Belanja Harian', '🛒'),
      ('Transportasi', '🚌'),
      ('Kesehatan', '💊'),
      ('Pendidikan', '📚'),
      ('Hiburan', '🎬'),
      ('Lainnya', '📦'),
    ];

    const dailyIncomeCategories = [
      ('Gaji', '💼'),
      ('Bonus', '🎁'),
      ('Freelance', '🧑‍💻'),
      ('Usaha', '🏪'),
      ('Hadiah', '🎉'),
      ('Investasi', '📈'),
      ('Lainnya', '💰'),
    ];

    for (final item in dailyExpenseCategories) {
      await addCategory(item.$1, 'expense', item.$2);
    }

    for (final item in dailyIncomeCategories) {
      await addCategory(item.$1, 'income', item.$2);
    }
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
