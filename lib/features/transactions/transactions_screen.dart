import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final tx = transactions[index];
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
}
