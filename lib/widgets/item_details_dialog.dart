import 'package:flutter/material.dart';

import '../models/inventory_item.dart';

class ItemDetailsDialog extends StatelessWidget {
  const ItemDetailsDialog({super.key, required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes do item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemDetailRow(label: 'Nome', value: item.name),
          const SizedBox(height: 10),
          _ItemDetailRow(label: 'Código', value: item.code),
          const SizedBox(height: 10),
          _ItemDetailRow(
            label: 'Descrição',
            value: item.description.isEmpty
                ? 'Sem descrição.'
                : item.description,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class _ItemDetailRow extends StatelessWidget {
  const _ItemDetailRow({required this.label, required this.value});

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
              width: 76,
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
