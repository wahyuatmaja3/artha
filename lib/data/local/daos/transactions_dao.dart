import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/transactions.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<Transaction>> getAllTransactions() => (select(transactions)..where((t) => t.deletedAt.isNull())).get();

  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
        .watch();
  }
  
  Stream<List<Transaction>> watchTransactionsByMonth(DateTime monthStart, DateTime monthEnd) {
     return (select(transactions)
          ..where((t) => t.deletedAt.isNull() & t.transactionDate.isBetweenValues(monthStart, monthEnd))
          ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) => into(transactions).insert(transaction);
  
  Future<bool> updateTransaction(TransactionsCompanion transaction) => update(transactions).replace(transaction);
  
  Future<int> deleteTransaction(String id) {
     return (update(transactions)..where((t) => t.id.equals(id)))
         .write(TransactionsCompanion(
             deletedAt: Value(DateTime.now()),
             syncStatus: const Value('pending'),
         ));
  }
}
