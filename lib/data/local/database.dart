import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/wallets.dart';
import 'tables/categories.dart';
import 'tables/transactions.dart';
import 'tables/budgets.dart';

import 'daos/wallets_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/budgets_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Wallets, Categories, Transactions, Budgets],
  daos: [WalletsDao, CategoriesDao, TransactionsDao, BudgetsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement('''
        CREATE TABLE IF NOT EXISTS recurring_rules (
          id TEXT PRIMARY KEY,
          wallet_id TEXT NOT NULL,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          note TEXT,
          frequency TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT,
          reminder_enabled INTEGER NOT NULL DEFAULT 0,
          auto_create_enabled INTEGER NOT NULL DEFAULT 1,
          is_active INTEGER NOT NULL DEFAULT 1,
          next_run_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await customStatement('''
          CREATE TABLE IF NOT EXISTS recurring_rules (
            id TEXT PRIMARY KEY,
            wallet_id TEXT NOT NULL,
            category_id TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            note TEXT,
            frequency TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT,
            reminder_enabled INTEGER NOT NULL DEFAULT 0,
            auto_create_enabled INTEGER NOT NULL DEFAULT 1,
            is_active INTEGER NOT NULL DEFAULT 1,
            next_run_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'artha.sqlite'));

    // Extract bundled sqlite3 on Android so it can be found
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
