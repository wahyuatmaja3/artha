import 'package:drift/drift.dart';
import 'wallets.dart';

class InvestmentPlans extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get name => text()();
  TextColumn get investmentType => text()();
  RealColumn get targetAmount => real()();
  RealColumn get periodicAllocation => real()();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  BoolColumn get autoInvestEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get nextAutoInvestAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
