import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../utils/item_code_formatters.dart';
import 'empty_state.dart';
import 'inventory_item_tile.dart';

class InventoryList extends StatelessWidget {
  const InventoryList({
    super.key,
    required this.searchController,
    required this.items,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final List<InventoryItem> items;
  final ValueChanged<InventoryItem> onEditItem;
  final ValueChanged<InventoryItem> onDeleteItem;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _InventoryListHeader(),
            const SizedBox(height: 18),
            TextField(
              key: const ValueKey('inventory-search-field'),
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou código',
                prefixIcon: Icon(Icons.search),
              ),
              inputFormatters: const [SearchInputFormatter()],
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const EmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return InventoryItemTile(
                    item: item,
                    onEdit: () => onEditItem(item),
                    onDelete: () => onDeleteItem(item),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _InventoryListHeader extends StatelessWidget {
  const _InventoryListHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5ED),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD9E4D3)),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF2F6F3E),
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Itens cadastrados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF1F2A21),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
