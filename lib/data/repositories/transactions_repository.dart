import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import '../local/database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'wallets_repository.dart'; // for databaseProvider

enum RecurringFrequency { daily, weekly, monthly, yearly }

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final walletsRepo = ref.watch(walletsRepositoryProvider);
  return TransactionsRepository(db, walletsRepo);
});

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchTransactions();
});

class TransactionsRepository {
  final AppDatabase _db;
  final WalletsRepository _walletsRepo;
  final _uuid = const Uuid();

  TransactionsRepository(this._db, this._walletsRepo);

  Stream<List<TransactionModel>> watchTransactions() {
    return _db.transactionsDao.watchAllTransactions().asyncMap((rows) async {
      final categories = await _db.categoriesDao.getAllCategories();
      final wallets = await _db.walletsDao.getAllWallets();

      final categoriesById = {for (final c in categories) c.id: c};
      final walletsById = {for (final w in wallets) w.id: w};

      return rows
          .map(
            (row) {
              final category = categoriesById[row.categoryId];
              final wallet = walletsById[row.walletId];

              return TransactionModel(
                id: row.id,
                walletId: row.walletId,
                categoryId: row.categoryId,
                amount: row.amount,
                note: row.note ?? '',
                date: row.transactionDate,
                walletName: wallet?.name,
                categoryName: category?.name,
                categoryIcon: category?.icon,
                categoryType: category?.type,
              );
            },
          )
          .toList();
    });
  }

  Future<void> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required String type, // 'income' or 'expense'
    required DateTime date,
    String note = '',
  }) async {
    final id = _uuid.v4();
    
    // 1. Insert transaction
    await _db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
      id: id,
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      transactionDate: date,
      note: drift.Value(note),
      userId: const drift.Value('local_user'),
    ));

    // 2. Update wallet balance
    final wallet = await _db.walletsDao.getWalletById(walletId);
    final modifier = type == 'expense' ? -1 : 1;
    final newBalance = wallet.balance + (amount * modifier);
    await _walletsRepo.updateBalance(walletId, newBalance);
  }

  Future<void> addRecurringRule({
    required String walletId,
    required String categoryId,
    required double amount,
    required String type,
    required DateTime startDate,
    DateTime? endDate,
    required RecurringFrequency frequency,
    String note = '',
    bool reminderEnabled = false,
    bool autoCreateEnabled = true,
  }) async {
    final now = DateTime.now().toUtc();
    final startUtc = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final endUtc = endDate == null ? null : DateTime.utc(endDate.year, endDate.month, endDate.day);
    final nextRunAt = _calculateNextRunAt(
      frequency: frequency,
      startDate: startUtc,
      reference: now,
    );

    await _db.customStatement(
      '''
      INSERT INTO recurring_rules (
        id, wallet_id, category_id, amount, type, note, frequency,
        start_date, end_date, reminder_enabled, auto_create_enabled,
        is_active, next_run_at, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        _uuid.v4(),
        walletId,
        categoryId,
        amount,
        type,
        note,
        frequency.name,
        startUtc.toIso8601String(),
        endUtc?.toIso8601String(),
        reminderEnabled ? 1 : 0,
        autoCreateEnabled ? 1 : 0,
        1,
        nextRunAt.toIso8601String(),
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );
  }

  DateTime _calculateNextRunAt({
    required RecurringFrequency frequency,
    required DateTime startDate,
    required DateTime reference,
  }) {
    var next = startDate;
    while (!next.isAfter(reference)) {
      switch (frequency) {
        case RecurringFrequency.daily:
          next = next.add(const Duration(days: 1));
          break;
        case RecurringFrequency.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case RecurringFrequency.monthly:
          next = DateTime.utc(next.year, next.month + 1, next.day);
          break;
        case RecurringFrequency.yearly:
          next = DateTime.utc(next.year + 1, next.month, next.day);
          break;
      }
    }
    return next;
  }

  Future<void> deleteTransaction(String id, String walletId, double amount, String type) async {
    await _db.transactionsDao.deleteTransaction(id);
    
    // Reverse wallet balance
    final wallet = await _db.walletsDao.getWalletById(walletId);
    final modifier = type == 'expense' ? 1 : -1; // Reverse logic
    final newBalance = wallet.balance + (amount * modifier);
    await _walletsRepo.updateBalance(walletId, newBalance);
  }
}
