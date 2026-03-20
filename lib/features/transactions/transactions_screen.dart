import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            icon: const Icon(Icons.filter_list),
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
              final isExpense = tx.amount > 0; // Simplified assumption for demo
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                  child: Icon(
                    isExpense ? Icons.fastfood : Icons.attach_money,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(tx.note.isNotEmpty ? tx.note : 'Uncategorized'),
                subtitle: Text(DateUtilsApp.formatDate(tx.date)),
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
