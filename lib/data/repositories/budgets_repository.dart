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
    return _db.budgetsDao.watchAllBudgets().asyncMap((rows) async {
      final categories = await _db.categoriesDao.getAllCategories();
      final transactions = await _db.transactionsDao.getAllTransactions();

      final categoriesById = {for (final c in categories) c.id: c};

      double usedAmountFor(String categoryId, String month) {
        final parts = month.split('-');
        if (parts.length != 2) return 0.0;

        final year = int.tryParse(parts[0]);
        final monthInt = int.tryParse(parts[1]);
        if (year == null || monthInt == null) return 0.0;

        return transactions
            .where((tx) {
              final txDate = tx.transactionDate;
              return tx.categoryId == categoryId &&
                  txDate.year == year &&
                  txDate.month == monthInt;
            })
            .fold(0.0, (sum, tx) => sum + tx.amount.abs());
      }

      return rows.map((row) {
        final category = categoriesById[row.categoryId];
        return BudgetModel(
          id: row.id,
          categoryId: row.categoryId,
          month: row.month,
          limitAmount: row.limitAmount,
          categoryName: category?.name,
          categoryIcon: category?.icon,
          usedAmount: usedAmountFor(row.categoryId, row.month),
        );
      }).toList();
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
