import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/database.dart';
import '../repositories/wallets_repository.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

class SyncService {
  final AppDatabase _db;
  final SupabaseClient _supabase = Supabase.instance.client;

  SyncService(this._db);

  /// Pull all data from Supabase into local SQLite
  Future<void> pullAll() async {
    await pullWallets();
    await pullCategories();
    await pullTransactions();
  }

  Future<void> pullWallets() async {
    final rows = await _supabase.from('wallets').select();
    for (final row in rows) {
      await _db.walletsDao.insertWallet(WalletsCompanion.insert(
        id: row['id'] as String,
        name: row['name'] as String,
        balance: Value((row['balance'] as num?)?.toDouble() ?? 0.0),
        userId: Value(row['user_id'] as String?),
        syncStatus: const Value('synced'),
      )).catchError((_) async {
        // Already exists, update instead
        await ((_db.update(_db.wallets))
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(WalletsCompanion(
          name: Value(row['name'] as String),
          balance: Value((row['balance'] as num?)?.toDouble() ?? 0.0),
          syncStatus: const Value('synced'),
        ));
      });
    }
  }

  Future<void> pullCategories() async {
    final rows = await _supabase.from('categories').select();
    for (final row in rows) {
      await _db.categoriesDao.insertCategory(CategoriesCompanion.insert(
        id: row['id'] as String,
        name: row['name'] as String,
        type: row['type'] as String,
        icon: row['icon'] as String? ?? 'category',
        userId: Value(row['user_id'] as String?),
        syncStatus: const Value('synced'),
      )).catchError((_) async {
        await ((_db.update(_db.categories))
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(CategoriesCompanion(
          name: Value(row['name'] as String),
          type: Value(row['type'] as String),
          icon: Value(row['icon'] as String? ?? 'category'),
          syncStatus: const Value('synced'),
        ));
      });
    }
  }

  Future<void> pullTransactions() async {
    final rows = await _supabase.from('transactions').select();
    for (final row in rows) {
      await _db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        id: row['id'] as String,
        walletId: row['wallet_id'] as String,
        categoryId: row['category_id'] as String,
        amount: (row['amount'] as num).toDouble(),
        transactionDate: DateTime.parse(row['transaction_date'] as String),
        note: Value(row['note'] as String?),
        userId: Value(row['user_id'] as String?),
        syncStatus: const Value('synced'),
      )).catchError((_) async {
        await ((_db.update(_db.transactions))
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(TransactionsCompanion(
          amount: Value((row['amount'] as num).toDouble()),
          note: Value(row['note'] as String?),
          syncStatus: const Value('synced'),
        ));
      });
    }
  }
}
