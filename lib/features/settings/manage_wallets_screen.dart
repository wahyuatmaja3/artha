import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/wallets_repository.dart';
import '../../domain/models/models.dart';

class ManageWalletsScreen extends ConsumerWidget {
  const ManageWalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Wallets')),
      body: walletsAsync.when(
        data: (wallets) => _WalletsList(wallets: wallets),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWalletDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Wallet'),
      ),
    );
  }

  Future<void> _showAddWalletDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '0');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama wallet'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Saldo awal'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final initialBalance =
                    double.tryParse(amountController.text.trim()) ?? 0;

                if (name.isEmpty) return;

                await ref
                    .read(walletsRepositoryProvider)
                    .addWallet(name, initialBalance);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class _WalletsList extends ConsumerWidget {
  const _WalletsList({required this.wallets});

  final List<WalletModel> wallets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (wallets.isEmpty) {
      return const Center(child: Text('Belum ada wallet'));
    }

    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ListView.separated(
      itemCount: wallets.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final wallet = wallets[index];

        return ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: Text(wallet.name),
          subtitle: Text(currency.format(wallet.balance)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, wallet),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WalletModel wallet,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus wallet?'),
            content: Text('Wallet "${wallet.name}" akan dihapus.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    await ref.read(walletsRepositoryProvider).deleteWallet(wallet.id);
  }
}
