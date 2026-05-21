import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/repositories/budgets_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../core/utils/formatters.dart';
import '../../core/ui/neo_widgets.dart';
import '../../domain/models/models.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  Future<void> _showAddBudgetSheet(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> expenseCategories,
  ) async {

    var selectedCategoryId = expenseCategories.first.id;
    final limitController = TextEditingController();
    var selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tambah Budget', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: expenseCategories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text('${c.icon} ${c.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => selectedCategoryId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: limitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Limit Budget',
                        hintText: 'contoh: 1500000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bulan'),
                      subtitle: Text(DateUtilsApp.formatMonth(selectedMonth)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedMonth,
                          firstDate: DateTime(2020, 1),
                          lastDate: DateTime(2100, 12),
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked == null) return;
                        setSheetState(() {
                          selectedMonth = DateTime(picked.year, picked.month);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                    final limitAmount = double.tryParse(limitController.text.trim());
                    if (limitAmount == null || limitAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Limit budget tidak valid')),
                      );
                      return;
                    }

                    final month =
                        '${selectedMonth.year.toString().padLeft(4, '0')}-${selectedMonth.month.toString().padLeft(2, '0')}';
                    await ref
                        .read(budgetsRepositoryProvider)
                        .addBudget(selectedCategoryId, month, limitAmount);

                    if (!context.mounted) return;
                    Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget berhasil ditambahkan')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsyncValue = ref.watch(budgetsProvider);
    final transactionsAsyncValue = ref.watch(transactionsProvider);
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final List<CategoryModel> expenseCategories = categoriesAsyncValue.maybeWhen(
      data: (items) => items.where((c) => c.type == 'expense').toList(),
      orElse: () => <CategoryModel>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            onPressed: () {
              if (categoriesAsyncValue.isLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memuat kategori...')),
                );
                return;
              }

              if (expenseCategories.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kategori pengeluaran belum tersedia'),
                  ),
                );
                return;
              }

              _showAddBudgetSheet(context, ref, expenseCategories);
            },
          ),
        ],
      ),
      body: budgetsAsyncValue.when(
        data: (budgets) {
          final transactions = transactionsAsyncValue.maybeWhen(
            data: (items) => items,
            orElse: () => <TransactionModel>[],
          );

          if (budgets.isEmpty) {
            return const Center(
              child: Text(
                'No budgets set.\nTap + to create a monthly limit.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final usedAmount = _calculateUsedAmount(transactions, budget);
              final progress = usedAmount / budget.limitAmount;
              final color = progress > 0.9 ? Colors.red : (progress > 0.7 ? Colors.orange : Colors.green);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeoCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(budget.categoryIcon ?? '🛒'),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                budget.categoryName ?? 'Category',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress > 1.0 ? 1.0 : progress,
                        backgroundColor: Colors.grey.shade300,
                        color: color,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text('Spent: ${CurrencyUtils.formatRupiah(usedAmount)}'),
                           Text('Limit: ${CurrencyUtils.formatRupiah(budget.limitAmount)}'),
                         ],
                       ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  double _calculateUsedAmount(List<TransactionModel> transactions, BudgetModel budget) {
    final parts = budget.month.split('-');
    if (parts.length != 2) return 0.0;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return 0.0;

    return transactions
        .where(
          (tx) =>
              tx.categoryId == budget.categoryId &&
              tx.categoryType == 'expense' &&
              tx.date.year == year &&
              tx.date.month == month,
        )
        .fold(0.0, (sum, tx) => sum + tx.amount.abs());
  }
}
