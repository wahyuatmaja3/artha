import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import '../local/database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'wallets_repository.dart'; // for databaseProvider

final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetsRepository(db);
});

final budgetsProvider = StreamProvider<List<BudgetModel>>((ref) {
  final repo = ref.watch(budgetsRepositoryProvider);
  return repo.watchBudgets();
});

class BudgetsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  BudgetsRepository(this._db);

  Stream<List<BudgetModel>> watchBudgets() {
    return _db.budgetsDao.watchAllBudgets().map((rows) {
      return rows.map((row) => BudgetModel(
        id: row.id,
        categoryId: row.categoryId,
        month: row.month,
        limitAmount: row.limitAmount,
      )).toList();
    });
  }

  Future<void> addBudget(String categoryId, String month, double limitAmount) async {
    final id = _uuid.v4();
    await _db.budgetsDao.insertBudget(BudgetsCompanion.insert(
      id: id,
      categoryId: categoryId,
      month: month,
      limitAmount: limitAmount,
      userId: const drift.Value('local_user'),
    ));
  }

  Future<void> updateBudgetLimit(String id, double newLimit) async {
    await _db.budgetsDao.updateLimit(id, newLimit);
  }

  Future<void> deleteBudget(String id) async {
    await _db.budgetsDao.deleteBudget(id);
  }
}
