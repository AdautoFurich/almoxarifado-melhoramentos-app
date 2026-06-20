class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.code,
    this.description = '',
    this.location = '',
    this.quantity = 0,
    this.photoPath,
    this.history = const [],
  });

  final String name;
  final String code;
  final String description;
  final String location;
  final int quantity;
  final String? photoPath;
  final List<String> history;
}
