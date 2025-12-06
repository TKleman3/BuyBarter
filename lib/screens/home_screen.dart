// lib/screens/home_screen.dart (adjust imports to match your structure)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    final firestore = ref.watch(firestoreProvider);
    final requestRepo = ref.watch(requestRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Smoke Test + Requests'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Existing auth button
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

            // Existing Firestore test
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
            const SizedBox(height: 16),

            // NEW: simple Request test button
            ElevatedButton(
              onPressed: () async {
                try {
                  // Make sure the user is signed in.
                  final buyerId = ref.read(currentUserIdProvider);

                  // For now, use fake IDs. Later we’ll use real listing + seller.
                  const fakeListingId = 'demo-listing-123';
                  const fakeSellerId = 'demo-seller-abc';

                  await requestRepo.createBuyRequest(
                    listingId: fakeListingId,
                    sellerId: fakeSellerId,
                    buyerId: buyerId,
                    priceOffered: 5, // $5, or 5 units of whatever
                    message: 'I would like to buy this item.',
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request document created')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Request error: $e')),
                  );
                }
              },
              child: const Text('Create test BUY request'),
            ),
          ],
        ),
      ),
    );
  }
}
