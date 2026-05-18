import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/savings_goals.dart';

part 'savings_goals_dao.g.dart';

@DriftAccessor(tables: [SavingsGoals])
class SavingsGoalsDao extends DatabaseAccessor<AppDatabase> with _$SavingsGoalsDaoMixin {
  SavingsGoalsDao(super.db);

  Stream<List<SavingsGoal>> watchAllGoals() {
    return (select(savingsGoals)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> insertGoal(SavingsGoalsCompanion goal) => into(savingsGoals).insert(goal);

  Future<int> updateCurrentAmount(String id, double newAmount) {
    return (update(savingsGoals)..where((t) => t.id.equals(id))).write(
      SavingsGoalsCompanion(
        currentAmount: Value(newAmount),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<int> setPaused(String id, bool paused) {
    return (update(savingsGoals)..where((t) => t.id.equals(id))).write(
      SavingsGoalsCompanion(
        isPaused: Value(paused),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<int> deleteGoal(String id) {
    return (update(savingsGoals)..where((t) => t.id.equals(id))).write(
      SavingsGoalsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
