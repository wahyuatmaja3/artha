// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_plans_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestmentPlansDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalletsTable get wallets => attachedDatabase.wallets;
  $InvestmentPlansTable get investmentPlans => attachedDatabase.investmentPlans;
  InvestmentPlansDaoManager get managers => InvestmentPlansDaoManager(this);
}

class InvestmentPlansDaoManager {
  final _$InvestmentPlansDaoMixin _db;
  InvestmentPlansDaoManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db.attachedDatabase, _db.wallets);
  $$InvestmentPlansTableTableManager get investmentPlans =>
      $$InvestmentPlansTableTableManager(
        _db.attachedDatabase,
        _db.investmentPlans,
      );
}
