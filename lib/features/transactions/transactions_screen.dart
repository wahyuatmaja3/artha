import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../core/utils/formatters.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: transactionsAsyncValue.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          // For a real app, we'd group transactions by Date using a map.
          // Here, we just list them vertically.
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length + 1,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildExpenseChart(transactions);
              }

              final tx = transactions[index - 1];
              final isExpense = tx.categoryType == 'expense';
              final title = tx.categoryName?.isNotEmpty == true
                  ? tx.categoryName!
                  : 'Uncategorized';
              final subtitle = tx.note.isNotEmpty
                  ? '${DateUtilsApp.formatDate(tx.date)} • ${tx.note}'
                  : DateUtilsApp.formatDate(tx.date);
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                  child: FaIcon(
                    isExpense
                        ? FontAwesomeIcons.bowlFood
                        : FontAwesomeIcons.moneyBillWave,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: Text(
                  '${isExpense ? '-' : '+'}${CurrencyUtils.formatRupiah(tx.amount)}',
                  style: TextStyle(
                    color: isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // View/Edit transaction details
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildExpenseChart(List transactions) {
    final expenseByCategory = <String, double>{};
    for (final tx in transactions) {
      if (tx.categoryType != 'expense') continue;
      final category =
          (tx.categoryName == null || tx.categoryName!.isEmpty) ? 'Lainnya' : tx.categoryName!;
      expenseByCategory[category] = (expenseByCategory[category] ?? 0) + tx.amount.abs();
    }

    if (expenseByCategory.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Belum ada data pengeluaran')),
      );
    }

    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < top.length; i++) {
      final item = top[i];
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: item.value,
          title: item.key,
          radius: 52,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 42,
          sections: sections,
        ),
      ),
    );
  }
}
