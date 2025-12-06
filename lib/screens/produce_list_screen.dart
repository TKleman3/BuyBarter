import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/produce_repository.dart';
import '../models/produce_item.dart';
import '../widgets/produce_tile.dart';
import '../widgets/intent_form_sheet.dart';

// NEW: Firebase + Requests
import '../core/firebase_providers.dart';
import '../data/request_repository.dart';

/// Shows the list of posted produce items.
///
/// Now extends ConsumerStatefulWidget so we can:
/// - Still use the existing FutureBuilder for data
/// - Also access Riverpod providers (Firebase + RequestRepository)
class ProduceListScreen extends ConsumerStatefulWidget {
  const ProduceListScreen({super.key});

  @override
  ConsumerState<ProduceListScreen> createState() => _ProduceListScreenState();
}

class _ProduceListScreenState extends ConsumerState<ProduceListScreen> {
  final _repo = const ProduceRepository();
  late final Future<List<ProduceItem>> _future = _repo.fetchAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<List<ProduceItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? const <ProduceItem>[];
          if (items.isEmpty) {
            return const Center(child: Text('No produce posted yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = items[i];

              return ProduceTile(
                item: item,
                // BUY: now goes through Firebase Requests
                onBuy: () => _showBuyRequestDialog(item),
                // BARTER: keep your existing bottom sheet for now
                onBarter: () => _openIntentSheet(item, 'Barter'),
              );
            },
          );
        },
      ),
    );
  }

  /// Opens your existing bottom sheet (legacy behavior).
  /// We keep this for BARTER until we wire barter requests properly.
  void _openIntentSheet(ProduceItem item, String intent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => IntentFormSheet(item: item, intent: intent),
    );
  }

  /// NEW: Show a simple dialog to collect a BUY offer,
  /// then create a Request document in Firestore.
  Future<void> _showBuyRequestDialog(ProduceItem item) async {
    final priceCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Send Buy Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Offer amount',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note to owner (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      // User cancelled the dialog.
      return;
    }

    final price = num.tryParse(priceCtrl.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    try {
      // Get current user ID from Riverpod (must be signed in).
      final buyerId = ref.read(currentUserIdProvider);
      // Get the RequestRepository from Riverpod.
      final requestRepo = ref.read(requestRepositoryProvider);

      // TODO: adjust these to match your ProduceItem fields.
      final listingId = item.id;        // e.g. item.id
      final sellerId = item.ownerId;    // e.g. item.ownerId or item.userId

      await requestRepo.createBuyRequest(
        listingId: listingId,
        sellerId: sellerId,
        buyerId: buyerId,
        priceOffered: price,
        message: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }
}
