import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../screens/item_details_page.dart';

class InventoryItemTile extends StatelessWidget {
  const InventoryItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFBFCFA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE1E7DC)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ItemDetailsPage(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 470;

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: Color(0xFF2F6F3E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF1F2A21),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${item.code}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF667065)),
                        ),
                        if (item.location.isNotEmpty || item.quantity > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (item.location.isNotEmpty) item.location,
                              if (item.quantity > 0)
                                '${item.quantity} unidade(s)',
                            ].join(' - '),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF667065),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Wrap(
                    spacing: 4,
                    direction: isCompact ? Axis.vertical : Axis.horizontal,
                    children: [
                      IconButton(
                        tooltip: 'Editar item',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        color: const Color(0xFF2F6F3E),
                      ),
                      IconButton(
                        tooltip: 'Excluir item',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: const Color(0xFF9B2C2C),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
