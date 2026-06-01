import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/repositories/transactions_repository.dart';
import '../../data/repositories/wallets_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/budgets_repository.dart';
import '../../domain/models/models.dart';
import '../../core/ui/neo_text_field.dart';
import '../../core/utils/transaction_text_parser.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final bool automaticMode;

  const AddTransactionScreen({
    super.key,
    this.automaticMode = false,
  });

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
  bool _isRecurring = false;
  RecurringFrequency _recurringFrequency = RecurringFrequency.monthly;
  bool _recurringReminder = false;
  final _textParser = TransactionTextParser();
  ParsedTransactionInput? _lastParsed;
  late final TextEditingController _noteController;
  late final TextEditingController _quickInputController;

  static const Map<String, List<String>> _categoryKeywordHints = {
    'Makan': ['makan', 'batagor', 'bakso', 'kopi', 'jajan', 'resto'],
    'Bensin': ['bensin', 'bbm', 'pertalite', 'pertamax'],
    'Listrik': ['listrik', 'token', 'pln'],
    'Air': ['air', 'pdam'],
    'Internet': ['internet', 'wifi', 'kuota', 'data'],
    'Belanja Harian': ['belanja', 'sembako', 'minimarket'],
    'Transportasi': ['transport', 'ojek', 'gojek', 'grab', 'tol', 'parkir'],
    'Kesehatan': ['obat', 'dokter', 'klinik', 'rumah sakit'],
    'Pendidikan': ['kursus', 'sekolah', 'buku', 'kuliah'],
    'Hiburan': ['bioskop', 'game', 'hiburan', 'nonton'],
    'Gaji': ['gaji', 'salary'],
    'Bonus': ['bonus', 'thr'],
    'Freelance': ['freelance', 'proyek'],
    'Usaha': ['jualan', 'usaha', 'omzet'],
    'Investasi': ['dividen', 'investasi', 'bunga'],
  };

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: _note);
    _quickInputController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _quickInputController.dispose();
    super.dispose();
  }

  void _applyQuickInput() {
    final parsed = _textParser.parse(_quickInputController.text);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tidak dikenali. Contoh: beli batagor 10000')),
      );
      return;
    }

    final allCategories = ref.read(categoriesProvider).maybeWhen(
          data: (items) => items,
          orElse: () => <CategoryModel>[],
        );
    final categoryId = _autoSelectCategoryId(
      categories: allCategories,
      type: parsed.type,
      note: parsed.note,
    );

    setState(() {
      _type = parsed.type;
      _amountStr = parsed.amount.toInt().toString();
      _selectedDate = parsed.date;
      _note = parsed.note;
      _noteController.text = parsed.note;
      _selectedCategoryId = categoryId;
      _lastParsed = parsed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          categoryId == null
              ? 'Input berhasil diparsing.'
              : 'Input berhasil diparsing. Kategori otomatis terpilih.',
        ),
      ),
    );

    _showParsedResultSheet();
  }

  void _showParsedResultSheet() {
    if (_lastParsed == null) return;

    final categories = ref.read(categoriesProvider).maybeWhen(
          data: (items) => items,
          orElse: () => <CategoryModel>[],
        );
    final selectedCategory = categories.where((c) => c.id == _selectedCategoryId).toList();
    final categoryLabel = selectedCategory.isEmpty
        ? '-'
        : '${selectedCategory.first.icon} ${selectedCategory.first.name}';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hasil Parsing', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('Tipe: ${_lastParsed!.type == 'expense' ? 'Pengeluaran' : 'Pemasukan'}'),
                const SizedBox(height: 6),
                Text('Nominal: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_lastParsed!.amount)}'),
                const SizedBox(height: 6),
                Text('Catatan: ${_lastParsed!.note.isEmpty ? '-' : _lastParsed!.note}'),
                const SizedBox(height: 6),
                Text('Kategori: $categoryLabel'),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Lanjutkan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _autoSelectCategoryId({
    required List<CategoryModel> categories,
    required String type,
    required String note,
  }) {
    final byType = categories.where((c) => c.type == type).toList();
    if (byType.isEmpty) return null;

    final noteLower = note.toLowerCase();
    for (final category in byType) {
      final hints = _categoryKeywordHints[category.name] ?? const <String>[];
      for (final hint in hints) {
        if (noteLower.contains(hint)) {
          return category.id;
        }
      }
    }

    for (final category in byType) {
      if (noteLower.contains(category.name.toLowerCase())) {
        return category.id;
      }
    }

    final fallback = byType.where((c) => c.name.toLowerCase() == 'lainnya').toList();
    if (fallback.isNotEmpty) return fallback.first.id;
    return byType.first.id;
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
        SnackBar(
          content: Text(widget.automaticMode ? 'Parse input dulu lalu pilih wallet.' : 'Pilih wallet dan kategori'),
        ),
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
      if (_isRecurring) {
        await ref.read(transactionsRepositoryProvider).addRecurringRule(
              walletId: _selectedWalletId!,
              categoryId: _selectedCategoryId!,
              amount: amt,
              type: _type,
              startDate: _selectedDate,
              frequency: _recurringFrequency,
              note: _note,
              reminderEnabled: _recurringReminder,
              autoCreateEnabled: true,
            );
      } else {
        await ref.read(transactionsRepositoryProvider).addTransaction(
              walletId: _selectedWalletId!,
              categoryId: _selectedCategoryId!,
              amount: amt,
              type: _type,
              date: _selectedDate,
              note: _note,
            );
      }
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
          child: widget.automaticMode
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _selectedCategoryId == null
                          ? 'Kategori akan dipilih otomatis setelah parsing input.'
                          : 'Kategori dipilih otomatis. Kamu bisa lanjut simpan transaksi.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : GridView.builder(
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
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
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
                          : 'Wallet',
                ),
                onPressed: wallets.isEmpty ? null : () => _showWalletPicker(wallets),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.calendarDay, size: 14),
                      const SizedBox(width: 8),
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
              FilterChip(
                label: const Text('Recurring'),
                selected: _isRecurring,
                onSelected: (v) => setState(() => _isRecurring = v),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.automaticMode) ...[
            NeoTextFieldFrame(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quickInputController,
                      minLines: 1,
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _applyQuickInput(),
                      decoration: const InputDecoration(
                        hintText: 'Input otomatis: beli batagor 10000',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _applyQuickInput,
                    child: const Text('Parse'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (!widget.automaticMode)
            NeoTextFieldFrame(
              child: TextField(
                controller: _noteController,
                onChanged: (value) => _note = value,
                minLines: 1,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Catatan (opsional)',
                  isDense: true,
                ),
              ),
            ),
          if (_isRecurring) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frekuensi Recurring',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Harian'),
                        selected: _recurringFrequency == RecurringFrequency.daily,
                        onSelected: (_) => setState(() => _recurringFrequency = RecurringFrequency.daily),
                      ),
                      ChoiceChip(
                        label: const Text('Mingguan'),
                        selected: _recurringFrequency == RecurringFrequency.weekly,
                        onSelected: (_) => setState(() => _recurringFrequency = RecurringFrequency.weekly),
                      ),
                      ChoiceChip(
                        label: const Text('Bulanan'),
                        selected: _recurringFrequency == RecurringFrequency.monthly,
                        onSelected: (_) => setState(() => _recurringFrequency = RecurringFrequency.monthly),
                      ),
                      ChoiceChip(
                        label: const Text('Tahunan'),
                        selected: _recurringFrequency == RecurringFrequency.yearly,
                        onSelected: (_) => setState(() => _recurringFrequency = RecurringFrequency.yearly),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder'),
                    value: _recurringReminder,
                    onChanged: (v) => setState(() => _recurringReminder = v),
                  ),
                ],
              ),
            ),
          ],
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: isOk && _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  key,
                  style: TextStyle(
                    fontSize: isAction ? 17 : 20,
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
            if (widget.automaticMode || _selectedCategoryId != null)
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
