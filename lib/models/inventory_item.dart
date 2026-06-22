class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.code,
    this.description = '',
    this.photoPath,
    this.history = const [],
  });

  final String name;
  final String code;
  final String description;
  final String? photoPath;
  final List<String> history;
}
