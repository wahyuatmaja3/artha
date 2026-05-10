import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/repositories/budgets_repository.dart';
import '../../core/utils/formatters.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsyncValue = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            onPressed: () {
              // Add new budget limit
            },
          ),
        ],
      ),
      body: budgetsAsyncValue.when(
        data: (budgets) {
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
              final progress = budget.usedAmount / budget.limitAmount;
              final color = progress > 0.9 ? Colors.red : (progress > 0.7 ? Colors.orange : Colors.green);

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
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
                          Text('Spent: ${CurrencyUtils.formatRupiah(budget.usedAmount)}'),
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
}
