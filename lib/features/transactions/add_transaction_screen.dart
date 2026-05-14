import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/repositories/transactions_repository.dart';
import '../../data/repositories/wallets_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/budgets_repository.dart';
import '../../domain/models/models.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _type = 'expense';
  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _amountStr = '0';
  String _note = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showNoteDialog() {
    final noteController = TextEditingController(text: _note);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Catatan'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Tambahkan catatan jika perlu',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _note = noteController.text);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showWalletPicker(List<WalletModel> wallets) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (wallets.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada wallet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan wallet dulu dari menu Manage Wallets agar bisa dipilih untuk transaksi.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const FaIcon(FontAwesomeIcons.check),
                    label: const Text('Mengerti'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final w = wallets[index];
            return ListTile(
              leading: const FaIcon(FontAwesomeIcons.wallet),
              title: Text(w.name),
              subtitle: Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(w.balance),
              ),
              onTap: () {
                setState(() => _selectedWalletId = w.id);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih wallet dan kategori')),
      );
      return;
    }

    final amt = double.tryParse(_amountStr) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    if (_type == 'expense') {
      final budgets = await ref.read(budgetsProvider.future);
      final transactions = await ref.read(transactionsProvider.future);
      final monthKey =
          '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}';

      BudgetModel? matchingBudget;
      for (final budget in budgets) {
        if (budget.categoryId == _selectedCategoryId && budget.month == monthKey) {
          matchingBudget = budget;
          break;
        }
      }

      if (matchingBudget != null) {
        final currentUsed = transactions
            .where(
              (tx) =>
                  tx.categoryId == _selectedCategoryId &&
                  tx.categoryType == 'expense' &&
                  tx.date.year == _selectedDate.year &&
                  tx.date.month == _selectedDate.month,
            )
            .fold(0.0, (sum, tx) => sum + tx.amount.abs());

        final projectedUsed = currentUsed + amt;
        if (projectedUsed > matchingBudget.limitAmount) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaksi ditolak: budget ${matchingBudget.categoryName ?? ''} bulan ini sudah terlewati.',
              ),
            ),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(transactionsRepositoryProvider).addTransaction(
            walletId: _selectedWalletId!,
            categoryId: _selectedCategoryId!,
            amount: amt,
            type: _type,
            date: _selectedDate,
            note: _note,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onNumpadTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == 'C') {
        _amountStr = '0';
      } else if (key == 'OK') {
        _submit();
      } else if (key == '000') {
        if (_amountStr != '0') {
          _amountStr += '000';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          _amountStr += key;
        }
      }
    });
  }

  Widget _buildTopScreen(List<CategoryModel> categories) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
              ButtonSegment(value: 'income', label: Text('Pemasukan')),
            ],
            selected: {_type},
            onSelectionChanged: (value) {
              setState(() {
                _type = value.first;
                _selectedCategoryId = null;
              });
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == _selectedCategoryId;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryId = category.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Text(
                        category.icon.isEmpty ? '?' : category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomScreen(List<WalletModel> wallets) {
    final formattedAmount = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.tryParse(_amountStr) ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: const FaIcon(FontAwesomeIcons.wallet, size: 14),
                  label: Text(
                    wallets.isEmpty
                        ? 'Belum ada wallet'
                        : _selectedWalletId != null
                        ? wallets
                            .firstWhere(
                              (w) => w.id == _selectedWalletId,
                              orElse: () => wallets.first,
                            )
                            .name
                        : 'Pilih Wallet',
                  ),
                  onPressed: wallets.isEmpty
                      ? null
                      : () => _showWalletPicker(wallets),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const FaIcon(FontAwesomeIcons.calendarDay, size: 14),
                  label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                  onPressed: _pickDate,
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const FaIcon(FontAwesomeIcons.noteSticky, size: 14),
                  label: Text(_note.isEmpty ? 'Catatan' : '1 Catatan'),
                  onPressed: _showNoteDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              formattedAmount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3', '⌫'],
      ['4', '5', '6', 'C'],
      ['7', '8', '9', '000'],
      ['', '0', '', 'OK'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildNumpadButton(key),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildNumpadButton(String key) {
    if (key.isEmpty) return const SizedBox.shrink();

    final isAction = key == '⌫' || key == 'C' || key == 'OK';
    final isOk = key == 'OK';

    return Material(
      color: isOk
          ? Theme.of(context).colorScheme.primary
          : isAction
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onNumpadTap(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: isOk && _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  key,
                  style: TextStyle(
                    fontSize: isAction ? 20 : 24,
                    fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
                    color: isOk
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  final filtered =
                      categories.where((c) => c.type == _type).toList();
                  return _buildTopScreen(filtered);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            walletsAsync.when(
              data: (wallets) => _buildBottomScreen(wallets),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
