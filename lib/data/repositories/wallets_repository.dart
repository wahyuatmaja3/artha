import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/models.dart';
import '../local/database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final walletsRepositoryProvider = Provider<WalletsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WalletsRepository(db);
});

final walletsProvider = StreamProvider<List<WalletModel>>((ref) {
  final repo = ref.watch(walletsRepositoryProvider);
  return repo.watchWallets();
});

class WalletsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  WalletsRepository(this._db);

  Stream<List<WalletModel>> watchWallets() {
    return _db.walletsDao.watchAllWallets().map((rows) {
      return rows.map((row) => WalletModel(
        id: row.id,
        name: row.name,
        balance: row.balance,
      )).toList();
    });
  }

  Future<void> addWallet(String name, double initialBalance) async {
    final id = _uuid.v4();
    await _db.walletsDao.insertWallet(WalletsCompanion.insert(
      id: id,
      name: name,
      balance: drift.Value(initialBalance),
      userId: const drift.Value('local_user'), // Replace when Auth is added
    ));
    // Implementation of trigger sync event goes here
  }

  Future<void> updateBalance(String id, double newBalance) async {
    await _db.walletsDao.updateBalance(id, newBalance);
  }

  Future<void> deleteWallet(String id) async {
    await _db.walletsDao.deleteWallet(id);
  }
}

// Needed because Drift types conflict with other imports sometimes

