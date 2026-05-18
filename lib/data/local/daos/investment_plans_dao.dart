import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/investment_plans.dart';

part 'investment_plans_dao.g.dart';

@DriftAccessor(tables: [InvestmentPlans])
class InvestmentPlansDao extends DatabaseAccessor<AppDatabase> with _$InvestmentPlansDaoMixin {
  InvestmentPlansDao(super.db);

  Stream<List<InvestmentPlan>> watchAllPlans() {
    return (select(investmentPlans)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> insertPlan(InvestmentPlansCompanion plan) => into(investmentPlans).insert(plan);

  Future<int> updateCurrentAmount(String id, double newAmount) {
    return (update(investmentPlans)..where((t) => t.id.equals(id))).write(
      InvestmentPlansCompanion(
        currentAmount: Value(newAmount),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<int> setPaused(String id, bool paused) {
    return (update(investmentPlans)..where((t) => t.id.equals(id))).write(
      InvestmentPlansCompanion(
        isPaused: Value(paused),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<int> updateAutoSchedule(String id, DateTime? nextAt) {
    return (update(investmentPlans)..where((t) => t.id.equals(id))).write(
      InvestmentPlansCompanion(
        nextAutoInvestAt: Value(nextAt),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
