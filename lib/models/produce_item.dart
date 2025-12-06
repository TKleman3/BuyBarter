class ProduceItem {
  final String id;
  final String ownerId;
  final String title;
  final String unit;
  final double quantity;
  final double price; // per unit
  final String description;
  final String? image;

  const ProduceItem({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.description,
    this.image,
  });

  factory ProduceItem.fromJson(Map<String, dynamic> j) => ProduceItem(
        id: j['id'] as String,
        ownerId: j['ownerId'] as String,
        title: j['title'] as String,
        unit: j['unit'] as String,
        quantity: (j['quantity'] as num).toDouble(),
        price: (j['price'] as num).toDouble(),
        description: (j['description'] as String?) ?? '',
        image: j['image'] as String?,
      );
}
