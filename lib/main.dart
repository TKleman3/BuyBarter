import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

// ====== Configure these with your info ======
const String sellerPhoneE164 = "+14192036869"; // <- replace with your number
const String sellerEmail = "toddkleman@gmail.com";  // <- optional fallback
// ============================================

void main() {
  runApp(const ProduceShareApp());
}

class ProduceShareApp extends StatelessWidget {
  const ProduceShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produce Share',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ProduceListPage(),
    );
  }
}

class ProduceItem {
  final String id;
  final String title;
  final String unit;
  final double quantity;
  final double price; // per unit
  final String description;
  final String? image;

  ProduceItem({
    required this.id,
    required this.title,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.description,
    this.image,
  });

  factory ProduceItem.fromJson(Map<String, dynamic> j) => ProduceItem(
        id: j['id'] as String,
        title: j['title'] as String,
        unit: j['unit'] as String,
        quantity: (j['quantity'] as num).toDouble(),
        price: (j['price'] as num).toDouble(),
        description: (j['description'] as String?) ?? '',
        image: j['image'] as String?,
      );
}

class ProduceListPage extends StatefulWidget {
  const ProduceListPage({super.key});

  @override
  State<ProduceListPage> createState() => _ProduceListPageState();
}

class _ProduceListPageState extends State<ProduceListPage> {
  late Future<List<ProduceItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = _loadItems();
  }

  Future<List<ProduceItem>> _loadItems() async {
    final raw = await rootBundle.loadString('assets/produce.json');
    final data = json.decode(raw) as List<dynamic>;
    return data.map((e) => ProduceItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produce Share')),
      body: FutureBuilder<List<ProduceItem>>(
        future: _items,
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
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.image!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 96,
                          height: 96,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_florist),
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
                                  onPressed: () => _openIntentSheet(context, item, 'Buy'),
                                  icon: const Icon(Icons.shopping_cart),
                                  label: const Text('Buy'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _openIntentSheet(context, item, 'Barter'),
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
            },
          );
        },
      ),
    );
  }

  void _openIntentSheet(BuildContext context, ProduceItem item, String intent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => IntentFormSheet(item: item, intent: intent),
    );
  }
}

class IntentFormSheet extends StatefulWidget {
  final ProduceItem item;
  final String intent; // "Buy" or "Barter"
  const IntentFormSheet({super.key, required this.item, required this.intent});

  @override
  State<IntentFormSheet> createState() => _IntentFormSheetState();
}

class _IntentFormSheetState extends State<IntentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.intent} — ${widget.item.title}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Your phone number'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter your phone number'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Optional note (quantity, pickup time, barter offer, etc.)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _sendSMS,
                      icon: const Icon(Icons.sms),
                      label: const Text('Send SMS'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _sendEmail,
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Send Email'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _composeBody() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final note = _messageCtrl.text.trim();
    final lines = [
      'Intent: ${widget.intent}',
      'Item: ${widget.item.title}',
      'From: $name',
      'Phone: $phone',
      if (note.isNotEmpty) 'Note: $note',
    ];
    return lines.join('\n');
  }

  Future<void> _sendSMS() async {
    if (!_formKey.currentState!.validate()) return;
    final body = Uri.encodeComponent(_composeBody());
    final uri = Uri.parse('sms:$sellerPhoneE164?body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (mounted) Navigator.of(context).pop();
    } else {
      _snack('Could not open SMS app. Try email instead.');
    }
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final subject = Uri.encodeComponent('[Produce Share] ${widget.intent} — ${widget.item.title}');
    final body = Uri.encodeComponent(_composeBody());
    final uri = Uri.parse('mailto:$sellerEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (mounted) Navigator.of(context).pop();
    } else {
      _snack('Could not open email app.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
