// Domain Models

class WalletModel {
  final String id;
  final String name;
  final double balance;

  WalletModel({required this.id, required this.name, required this.balance});
}

class CategoryModel {
  final String id;
  final String name;
  final String type;
  final String icon;

  CategoryModel({required this.id, required this.name, required this.type, required this.icon});
}

class TransactionModel {
  final String id;
  final String walletId;
  final String categoryId;
  final double amount;
  final String note;
  final DateTime date;
  
  // Relational data populated by joins
  final String? walletName;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryType;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.date,
    this.walletName,
    this.categoryName,
    this.categoryIcon,
    this.categoryType,
  });
}

class BudgetModel {
  final String id;
  final String categoryId;
  final String month;
  final double limitAmount;
  
  // Relational data
  final String? categoryName;
  final String? categoryIcon;
  final double usedAmount;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limitAmount,
    this.categoryName,
    this.categoryIcon,
    this.usedAmount = 0.0,
  });
}
