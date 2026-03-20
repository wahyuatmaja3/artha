import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/budgets.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  Future<List<Budget>> getAllBudgets() => (select(budgets)..where((t) => t.deletedAt.isNull())).get();
  
  Stream<List<Budget>> watchAllBudgets() => (select(budgets)..where((t) => t.deletedAt.isNull())).watch();
  
  Stream<List<Budget>> watchBudgetsByMonth(String month) {
     return (select(budgets)..where((t) => t.deletedAt.isNull() & t.month.equals(month))).watch();
  }

  Future<int> insertBudget(BudgetsCompanion budget) => into(budgets).insert(budget);
  
  Future<bool> updateBudget(BudgetsCompanion budget) => update(budgets).replace(budget);
  
  Future<int> updateLimit(String id, double newLimit) {
      return (update(budgets)..where((t) => t.id.equals(id)))
          .write(BudgetsCompanion(
              limitAmount: Value(newLimit),
              syncStatus: const Value('pending'),
          ));
  }
  
  Future<int> deleteBudget(String id) {
     return (update(budgets)..where((t) => t.id.equals(id)))
         .write(BudgetsCompanion(
             deletedAt: Value(DateTime.now()),
             syncStatus: const Value('pending'),
         ));
  }
}
