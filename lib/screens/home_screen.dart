import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase_providers.dart'; // we'll define this next
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get Firebase instances from Riverpod providers
    final auth = ref.watch(firebaseAuthProvider);
    final firestore = ref.watch(firestoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Smoke Test'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final cred = await auth.signInAnonymously();
                  final uid = cred.user?.uid;
                  if (uid == null) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Signed in as $uid')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Auth error: $e')),
                  );
                }
              },
              child: const Text('Sign in anonymously'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await firestore.collection('test').add({
                    'hello': 'world',
                    'createdAt': DateTime.now(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Firestore write OK')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Firestore error: $e')),
                  );
                }
              },
              child: const Text('Write test document'),
            ),
          ],
        ),
      ),
    );
  }
}
