import 'package:flutter/material.dart';
import '../models/produce_item.dart';
import 'smart_image.dart';

class ProduceTile extends StatelessWidget {
  final ProduceItem item;
  final VoidCallback onBuy;
  final VoidCallback onBarter;

  const ProduceTile({
    super.key,
    required this.item,
    required this.onBuy,
    required this.onBarter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmartImage(item.image, size: 96),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(label: Text('${item.quantity} ${item.unit} available')),
                      Chip(label: Text('\$${item.price.toStringAsFixed(2)} per ${item.unit}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onBuy,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Buy'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: onBarter,
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Barter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
