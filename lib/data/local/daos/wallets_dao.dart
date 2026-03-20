import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/wallets.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletsDao extends DatabaseAccessor<AppDatabase> with _$WalletsDaoMixin {
  WalletsDao(super.db);

  Future<List<Wallet>> getAllWallets() => (select(wallets)..where((t) => t.deletedAt.isNull())).get();
  
  Stream<List<Wallet>> watchAllWallets() => (select(wallets)..where((t) => t.deletedAt.isNull())).watch();

  Future<Wallet> getWalletById(String id) => (select(wallets)..where((t) => t.id.equals(id))).getSingle();

  Future<int> insertWallet(WalletsCompanion wallet) => into(wallets).insert(wallet);
  
  Future<bool> updateWallet(WalletsCompanion wallet) => update(wallets).replace(wallet);
  
  Future<int> deleteWallet(String id) {
     return (update(wallets)..where((t) => t.id.equals(id)))
         .write(WalletsCompanion(
             deletedAt: Value(DateTime.now()),
             syncStatus: const Value('pending'),
         ));
  }

  Future<void> updateBalance(String id, double newBalance) {
     return (update(wallets)..where((t) => t.id.equals(id)))
         .write(WalletsCompanion(
             balance: Value(newBalance),
             syncStatus: const Value('pending'),
             updatedAt: Value(DateTime.now()),
         ));
  }
}
