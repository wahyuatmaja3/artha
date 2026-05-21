import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils/formatters.dart';
import '../../core/ui/neo_widgets.dart';
import '../../core/ui/neo_text_field.dart';
import '../../data/repositories/investment_plans_repository.dart';
import '../../data/repositories/wallets_repository.dart';
import '../../domain/models/models.dart';

double? _parseCurrencyAmount(String input) {
  final normalized = input.trim().replaceAll('Rp', '').replaceAll('rp', '').replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(normalized);
}

class InvestmentPlansScreen extends ConsumerWidget {
  const InvestmentPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(investmentPlansProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Plan'),
        actions: [
          IconButton(
            onPressed: walletsAsync.maybeWhen(
              data: (wallets) => wallets.isEmpty ? null : () => _showAddPlanSheet(context, ref, wallets),
              orElse: () => null,
            ),
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
        ],
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) return const Center(child: Text('Belum ada investment plan.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) => _PlanCard(plan: plans[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showAddPlanSheet(BuildContext context, WidgetRef ref, List<WalletModel> wallets) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final allocationController = TextEditingController();
    final noteController = TextEditingController();
    String walletId = wallets.first.id;
    String type = 'Saham';
    String frequency = 'monthly';
    DateTime startDate = DateTime.now();
    bool autoInvestEnabled = false;

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
                Text('Tambah Investment Plan', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                NeoTextFieldFrame(child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama plan'))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Jenis investasi'),
                  items: const [
                    DropdownMenuItem(value: 'Saham', child: Text('Saham')),
                    DropdownMenuItem(value: 'Crypto', child: Text('Crypto')),
                    DropdownMenuItem(value: 'Reksadana', child: Text('Reksadana')),
                    DropdownMenuItem(value: 'Emas', child: Text('Emas')),
                  ],
                  onChanged: (value) {
                    if (value != null) setStateDialog(() => type = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: walletId,
                  decoration: const InputDecoration(labelText: 'Akun aset terkait'),
                  items: wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                  onChanged: (value) {
                    if (value != null) setStateDialog(() => walletId = value);
                  },
                ),
                const SizedBox(height: 12),
                NeoTextFieldFrame(child: TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target nominal',
                    hintText: 'contoh: 10000000',
                    prefixText: 'Rp ',
                  ),
                )),
                const SizedBox(height: 12),
                NeoTextFieldFrame(child: TextField(
                  controller: allocationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Alokasi dana berkala',
                    hintText: 'contoh: 500000',
                    prefixText: 'Rp ',
                  ),
                )),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: frequency,
                  decoration: const InputDecoration(labelText: 'Frekuensi investasi'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Harian')),
                    DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                    DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                    DropdownMenuItem(value: 'yearly', child: Text('Tahunan')),
                  ],
                  onChanged: (value) {
                    if (value != null) setStateDialog(() => frequency = value);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal mulai'),
                  subtitle: Text(DateUtilsApp.formatDate(startDate)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (picked != null) setStateDialog(() => startDate = picked);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto investasi sesuai frekuensi'),
                  subtitle: const Text('Sistem akan input investasi otomatis'),
                  value: autoInvestEnabled,
                  onChanged: (value) => setStateDialog(() => autoInvestEnabled = value),
                ),
                NeoTextFieldFrame(child: TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Catatan'))),
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
                final target = _parseCurrencyAmount(targetController.text);
                final allocation = _parseCurrencyAmount(allocationController.text);
                if (nameController.text.trim().isEmpty || target == null || target <= 0 || allocation == null || allocation <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi field dengan nominal yang valid.')),
                  );
                  return;
                }
                await ref.read(investmentPlansRepositoryProvider).addPlan(
                      walletId: walletId,
                      name: nameController.text.trim(),
                      investmentType: type,
                      targetAmount: target,
                      periodicAllocation: allocation,
                      frequency: frequency,
                      startDate: startDate,
                      note: noteController.text.trim(),
                      autoInvestEnabled: autoInvestEnabled,
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

class _PlanCard extends ConsumerWidget {
  final InvestmentPlanModel plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.trending_up)),
                const SizedBox(width: 10),
                Expanded(child: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Chip(label: Text(plan.status)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: plan.progress, minHeight: 8),
            const SizedBox(height: 8),
            Text('Jenis: ${plan.investmentType}'),
            Text('Total investasi: ${CurrencyUtils.formatRupiah(plan.currentAmount)}'),
            Text('Target: ${CurrencyUtils.formatRupiah(plan.targetAmount)}'),
            Text('Alokasi ${plan.frequency}: ${CurrencyUtils.formatRupiah(plan.periodicAllocation)}'),
            Text('Estimasi selesai: ${plan.estimatedFinishDate == null ? '-' : DateUtilsApp.formatDate(plan.estimatedFinishDate!)}'),
            Text('Auto invest: ${plan.autoInvestEnabled ? 'Aktif' : 'Nonaktif'}'),
            Text('Akun: ${plan.walletName ?? '-'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _showContributionDialog(context, ref, true),
                  child: const Text('+ Investasi'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showContributionDialog(context, ref, false),
                  child: const Text('- Tarik'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.read(investmentPlansRepositoryProvider).setPaused(plan.id, !plan.isPaused),
                  icon: Icon(plan.isPaused ? Icons.play_arrow : Icons.pause),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContributionDialog(BuildContext context, WidgetRef ref, bool add) async {
    final controller = TextEditingController();
    final presets = [100000.0, 250000.0, 500000.0, 1000000.0, 2500000.0];
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
            Text(add ? 'Tambah Investasi' : 'Tarik Investasi', style: Theme.of(context).textTheme.titleLarge),
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                hintText: 'contoh: 250000',
                prefixText: 'Rp ',
              ),
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
                      final amount = _parseCurrencyAmount(controller.text);
                      if (amount == null || amount <= 0) return;
                      await ref.read(investmentPlansRepositoryProvider).addContribution(plan.id, add ? amount : -amount);
                      if (!context.mounted) return;
                      Navigator.of(sheetContext).pop();
                    },
                    child: Text(add ? 'Tambah' : 'Tarik'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
