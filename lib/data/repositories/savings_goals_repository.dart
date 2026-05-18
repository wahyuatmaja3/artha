import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/models.dart';
import '../local/database.dart';
import 'wallets_repository.dart';

final savingsGoalsRepositoryProvider = Provider<SavingsGoalsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final walletsRepo = ref.watch(walletsRepositoryProvider);
  return SavingsGoalsRepository(db, walletsRepo);
});

final savingsGoalsProvider = StreamProvider<List<SavingsGoalModel>>((ref) {
  final repo = ref.watch(savingsGoalsRepositoryProvider);
  return repo.watchGoals();
});

class SavingsGoalsRepository {
  final AppDatabase _db;
  final WalletsRepository _walletsRepo;
  final _uuid = const Uuid();

  SavingsGoalsRepository(this._db, this._walletsRepo);

  Stream<List<SavingsGoalModel>> watchGoals() {
    return _db.savingsGoalsDao.watchAllGoals().asyncMap((rows) async {
      final wallets = await _db.walletsDao.getAllWallets();
      final walletsById = {for (final w in wallets) w.id: w};

      return rows.map((row) {
        final wallet = walletsById[row.walletId];
        return SavingsGoalModel(
          id: row.id,
          walletId: row.walletId,
          name: row.name,
          targetAmount: row.targetAmount,
          currentAmount: row.currentAmount,
          targetDate: row.targetDate,
          priority: row.priority,
          description: row.description,
          icon: row.icon,
          isPaused: row.isPaused,
          walletName: wallet?.name,
        );
      }).toList();
    });
  }

  Future<void> addGoal({
    required String walletId,
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String priority = 'medium',
    String description = '',
    String icon = '🎯',
  }) async {
    await _db.savingsGoalsDao.insertGoal(
      SavingsGoalsCompanion.insert(
        id: _uuid.v4(),
        walletId: walletId,
        name: name,
        targetAmount: targetAmount,
        targetDate: drift.Value(targetDate),
        priority: drift.Value(priority),
        description: drift.Value(description),
        icon: drift.Value(icon),
        userId: const drift.Value('local_user'),
      ),
    );
  }

  Future<void> addContribution(String goalId, double amount) async {
    final goal = await (_db.select(
      _db.savingsGoals,
    )..where((t) => t.id.equals(goalId) & t.deletedAt.isNull())).getSingle();
    final next = (goal.currentAmount + amount).clamp(0.0, double.infinity).toDouble();
    await _db.savingsGoalsDao.updateCurrentAmount(goalId, next);

    final wallet = await _db.walletsDao.getWalletById(goal.walletId);
    final newWalletBalance = wallet.balance - amount;
    await _walletsRepo.updateBalance(goal.walletId, newWalletBalance);
  }

  Future<void> setPaused(String goalId, bool paused) async {
    await _db.savingsGoalsDao.setPaused(goalId, paused);
  }

  Future<void> deleteGoal(String goalId) async {
    await _db.savingsGoalsDao.deleteGoal(goalId);
  }
}
