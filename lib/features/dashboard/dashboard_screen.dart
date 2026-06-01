import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app.dart';
import '../../core/ui/neo_widgets.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/budgets_repository.dart';
import '../../data/repositories/investment_plans_repository.dart';
import '../../data/repositories/savings_goals_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/repositories/wallets_repository.dart';
import '../../domain/models/models.dart';

final recurringActivitiesProvider = FutureProvider<List<_RecurringActivity>>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.customSelect(
    '''
    SELECT rr.amount, rr.type, rr.note, rr.frequency, rr.next_run_at, c.name AS category_name
    FROM recurring_rules rr
    LEFT JOIN categories c ON c.id = rr.category_id
    WHERE rr.is_active = 1
    ORDER BY rr.next_run_at ASC
    LIMIT 5
    ''',
  ).get();

  return rows.map((row) {
    final data = row.data;
    return _RecurringActivity(
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: (data['type'] as String?) ?? 'expense',
      note: (data['note'] as String?) ?? '',
      frequency: (data['frequency'] as String?) ?? '-',
      nextRunAt: DateTime.tryParse((data['next_run_at'] as String?) ?? '') ?? DateTime.now(),
      categoryName: (data['category_name'] as String?) ?? 'Transaksi berulang',
    );
  }).toList();
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _pickMonthYear(BuildContext context) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Pilih Bulan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: tempYear,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(DateTime(tempYear, tempMonth)),
                          child: const Text('Pilih'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
    final transactionsAsync = ref.watch(transactionsProvider);
    final budgetsAsync = ref.watch(budgetsProvider);
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final plansAsync = ref.watch(investmentPlansProvider);
    final recurringAsync = ref.watch(recurringActivitiesProvider);
    final walletsAsync = ref.watch(walletsProvider);

    final monthLabel = DateUtilsApp.formatMonth(_selectedMonth);

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
      body: transactionsAsync.when(
        data: (transactions) {
          final dashboardData = _DashboardData.build(
            transactions: transactions,
            budgets: budgetsAsync.maybeWhen(data: (items) => items, orElse: () => const <BudgetModel>[]),
            goals: goalsAsync.maybeWhen(data: (items) => items, orElse: () => const <SavingsGoalModel>[]),
            plans: plansAsync.maybeWhen(data: (items) => items, orElse: () => const <InvestmentPlanModel>[]),
            wallets: walletsAsync.maybeWhen(data: (items) => items, orElse: () => const <WalletModel>[]),
            recurring: recurringAsync.maybeWhen(data: (items) => items, orElse: () => const <_RecurringActivity>[]),
            selectedMonth: _selectedMonth,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, dashboardData),
                const SizedBox(height: 24),
                const NeoSectionTitle('Ringkasan Cepat'),
                const SizedBox(height: 12),
                _buildQuickStats(dashboardData),
                const SizedBox(height: 24),
                const NeoSectionTitle('Visual'),
                const SizedBox(height: 12),
                _buildCategoryChart(context, dashboardData),
                const SizedBox(height: 12),
                _buildTrendChart(context, dashboardData),
                const SizedBox(height: 24),
                const NeoSectionTitle('Progress'),
                const SizedBox(height: 12),
                _buildProgressCards(context, dashboardData),
                const SizedBox(height: 24),
                const NeoSectionTitle('Aktivitas'),
                const SizedBox(height: 12),
                _buildActivityCards(context, dashboardData),
                const SizedBox(height: 24),
                const NeoSectionTitle('Recent Transactions'),
                const SizedBox(height: 16),
                _buildRecentTransactions(context, dashboardData.monthTransactions),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, _DashboardData data) {
    final scheme = Theme.of(context).colorScheme;
    return NeoCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sisa budget ${DateUtilsApp.formatMonth(_selectedMonth)}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatRupiah(data.remainingBudget),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _summaryMetric('Pemasukan', data.totalIncome, Colors.greenAccent)),
                const SizedBox(width: 12),
                Expanded(child: _summaryMetric('Pengeluaran', data.totalExpense, Colors.orangeAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatRupiah(value),
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildQuickStats(_DashboardData data) {
    return Row(
      children: [
        Expanded(child: _statCard('Pemasukan', data.totalIncome, Colors.green, FontAwesomeIcons.arrowTrendUp)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Pengeluaran', data.totalExpense, Colors.red, FontAwesomeIcons.arrowTrendDown)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Sisa', data.remainingBudget, Colors.blue, FontAwesomeIcons.wallet)),
      ],
    );
  }

  Widget _statCard(String label, double amount, Color color, IconData icon) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, color: color, size: 16),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            CurrencyUtils.formatRupiah(amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, _DashboardData data) {
    final entries = data.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    final colors = [Colors.red, Colors.orange, Colors.amber, Colors.blue, Colors.purple];

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengeluaran per kategori', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (top.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Belum ada pengeluaran bulan ini')),
            )
          else
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 42,
                  sections: List.generate(top.length, (index) {
                    final item = top[index];
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: item.value,
                      title: '${(item.value / data.totalExpense * 100).toStringAsFixed(0)}%',
                      radius: 56,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    );
                  }),
                ),
              ),
            ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(top.length, (index) {
              final item = top[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[index % colors.length], borderRadius: BorderRadius.circular(99))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.key)),
                    Text(CurrencyUtils.formatRupiah(item.value)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context, _DashboardData data) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tren 7 / 30 hari', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text('${(value / 1000).round()}k', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 5,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.trend7.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value)).toList(),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: data.trend30.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              _LegendDot(color: Colors.orange, label: '7 hari'),
              SizedBox(width: 12),
              _LegendDot(color: Colors.blue, label: '30 hari'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(BuildContext context, _DashboardData data) {
    return Column(
      children: [
        _progressCard(
          context,
          label: 'Goals',
          progress: data.goalProgress,
          subtitle: data.goals.isEmpty ? 'Belum ada goal' : '${data.completedGoals}/${data.goals.length} goal on track',
          status: data.goals.isEmpty ? 'Kosong' : (data.goalProgress >= 0.8 ? 'Bagus' : 'Perlu dorongan'),
          color: Colors.green,
          onTap: () => AppShellController.of(context).goToTab(2),
        ),
        const SizedBox(height: 10),
        _progressCard(
          context,
          label: 'Invest',
          progress: data.investmentProgress,
          subtitle: data.plans.isEmpty ? 'Belum ada rencana investasi' : '${data.activePlans}/${data.plans.length} plan aktif',
          status: data.plans.isEmpty ? 'Kosong' : (data.investmentProgress >= 0.75 ? 'Stabil' : 'Bangun portofolio'),
          color: Colors.blue,
          onTap: () => AppShellController.of(context).goToTab(3),
        ),
        const SizedBox(height: 10),
        _progressCard(
          context,
          label: 'Budget',
          progress: data.budgetProgress,
          subtitle: data.budgets.isEmpty ? 'Belum ada budget bulan ini' : '${data.warningBudgets} kategori hampir over budget',
          status: data.budgets.isEmpty
              ? 'Kosong'
              : (data.budgetProgress >= 1
                  ? 'Over budget'
                  : (data.warningBudgets > 0 ? 'Hampir over budget' : 'Aman')),
          color: data.budgetProgress >= 1 ? Colors.red : (data.warningBudgets > 0 ? Colors.orange : Colors.green),
          onTap: () => AppShellController.of(context).goToTab(4),
        ),
      ],
    );
  }

  Widget _progressCard(
    BuildContext context, {
    required String label,
    required double progress,
    required String subtitle,
    required String status,
    required Color color,
    required VoidCallback onTap,
  }) {
    final safeProgress = progress.clamp(0, 1).toDouble();
    return NeoCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: safeProgress, minHeight: 8, color: color, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActivityCards(BuildContext context, _DashboardData data) {
    return Column(
      children: [
        _activityCard(
          icon: FontAwesomeIcons.clock,
          title: 'Tagihan jatuh tempo',
          body: data.upcomingBills.isEmpty ? 'Belum ada tagihan dalam 7 hari' : data.upcomingBills.join('\n'),
          color: Colors.red,
        ),
        const SizedBox(height: 10),
        _activityCard(
          icon: FontAwesomeIcons.arrowsRotate,
          title: 'Transaksi berulang berikutnya',
          body: data.recurringItems.isEmpty ? 'Belum ada transaksi berulang aktif' : data.recurringItems.join('\n'),
          color: Colors.blue,
        ),
        const SizedBox(height: 10),
        _activityCard(
          icon: FontAwesomeIcons.lightbulb,
          title: 'Insight otomatis',
          body: data.insights.isEmpty ? 'Belum cukup data untuk insight' : data.insights.join('\n'),
          color: Colors.amber.shade800,
        ),
      ],
    );
  }

  Widget _activityCard({required IconData icon, required String title, required String body, required Color color}) {
    return NeoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: FaIcon(icon, color: color, size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<TransactionModel> monthTransactions) {
    if (monthTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No recent transactions')),
      );
    }

    final recent = monthTransactions.take(5).toList();

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final tx = recent[index];
            final isExpense = tx.categoryType == 'expense';

            return NeoCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
                  child: FaIcon(
                    isExpense ? FontAwesomeIcons.arrowTrendDown : FontAwesomeIcons.arrowTrendUp,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(tx.note.isNotEmpty ? tx.note : (tx.categoryName ?? 'Transaction')),
                subtitle: Text(DateUtilsApp.formatDate(tx.date)),
                trailing: Text(
                  '${isExpense ? '-' : '+'}${CurrencyUtils.formatRupiah(tx.amount)}',
                  style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                ),
                onLongPress: () async {
                  await ref.read(transactionsRepositoryProvider).deleteTransaction(
                        tx.id,
                        tx.walletId,
                        tx.amount,
                        tx.categoryType ?? 'expense',
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaksi dihapus')),
                  );
                },
              ),
            );
          },
        ),
        if (monthTransactions.length > 5)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => AppShellController.of(context).goToTab(1),
              child: const Text('Load more'),
            ),
          ),
      ],
    );
  }

  Widget _buildShortcutCards(BuildContext context) {
    return Column(
      children: [
        _buildShortcutTile(
          context,
          icon: FontAwesomeIcons.bullseye,
          label: 'Goals',
          onTap: () => AppShellController.of(context).goToTab(2),
        ),
        const SizedBox(height: 8),
        _buildShortcutTile(
          context,
          icon: FontAwesomeIcons.chartLine,
          label: 'Invest',
          onTap: () => AppShellController.of(context).goToTab(3),
        ),
        const SizedBox(height: 8),
        _buildShortcutTile(
          context,
          icon: FontAwesomeIcons.chartPie,
          label: 'Budget',
          onTap: () => AppShellController.of(context).goToTab(4),
        ),
      ],
    );
  }

  Widget _buildShortcutTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return NeoCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: FaIcon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99))),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _RecurringActivity {
  const _RecurringActivity({
    required this.amount,
    required this.type,
    required this.note,
    required this.frequency,
    required this.nextRunAt,
    required this.categoryName,
  });

  final double amount;
  final String type;
  final String note;
  final String frequency;
  final DateTime nextRunAt;
  final String categoryName;
}

class _DashboardData {
  const _DashboardData({
    required this.monthTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBudget,
    required this.expenseByCategory,
    required this.trend7,
    required this.trend30,
    required this.goals,
    required this.plans,
    required this.budgets,
    required this.goalProgress,
    required this.investmentProgress,
    required this.budgetProgress,
    required this.completedGoals,
    required this.activePlans,
    required this.warningBudgets,
    required this.upcomingBills,
    required this.recurringItems,
    required this.insights,
  });

  final List<TransactionModel> monthTransactions;
  final double totalIncome;
  final double totalExpense;
  final double remainingBudget;
  final Map<String, double> expenseByCategory;
  final List<double> trend7;
  final List<double> trend30;
  final List<SavingsGoalModel> goals;
  final List<InvestmentPlanModel> plans;
  final List<BudgetModel> budgets;
  final double goalProgress;
  final double investmentProgress;
  final double budgetProgress;
  final int completedGoals;
  final int activePlans;
  final int warningBudgets;
  final List<String> upcomingBills;
  final List<String> recurringItems;
  final List<String> insights;

  static _DashboardData build({
    required List<TransactionModel> transactions,
    required List<BudgetModel> budgets,
    required List<SavingsGoalModel> goals,
    required List<InvestmentPlanModel> plans,
    required List<WalletModel> wallets,
    required List<_RecurringActivity> recurring,
    required DateTime selectedMonth,
  }) {
    final monthStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final monthEnd = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);
    final previousMonthStart = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final previousMonthEnd = DateTime(selectedMonth.year, selectedMonth.month, 0, 23, 59, 59);
    final now = DateTime.now();
    final last30Start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
    final last7Start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final monthTransactions = transactions
        .where((tx) => !tx.date.isBefore(monthStart) && !tx.date.isAfter(monthEnd))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final previousMonthTransactions = transactions
        .where((tx) => !tx.date.isBefore(previousMonthStart) && !tx.date.isAfter(previousMonthEnd))
        .toList();

    final totalIncome = monthTransactions
        .where((tx) => tx.categoryType != 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = monthTransactions
        .where((tx) => tx.categoryType == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final expenseByCategory = <String, double>{};
    for (final tx in monthTransactions.where((item) => item.categoryType == 'expense')) {
      final key = tx.categoryName ?? 'Lainnya';
      expenseByCategory.update(key, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    final trend30 = List<double>.generate(30, (index) {
      final day = DateTime(last30Start.year, last30Start.month, last30Start.day + index);
      return transactions
          .where(
            (tx) =>
                tx.categoryType == 'expense' &&
                tx.date.year == day.year &&
                tx.date.month == day.month &&
                tx.date.day == day.day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);
    });

    final trend7 = List<double>.generate(30, (index) {
      if (index < 23) return 0;
      final offset = index - 23;
      final day = DateTime(last7Start.year, last7Start.month, last7Start.day + offset);
      return transactions
          .where(
            (tx) =>
                tx.categoryType == 'expense' &&
                tx.date.year == day.year &&
                tx.date.month == day.month &&
                tx.date.day == day.day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);
    });

    final monthKey = '${selectedMonth.year.toString().padLeft(4, '0')}-${selectedMonth.month.toString().padLeft(2, '0')}';
    final currentBudgets = budgets.where((budget) => budget.month == monthKey).toList();
    final totalBudgetLimit = currentBudgets.fold(0.0, (sum, budget) => sum + budget.limitAmount);
    final totalBudgetUsed = currentBudgets.fold(0.0, (sum, budget) => sum + budget.usedAmount);
    final budgetProgress = totalBudgetLimit <= 0 ? 0.0 : totalBudgetUsed / totalBudgetLimit;
    final warningBudgets = currentBudgets.where((budget) => budget.limitAmount > 0 && (budget.usedAmount / budget.limitAmount) >= 0.9).length;

    final goalProgress = goals.isEmpty ? 0.0 : goals.fold(0.0, (sum, goal) => sum + goal.progress) / goals.length;
    final investmentProgress = plans.isEmpty ? 0.0 : plans.fold(0.0, (sum, plan) => sum + plan.progress) / plans.length;
    final completedGoals = goals.where((goal) => goal.status == 'Completed').length;
    final activePlans = plans.where((plan) => plan.status == 'Active').length;

    final upcomingBills = recurring
        .where((item) => item.type == 'expense' && !item.nextRunAt.isBefore(now) && item.nextRunAt.isBefore(now.add(const Duration(days: 7))))
        .take(3)
        .map((item) => '${item.note.isNotEmpty ? item.note : item.categoryName} • ${DateUtilsApp.formatDate(item.nextRunAt)}')
        .toList();

    final recurringItems = recurring
        .take(3)
        .map(
          (item) =>
              '${item.note.isNotEmpty ? item.note : item.categoryName} • ${item.frequency} • ${CurrencyUtils.formatRupiah(item.amount)}',
        )
        .toList();

    final insights = <String>[];
    final currentFood = expenseByCategory.entries
        .where((entry) => entry.key.toLowerCase().contains('makan'))
        .fold(0.0, (sum, entry) => sum + entry.value);
    final previousFood = previousMonthTransactions
        .where((tx) => tx.categoryType == 'expense' && (tx.categoryName ?? '').toLowerCase().contains('makan'))
        .fold(0.0, (sum, tx) => sum + tx.amount);
    if (currentFood > 0 && previousFood > 0) {
      final diff = ((currentFood - previousFood) / previousFood) * 100;
      final direction = diff >= 0 ? 'naik' : 'turun';
      insights.add('Makan $direction ${diff.abs().toStringAsFixed(0)}% dari bulan lalu');
    }
    if (totalIncome > 0) {
      final savingRate = ((totalIncome - totalExpense) / totalIncome) * 100;
      insights.add('Saving rate bulan ini ${savingRate.clamp(-999, 999).toStringAsFixed(0)}%');
    }
    final topCategory = expenseByCategory.entries.isEmpty
        ? null
        : expenseByCategory.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (topCategory != null) {
      insights.add('${topCategory.key} jadi pengeluaran terbesar bulan ini');
    }

    final totalWalletBalance = wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
    final remainingBudget = totalBudgetLimit > 0 ? totalBudgetLimit - totalBudgetUsed : totalWalletBalance + totalIncome - totalExpense;

    return _DashboardData(
      monthTransactions: monthTransactions,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      remainingBudget: remainingBudget,
      expenseByCategory: expenseByCategory,
      trend7: trend7,
      trend30: trend30,
      goals: goals,
      plans: plans,
      budgets: currentBudgets,
      goalProgress: goalProgress,
      investmentProgress: investmentProgress,
      budgetProgress: budgetProgress,
      completedGoals: completedGoals,
      activePlans: activePlans,
      warningBudgets: warningBudgets,
      upcomingBills: upcomingBills,
      recurringItems: recurringItems,
      insights: insights.take(3).toList(),
    );
  }
}
