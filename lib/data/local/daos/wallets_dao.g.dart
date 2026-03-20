// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallets_dao.dart';

// ignore_for_file: type=lint
mixin _$WalletsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalletsTable get wallets => attachedDatabase.wallets;
  WalletsDaoManager get managers => WalletsDaoManager(this);
}

class WalletsDaoManager {
  final _$WalletsDaoMixin _db;
  WalletsDaoManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db.attachedDatabase, _db.wallets);
}
