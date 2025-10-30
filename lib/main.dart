import 'dart:convert';
const SizedBox(height: 8),
TextFormField(
controller: _phoneCtrl,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(labelText: 'Your phone number'),
validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
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