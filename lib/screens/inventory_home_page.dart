import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/inventory_item.dart';
import '../services/item_photo_service.dart';
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
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final _photoService = ItemPhotoService();
  final List<InventoryItem> _items = [];
  bool _showItemForm = false;
  int? _editingItemIndex;
  String? _selectedPhotoPath;
  String? _originalPhotoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
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
          item.description.toLowerCase().contains(query) ||
          (queryDigits.isNotEmpty && itemCodeDigits.contains(queryDigits));
    }).toList();
  }

  void _submitItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final wasEditing = _editingItemIndex != null;
    final previousItem = wasEditing ? _items[_editingItemIndex!] : null;
    final item = InventoryItem(
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      photoPath: _selectedPhotoPath,
      history: [
        ...?previousItem?.history,
        wasEditing
            ? 'Dados atualizados em ${_formatDate(DateTime.now())}.'
            : 'Item cadastrado em ${_formatDate(DateTime.now())}.',
      ],
    );

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
      _descriptionController.clear();
      _selectedPhotoPath = null;
      _originalPhotoPath = null;
      _showItemForm = false;
    });

    if (previousItem?.photoPath != item.photoPath) {
      unawaited(_photoService.deletePhoto(previousItem?.photoPath));
    }

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
      _descriptionController.text = item.description;
      _selectedPhotoPath = item.photoPath;
      _originalPhotoPath = item.photoPath;
    });
  }

  void _cancelEditing() {
    final discardedPhotoPath = _selectedPhotoPath != _originalPhotoPath
        ? _selectedPhotoPath
        : null;

    setState(() {
      _editingItemIndex = null;
      _nameController.clear();
      _codeController.clear();
      _descriptionController.clear();
      _selectedPhotoPath = null;
      _originalPhotoPath = null;
      _showItemForm = false;
    });

    unawaited(_photoService.deletePhoto(discardedPhotoPath));
  }

  void _showCreateItemForm() {
    setState(() {
      _editingItemIndex = null;
      _nameController.clear();
      _codeController.clear();
      _descriptionController.clear();
      _selectedPhotoPath = null;
      _originalPhotoPath = null;
      _showItemForm = true;
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final newPhotoPath = await _photoService.pickAndStore(source);

      if (newPhotoPath == null || !mounted) {
        return;
      }

      final discardedPhotoPath = _selectedPhotoPath != _originalPhotoPath
          ? _selectedPhotoPath
          : null;

      setState(() {
        _selectedPhotoPath = newPhotoPath;
      });

      await _photoService.deletePhoto(discardedPhotoPath);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível adicionar a foto.')),
      );
    }
  }

  void _removePhoto() {
    final discardedPhotoPath = _selectedPhotoPath != _originalPhotoPath
        ? _selectedPhotoPath
        : null;

    setState(() {
      _selectedPhotoPath = null;
    });

    unawaited(_photoService.deletePhoto(discardedPhotoPath));
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

    final deletedIndex = _items.indexOf(item);
    if (deletedIndex == -1) {
      return;
    }

    final photoPath = item.photoPath;
    final discardedDraftPhotoPath =
        _editingItemIndex == deletedIndex &&
            _selectedPhotoPath != _originalPhotoPath
        ? _selectedPhotoPath
        : null;

    setState(() {
      _items.removeAt(deletedIndex);

      if (_editingItemIndex == deletedIndex) {
        _editingItemIndex = null;
        _nameController.clear();
        _codeController.clear();
        _descriptionController.clear();
        _selectedPhotoPath = null;
        _originalPhotoPath = null;
      } else if (_editingItemIndex != null &&
          _editingItemIndex! > deletedIndex) {
        _editingItemIndex = _editingItemIndex! - 1;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item excluído com sucesso.')));
    unawaited(_photoService.deletePhoto(photoPath));
    unawaited(_photoService.deletePhoto(discardedDraftPhotoPath));
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: const _InventoryTopBar(),
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
                                    descriptionController:
                                        _descriptionController,
                                    photoPath: _selectedPhotoPath,
                                    onTakePhoto: () =>
                                        _pickPhoto(ImageSource.camera),
                                    onChoosePhoto: () =>
                                        _pickPhoto(ImageSource.gallery),
                                    onRemovePhoto: _removePhoto,
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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/$year às $hour:$minute';
}

class _InventoryTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _InventoryTopBar();

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final horizontalPadding = isCompact ? 18.0 : 28.0;
          final logoHeight = isCompact ? 66.0 : 72.0;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF075324),
                  Color(0xFF0C6A2D),
                  Color(0xFF0D5E2A),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -72,
                  top: -76,
                  child: Container(
                    width: isCompact ? 210 : 250,
                    height: isCompact ? 210 : 250,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Semantics(
                              label: 'Companhia Melhoramentos Norte do Paraná',
                              image: true,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  'assets/companhia.png',
                                  key: const ValueKey('company-logo'),
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
