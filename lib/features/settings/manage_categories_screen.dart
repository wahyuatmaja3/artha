import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/categories_repository.dart';
import '../../domain/models/models.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> {
  String _selectedType = 'expense';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                ButtonSegment(value: 'income', label: Text('Pemasukan')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (value) {
                setState(() => _selectedType = value.first);
              },
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final filtered =
                    categories.where((c) => c.type == _selectedType).toList();
                return _CategoryList(
                  categories: filtered,
                  onDelete: (id) async {
                    await ref.read(categoriesRepositoryProvider).deleteCategory(id);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final iconController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama kategori'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Ikon (emoji)',
                hintText: 'Contoh: 🍽️',
              ),
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
              final icon = iconController.text.trim().isEmpty
                  ? '📁'
                  : iconController.text.trim();

              if (name.isEmpty) return;

              await ref
                  .read(categoriesRepositoryProvider)
                  .addCategory(name, _selectedType, icon);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories, required this.onDelete});

  final List<CategoryModel> categories;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('Belum ada kategori'));
    }

    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = categories[index];
        return ListTile(
          leading: CircleAvatar(child: Text(c.icon.isEmpty ? '📁' : c.icon)),
          title: Text(c.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, c),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, CategoryModel category) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus kategori?'),
            content: Text('Kategori "${category.name}" akan dihapus.'),
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
    await onDelete(category.id);
  }
}
