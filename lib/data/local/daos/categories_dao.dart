import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/categories.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<List<Category>> getAllCategories() => (select(categories)..where((t) => t.deletedAt.isNull())).get();
  
  Stream<List<Category>> watchAllCategories() => (select(categories)..where((t) => t.deletedAt.isNull())).watch();

  Future<int> insertCategory(CategoriesCompanion category) => into(categories).insert(category);
  
  Future<bool> updateCategory(CategoriesCompanion category) => update(categories).replace(category);
  
  Future<int> deleteCategory(String id) {
     return (update(categories)..where((t) => t.id.equals(id)))
         .write(CategoriesCompanion(
             deletedAt: Value(DateTime.now()),
             syncStatus: const Value('pending'),
         ));
  }
}
