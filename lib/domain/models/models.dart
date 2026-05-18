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

class InvestmentPlanModel {
  final String id;
  final String walletId;
  final String name;
  final String investmentType;
  final double targetAmount;
  final double periodicAllocation;
  final String frequency;
  final DateTime startDate;
  final String note;
  final double currentAmount;
  final bool isPaused;
  final bool autoInvestEnabled;

  final String? walletName;

  const InvestmentPlanModel({
    required this.id,
    required this.walletId,
    required this.name,
    required this.investmentType,
    required this.targetAmount,
    required this.periodicAllocation,
    required this.frequency,
    required this.startDate,
    required this.note,
    required this.currentAmount,
    required this.isPaused,
    required this.autoInvestEnabled,
    this.walletName,
  });

  double get progress => targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  String get status {
    if (isPaused) return 'Paused';
    if (currentAmount >= targetAmount) return 'Completed';
    return 'Active';
  }

  DateTime? get estimatedFinishDate {
    if (periodicAllocation <= 0 || frequency.isEmpty) return null;
    final remaining = (targetAmount - currentAmount).clamp(0, double.infinity);
    if (remaining <= 0) return DateTime.now();
    final cycles = (remaining / periodicAllocation).ceil();
    switch (frequency) {
      case 'daily':
        return DateTime.now().add(Duration(days: cycles));
      case 'weekly':
        return DateTime.now().add(Duration(days: cycles * 7));
      case 'yearly':
        return DateTime(DateTime.now().year + cycles, DateTime.now().month, DateTime.now().day);
      case 'monthly':
      default:
        return DateTime(DateTime.now().year, DateTime.now().month + cycles, DateTime.now().day);
    }
  }
}
