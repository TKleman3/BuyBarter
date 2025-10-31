import 'package:flutter/material.dart';
import '../data/produce_repository.dart';
import '../models/produce_item.dart';
import '../widgets/produce_tile.dart';
import '../widgets/intent_form_sheet.dart';

class ProduceListScreen extends StatefulWidget {
  const ProduceListScreen({super.key});

  @override
  State<ProduceListScreen> createState() => _ProduceListScreenState();
}

class _ProduceListScreenState extends State<ProduceListScreen> {
  final _repo = const ProduceRepository();
  late final Future<List<ProduceItem>> _future = _repo.fetchAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produce Share')),
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
                onBuy: () => _openIntentSheet(item, 'Buy'),
                onBarter: () => _openIntentSheet(item, 'Barter'),
              );
            },
          );
        },
      ),
    );
  }

  void _openIntentSheet(ProduceItem item, String intent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => IntentFormSheet(item: item, intent: intent),
    );
  }
}
