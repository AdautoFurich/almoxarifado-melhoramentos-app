class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.code,
    this.description = '',
  });

  final String name;
  final String code;
  final String description;
}
