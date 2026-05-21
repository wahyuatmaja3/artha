import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils/formatters.dart';
import '../../core/ui/neo_widgets.dart';
import '../../core/ui/neo_text_field.dart';
import '../../data/repositories/savings_goals_repository.dart';
import '../../data/repositories/wallets_repository.dart';
import '../../domain/models/models.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goal'),
        actions: [
          IconButton(
            onPressed: walletsAsync.maybeWhen(
              data: (wallets) => wallets.isEmpty
                  ? null
                  : () => _showAddGoalSheet(context, ref, wallets),
              orElse: () => null,
            ),
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada savings goal.\nTap + untuk membuat goal baru.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) => _GoalCard(goal: goals[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showAddGoalSheet(BuildContext context, WidgetRef ref, List<WalletModel> wallets) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    String selectedWalletId = wallets.first.id;
    DateTime? selectedDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tambah Goal', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                NeoTextFieldFrame(child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama target', hintText: 'contoh: Dana Darurat'))),
                const SizedBox(height: 12),
                NeoTextFieldFrame(
                  child: TextField(
                    controller: targetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Target nominal', hintText: 'contoh: 10000000'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedWalletId,
                  decoration: const InputDecoration(labelText: 'Akun penyimpanan'),
                  items: wallets
                      .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setStateDialog(() => selectedWalletId = value);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Target date'),
                  subtitle: Text(selectedDate == null ? 'Opsional' : DateUtilsApp.formatDate(selectedDate!)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setStateDialog(() => selectedDate = picked);
                  },
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim());
                if (name.isEmpty || target == null || target <= 0) return;
                await ref.read(savingsGoalsRepositoryProvider).addGoal(
                      walletId: selectedWalletId,
                      name: name,
                      targetAmount: target,
                      targetDate: selectedDate,
                      priority: 'medium',
                      description: '',
                      icon: '🎯',
                    );
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                        },
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final SavingsGoalModel goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressColor = goal.progress >= 1 ? Colors.green : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(goal.icon)),
                const SizedBox(width: 10),
                Expanded(child: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Chip(label: Text(goal.status)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: goal.progress, color: progressColor, minHeight: 8),
            const SizedBox(height: 10),
            Text('Terkumpul: ${CurrencyUtils.formatRupiah(goal.currentAmount)}'),
            Text('Target: ${CurrencyUtils.formatRupiah(goal.targetAmount)}'),
            Text('Sisa: ${CurrencyUtils.formatRupiah(goal.remainingAmount)}'),
            Text('Progress: ${(goal.progress * 100).toStringAsFixed(1)}%'),
            Text('Estimasi tercapai: ${_estimateReached(goal)}'),
            Text('Kebutuhan/bulan: ${CurrencyUtils.formatRupiah(_monthlyNeed(goal))}'),
            if (goal.targetDate != null) Text('Target date: ${DateUtilsApp.formatDate(goal.targetDate!)}'),
            Text('Akun: ${goal.walletName ?? '-'}'),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _showContributionDialog(context, ref, goal, true),
                  child: const Text('+ Dana'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showContributionDialog(context, ref, goal, false),
                  child: const Text('- Dana'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.read(savingsGoalsRepositoryProvider).setPaused(goal.id, !goal.isPaused),
                  icon: Icon(goal.isPaused ? Icons.play_arrow : Icons.pause),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContributionDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal, bool add) async {
    final controller = TextEditingController();
    final noteController = TextEditingController();
    final presets = [50000.0, 100000.0, 250000.0, 500000.0, 1000000.0];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(add ? 'Tambah Dana Goal' : 'Kurangi Dana Goal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              goal.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((amount) {
                return ActionChip(
                  label: Text(CurrencyUtils.formatRupiah(amount)),
                  onPressed: () => controller.text = amount.toStringAsFixed(0),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            NeoTextFieldFrame(child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp '),
            )),
            const SizedBox(height: 10),
            NeoTextFieldFrame(child: TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final amount = double.tryParse(controller.text.trim());
                      if (amount == null || amount <= 0) return;
                      await ref.read(savingsGoalsRepositoryProvider).addContribution(goal.id, add ? amount : -amount);
                      if (!context.mounted) return;
                      Navigator.of(sheetContext).pop();
                    },
                    child: Text(add ? 'Tambah' : 'Kurangi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _estimateReached(SavingsGoalModel goal) {
    if (goal.currentAmount >= goal.targetAmount) return 'Sudah tercapai';
    if (goal.targetDate == null) return 'Belum bisa dihitung';
    final need = _monthlyNeed(goal);
    if (need <= 0) return 'Belum bisa dihitung';
    return DateUtilsApp.formatDate(goal.targetDate!);
  }

  double _monthlyNeed(SavingsGoalModel goal) {
    if (goal.currentAmount >= goal.targetAmount) return 0;
    if (goal.targetDate == null) return 0;
    final now = DateTime.now();
    final months = ((goal.targetDate!.year - now.year) * 12) + (goal.targetDate!.month - now.month);
    if (months <= 0) return goal.remainingAmount;
    return goal.remainingAmount / months;
  }
}
