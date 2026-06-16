import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../widgets/create_item_button.dart';
import '../widgets/inventory_list.dart';
import '../widgets/item_form.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _searchController = TextEditingController();
  final List<InventoryItem> _items = [];
  bool _showItemForm = false;
  int? _editingItemIndex;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<InventoryItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    final queryDigits = query.replaceAll(RegExp(r'\D'), '');

    if (query.isEmpty) {
      return _items;
    }

    return _items.where((item) {
      final itemCodeDigits = item.code.replaceAll(RegExp(r'\D'), '');

      return item.name.toLowerCase().contains(query) ||
          item.code.toLowerCase().contains(query) ||
          (queryDigits.isNotEmpty && itemCodeDigits.contains(queryDigits));
    }).toList();
  }

  void _submitItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = InventoryItem(
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
    );
    final wasEditing = _editingItemIndex != null;

    setState(() {
      final editingItemIndex = _editingItemIndex;

      if (editingItemIndex == null) {
        _items.add(item);
      } else {
        _items[editingItemIndex] = item;
        _editingItemIndex = null;
      }

      _nameController.clear();
      _codeController.clear();
      _showItemForm = false;
    });

    final message = wasEditing
        ? 'Item atualizado com sucesso.'
        : 'Item cadastrado com sucesso.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isCodeRegistered(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');

    return _items.indexed.any((entry) {
      final (index, item) = entry;

      if (index == _editingItemIndex) {
        return false;
      }

      return item.code.replaceAll(RegExp(r'\D'), '') == digits;
    });
  }

  void _startEditing(InventoryItem item) {
    final itemIndex = _items.indexOf(item);

    if (itemIndex == -1) {
      return;
    }

    setState(() {
      _showItemForm = true;
      _editingItemIndex = itemIndex;
      _nameController.text = item.name;
      _codeController.text = item.code;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingItemIndex = null;
      _nameController.clear();
      _codeController.clear();
      _showItemForm = false;
    });
  }

  void _showCreateItemForm() {
    setState(() {
      _editingItemIndex = null;
      _nameController.clear();
      _codeController.clear();
      _showItemForm = true;
    });
  }

  Future<void> _confirmDeleteItem(InventoryItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir item?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Confirme os dados do item que será removido:'),
              const SizedBox(height: 12),
              _DeleteItemDetail(label: 'Nome', value: item.name),
              const SizedBox(height: 8),
              _DeleteItemDetail(label: 'Código', value: item.code),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      final deletedIndex = _items.indexOf(item);

      if (deletedIndex == -1) {
        return;
      }

      _items.removeAt(deletedIndex);

      if (_editingItemIndex == deletedIndex) {
        _editingItemIndex = null;
        _nameController.clear();
        _codeController.clear();
      } else if (_editingItemIndex != null &&
          _editingItemIndex! > deletedIndex) {
        _editingItemIndex = _editingItemIndex! - 1;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item excluído com sucesso.')));
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 82,
        centerTitle: true,
        title: Semantics(
          label: 'Companhia Melhoramentos Norte do Paraná',
          image: true,
          child: Image.asset(
            'assets/companhia.png',
            key: const ValueKey('company-logo'),
            height: 56,
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: isWide ? 370 : double.infinity,
                            child: _showItemForm
                                ? ItemForm(
                                    formKey: _formKey,
                                    nameController: _nameController,
                                    codeController: _codeController,
                                    isCodeRegistered: _isCodeRegistered,
                                    isEditing: _editingItemIndex != null,
                                    onCancelEditing: _cancelEditing,
                                    onSubmit: _submitItem,
                                  )
                                : CreateItemButton(
                                    onPressed: _showCreateItemForm,
                                  ),
                          ),
                          SizedBox(
                            width: isWide ? 18 : 0,
                            height: isWide ? 0 : 18,
                          ),
                          if (isWide)
                            Expanded(
                              child: InventoryList(
                                searchController: _searchController,
                                items: filteredItems,
                                onEditItem: _startEditing,
                                onDeleteItem: _confirmDeleteItem,
                                onSearchChanged: (_) => setState(() {}),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: InventoryList(
                                searchController: _searchController,
                                items: filteredItems,
                                onEditItem: _startEditing,
                                onDeleteItem: _confirmDeleteItem,
                                onSearchChanged: (_) => setState(() {}),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeleteItemDetail extends StatelessWidget {
  const _DeleteItemDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E7DC)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667065),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1F2A21),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
