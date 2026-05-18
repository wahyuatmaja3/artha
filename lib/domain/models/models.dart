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

class SavingsGoalModel {
  final String id;
  final String walletId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String priority;
  final String description;
  final String icon;
  final bool isPaused;

  final String? walletName;

  const SavingsGoalModel({
    required this.id,
    required this.walletId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.priority,
    required this.description,
    required this.icon,
    this.isPaused = false,
    this.walletName,
  });

  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);

  double get progress => targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  String get status {
    if (isPaused) return 'Paused';
    if (currentAmount >= targetAmount) return 'Completed';
    if (targetDate != null && DateTime.now().isAfter(targetDate!)) return 'Failed';
    return 'Ongoing';
  }
}
