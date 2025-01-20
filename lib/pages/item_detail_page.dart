// item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:localrental_flutter/models/item_display_model.dart';

class ItemDetailPage extends StatelessWidget {
  final ItemDisplayModel item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: item.boxColor.withValues(alpha: 77),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.inventory,
                  size: 80,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '\$${item.price} ${item.priceType == 'per_day' ? '/day' : '/hour'}',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xff92A3FD),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Tags:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: item.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xff92A3FD).withAlpha(77),
                );
              }).toList(),
            ),
            // Add more details or actions here as needed
          ],
        ),
      ),
    );
  }
}
