import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../models/produce_item.dart';

class IntentFormSheet extends StatefulWidget {
  final ProduceItem item;
  final String intent; // "Buy" or "Barter"

  const IntentFormSheet({
    super.key,
    required this.item,
    required this.intent,
  });

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
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
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
