import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../core/utils/formatters.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _pickMonthYear(BuildContext context) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        var tempYear = _selectedMonth.year;
        var tempMonth = _selectedMonth.month;
        final years = List<int>.generate(81, (index) => 2020 + index);
        final monthNames = const [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return AlertDialog(
              title: const Text('Pilih Bulan'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: tempYear,
                      decoration: const InputDecoration(labelText: 'Tahun'),
                      items: years
                          .map(
                            (year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => tempYear = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (index) {
                        final month = index + 1;
                        return ChoiceChip(
                          label: Text(monthNames[index].substring(0, 3)),
                          selected: tempMonth == month,
                          onSelected: (_) => setSheetState(() => tempMonth = month),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(
                    DateTime(tempYear, tempMonth),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null) return;
    setState(() => _selectedMonth = DateTime(picked.year, picked.month));
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);
    final monthLabel = DateUtilsApp.formatMonth(_selectedMonth);

    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artha Budget'),
        actions: [
          TextButton.icon(
            onPressed: () => _pickMonthYear(context),
            icon: const Icon(Icons.calendar_month),
            label: Text(monthLabel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalBalanceCard(context, transactionsAsyncValue, monthStart, monthEnd),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildRecentTransactions(
              context,
              transactionsAsyncValue,
              monthStart,
              monthEnd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(
    BuildContext context,
    AsyncValue transactionsAsyncValue,
    DateTime monthStart,
    DateTime monthEnd,
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
        child: transactionsAsyncValue.when(
          data: (transactions) {
            final monthTransactions = transactions
                .where(
                  (tx) =>
                      !tx.date.isBefore(monthStart) && !tx.date.isAfter(monthEnd),
                )
                .toList();

            final totalBalance = monthTransactions.fold(
              0.0,
              (sum, tx) {
                final sign = tx.categoryType == 'expense' ? -1 : 1;
                return sum + (tx.amount * sign);
              },
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo ${DateUtilsApp.formatMonth(_selectedMonth)}',
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

  Widget _buildRecentTransactions(
    BuildContext context,
    AsyncValue transactionsAsyncValue,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    return transactionsAsyncValue.when(
      data: (transactions) {
        final monthTransactions = transactions
            .where(
              (tx) =>
                  !tx.date.isBefore(monthStart) && !tx.date.isAfter(monthEnd),
            )
            .toList();

        if (monthTransactions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No recent transactions')),
          );
        }

        final recent = monthTransactions.take(5).toList();

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
              onLongPress: () async {
                await ref
                    .read(transactionsRepositoryProvider)
                    .deleteTransaction(tx.id, tx.walletId, tx.amount, tx.categoryType ?? 'expense');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi dihapus')),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error loading transactions'),
    );
  }
}
