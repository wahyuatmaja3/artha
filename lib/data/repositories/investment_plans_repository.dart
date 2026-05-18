import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/models.dart';
import '../local/database.dart';
import 'wallets_repository.dart';

final investmentPlansRepositoryProvider = Provider<InvestmentPlansRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final walletsRepo = ref.watch(walletsRepositoryProvider);
  return InvestmentPlansRepository(db, walletsRepo);
});

final investmentPlansProvider = StreamProvider<List<InvestmentPlanModel>>((ref) {
  final repo = ref.watch(investmentPlansRepositoryProvider);
  return repo.watchPlans();
});

class InvestmentPlansRepository {
  final AppDatabase _db;
  final WalletsRepository _walletsRepo;
  final _uuid = const Uuid();

  InvestmentPlansRepository(this._db, this._walletsRepo);

  Stream<List<InvestmentPlanModel>> watchPlans() {
    return _db.investmentPlansDao.watchAllPlans().asyncMap((rows) async {
      await _runAutoInvestments(rows);
      final wallets = await _db.walletsDao.getAllWallets();
      final walletsById = {for (final w in wallets) w.id: w};
      return rows
          .map(
            (row) => InvestmentPlanModel(
              id: row.id,
              walletId: row.walletId,
              name: row.name,
              investmentType: row.investmentType,
              targetAmount: row.targetAmount,
              periodicAllocation: row.periodicAllocation,
              frequency: row.frequency,
              startDate: row.startDate,
              note: row.note,
              currentAmount: row.currentAmount,
              isPaused: row.isPaused,
              autoInvestEnabled: row.autoInvestEnabled,
              walletName: walletsById[row.walletId]?.name,
            ),
          )
          .toList();
    });
  }

  Future<void> addPlan({
    required String walletId,
    required String name,
    required String investmentType,
    required double targetAmount,
    required double periodicAllocation,
    required String frequency,
    required DateTime startDate,
    String note = '',
    bool autoInvestEnabled = false,
  }) async {
    await _db.investmentPlansDao.insertPlan(
      InvestmentPlansCompanion.insert(
        id: _uuid.v4(),
        walletId: walletId,
        name: name,
        investmentType: investmentType,
        targetAmount: targetAmount,
        periodicAllocation: periodicAllocation,
        frequency: frequency,
        startDate: startDate,
        note: drift.Value(note),
        autoInvestEnabled: drift.Value(autoInvestEnabled),
        nextAutoInvestAt: drift.Value(autoInvestEnabled ? startDate : null),
        userId: const drift.Value('local_user'),
      ),
    );
  }

  Future<void> _runAutoInvestments(List<InvestmentPlan> rows) async {
    final now = DateTime.now();
    for (final row in rows) {
      if (!row.autoInvestEnabled || row.isPaused || row.nextAutoInvestAt == null) continue;
      if (row.nextAutoInvestAt!.isAfter(now)) continue;
      await addContribution(row.id, row.periodicAllocation);
      await _db.investmentPlansDao.updateAutoSchedule(row.id, _nextFrom(row.frequency, row.nextAutoInvestAt!));
    }
  }

  DateTime _nextFrom(String frequency, DateTime current) {
    switch (frequency) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      case 'monthly':
      default:
        return DateTime(current.year, current.month + 1, current.day);
    }
  }

  Future<void> addContribution(String planId, double amount) async {
    final plan = await (_db.select(
      _db.investmentPlans,
    )..where((t) => t.id.equals(planId) & t.deletedAt.isNull())).getSingle();
    final next = (plan.currentAmount + amount).clamp(0.0, double.infinity).toDouble();
    await _db.investmentPlansDao.updateCurrentAmount(planId, next);

    final wallet = await _db.walletsDao.getWalletById(plan.walletId);
    await _walletsRepo.updateBalance(plan.walletId, wallet.balance - amount);
  }

  Future<void> setPaused(String planId, bool paused) async {
    await _db.investmentPlansDao.setPaused(planId, paused);
  }
}
