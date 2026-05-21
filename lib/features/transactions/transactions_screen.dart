import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../core/utils/formatters.dart';
import '../../core/ui/neo_widgets.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _selectedCategoryId = 'all';
  String _selectedType = 'all';

  Future<void> _openFilterSheet(BuildContext context) async {
    final categories = ref.read(categoriesProvider).maybeWhen(
      data: (items) => items,
      orElse: () => <dynamic>[],
    );
    var tempMonth = _selectedMonth;
    var tempCategory = _selectedCategoryId;
    var tempType = _selectedType;
    final years = List<int>.generate(81, (index) => 2020 + index);
    final monthNames = const [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Transaksi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Periode'),
                subtitle: Text(DateUtilsApp.formatMonth(tempMonth)),
                trailing: const Icon(Icons.calendar_month),
                onTap: null,
              ),
              DropdownButtonFormField<int>(
                initialValue: tempMonth.year,
                decoration: const InputDecoration(labelText: 'Tahun'),
                items: years.map((y) => DropdownMenuItem<int>(value: y, child: Text(y.toString()))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setSheetState(() => tempMonth = DateTime(value, tempMonth.month));
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(12, (index) {
                  final month = index + 1;
                  final selected = tempMonth.month == month;
                  return ChoiceChip(
                    label: Text(monthNames[index]),
                    selected: selected,
                    onSelected: (_) => setSheetState(() => tempMonth = DateTime(tempMonth.year, month)),
                  );
                }),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: tempCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Semua Kategori')),
                  ...categories.map((c) => DropdownMenuItem<String>(value: c.id, child: Text('${c.icon} ${c.name}'))),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setSheetState(() => tempCategory = value);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: tempType,
                decoration: const InputDecoration(labelText: 'Tipe'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Semua Tipe')),
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setSheetState(() => tempType = value);
                },
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
                        _selectedCategoryId = 'all';
                        _selectedType = 'all';
                      });
                      Navigator.pop(sheetContext, true);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedMonth = tempMonth;
                        _selectedCategoryId = tempCategory;
                        _selectedType = tempType;
                      });
                      Navigator.pop(sheetContext, true);
                    },
                    child: const Text('Terapkan'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionsProvider);
    final monthLabel = DateUtilsApp.formatMonth(_selectedMonth);
    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filter),
            onPressed: () => _openFilterSheet(context),
          ),
        ],
      ),
      body: transactionsAsyncValue.when(
        data: (transactions) {
          final filtered = transactions.where((tx) {
            final inMonth = !tx.date.isBefore(monthStart) && !tx.date.isAfter(monthEnd);
            if (!inMonth) return false;
            if (_selectedCategoryId != 'all' && tx.categoryId != _selectedCategoryId) {
              return false;
            }
            if (_selectedType == 'all') return true;
            return tx.categoryType == _selectedType;
          }).toList();

          final income = filtered.where((tx) => tx.categoryType == 'income').fold(0.0, (sum, tx) => sum + tx.amount.abs());
          final expense = filtered.where((tx) => tx.categoryType == 'expense').fold(0.0, (sum, tx) => sum + tx.amount.abs());
          final net = income - expense;

          if (filtered.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: filtered.length + 2,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(monthLabel, style: Theme.of(context).textTheme.titleMedium),
                        Text('Kategori: ${_selectedCategoryId == 'all' ? 'Semua' : 'Custom'}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _metricCard('Income', income, Colors.green)),
                        const SizedBox(width: 8),
                        Expanded(child: _metricCard('Expense', expense, Colors.red)),
                        const SizedBox(width: 8),
                        Expanded(child: _metricCard('Net', net, net >= 0 ? Colors.blue : Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildExpenseChart(filtered),
                  ],
                );
              }
              if (index == 1) return const SizedBox.shrink();

              final tx = filtered[index - 2];
              final isExpense = tx.categoryType == 'expense';
              final title = tx.categoryName?.isNotEmpty == true
                  ? tx.categoryName!
                  : 'Uncategorized';
              final subtitle = tx.note.isNotEmpty
                  ? '${DateUtilsApp.formatDate(tx.date)} • ${tx.note}'
                  : DateUtilsApp.formatDate(tx.date);
              
              return NeoCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
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
              ));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _metricCard(String title, double value, Color accent) {
    return NeoCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.formatRupiah(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 12),
          ),
        ],
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
