import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/repositories/wallets_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../core/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsyncValue = ref.watch(walletsProvider);
    final transactionsAsyncValue = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artha Budget'),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalBalanceCard(context, walletsAsyncValue),
            const SizedBox(height: 24),
            Text(
              'Expenses by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildExpenseChart(context, transactionsAsyncValue),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRecentTransactions(context, transactionsAsyncValue),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(
    BuildContext context,
    AsyncValue walletsAsyncValue,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: walletsAsyncValue.when(
          data: (wallets) {
            final totalBalance = wallets.fold(
              0.0,
              (sum, wallet) => sum + wallet.balance,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyUtils.formatRupiah(totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, _) => Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseChart(
    BuildContext context,
    AsyncValue transactionsAsyncValue,
  ) {
    return SizedBox(
      height: 200,
      child: transactionsAsyncValue.when(
        data: (transactions) {
          // In a real app, group by category ID, join with Category name, etc.
          // For now, doing a simple map for demo purposes.
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions yet'));
          }

          return PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.red,
                  value: 40,
                  title: 'Food',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.blue,
                  value: 30,
                  title: 'Transport',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: 15,
                  title: 'Bills',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: 15,
                  title: 'Other',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Error loading chart'),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    AsyncValue transactionsAsyncValue,
  ) {
    return transactionsAsyncValue.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No recent transactions')),
          );
        }

        // Take top 5
        final recent = transactions.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final tx = recent[index];
            // Mocking expense/income for UI demo based on amount sign
            final isExpense =
                tx.categoryType ==
                'expense'; // Since drift currently doesn't store type locally directly on tx

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isExpense
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                child: FaIcon(
                  isExpense
                      ? FontAwesomeIcons.arrowTrendDown
                      : FontAwesomeIcons.arrowTrendUp,
                  color: isExpense ? Colors.red : Colors.green,
                ),
              ),
              title: Text(tx.note.isNotEmpty ? tx.note : 'Transaction'),
              subtitle: Text(DateUtilsApp.formatDate(tx.date)),
              trailing: Text(
                '${isExpense ? '-' : '+'}${CurrencyUtils.formatRupiah(tx.amount)}',
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error loading transactions'),
    );
  }
}
