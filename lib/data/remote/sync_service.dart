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

  Future<void> pullAll() async {
    await pullWallets();
    await pullCategories();
    await pullTransactions();
  }

  // ================= WALLET =================

  Future<void> pullWallets() async {
    final rows = await _supabase.from('wallets').select();

    await _db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          _db.wallets,
          WalletsCompanion(
            id: Value(row['id']?.toString() ?? ''),
            name: Value(row['name']?.toString() ?? ''),
            balance: Value((row['balance'] as num?)?.toDouble() ?? 0),
            userId: Value(row['user_id']?.toString()),
            syncStatus: const Value('synced'),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ================= CATEGORY =================

  Future<void> pullCategories() async {
    final rows = await _supabase.from('categories').select();

    await _db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          _db.categories,
          CategoriesCompanion(
            id: Value(row['id']?.toString() ?? ''),
            name: Value(row['name']?.toString() ?? ''),
            type: Value(row['type']?.toString() ?? ''),
            icon: Value(row['icon']?.toString() ?? 'category'),
            userId: Value(row['user_id']?.toString()),
            syncStatus: const Value('synced'),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ================= TRANSACTION =================

  Future<void> pullTransactions() async {
    final rows = await _supabase.from('transactions').select();

    await _db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          _db.transactions,
          TransactionsCompanion(
            id: Value(row['id']?.toString() ?? ''),
            walletId: Value(row['wallet_id']?.toString() ?? ''),
            categoryId: Value(row['category_id']?.toString() ?? ''),
            amount: Value((row['amount'] as num?)?.toDouble() ?? 0),
            transactionDate: Value(
              DateTime.tryParse(row['transaction_date']?.toString() ?? '') ??
                  DateTime.now(),
            ),
            note: Value(row['note']?.toString()),
            userId: Value(row['user_id']?.toString()),
            syncStatus: const Value('synced'),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
