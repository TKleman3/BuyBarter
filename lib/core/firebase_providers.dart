import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/request_repository.dart';
import '../data/request_model.dart';


/// Provide FirebaseAuth instance to the app through Riverpod.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provide Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Current user ID (will throw if not signed in).
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    throw StateError('User not signed in');
  }
  return user.uid;
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  final db = ref.watch(firestoreProvider);
  return RequestRepository(db);
});


final sellerRequestsProvider =
    StreamProvider.family<List<RequestModel>, String>((ref, sellerId) {
  return ref.watch(requestRepositoryProvider).streamForSeller(sellerId);
});


final buyerRequestsProvider =
    StreamProvider.family<List<RequestModel>, String>((ref, buyerId) {
  return ref.watch(requestRepositoryProvider).streamForBuyer(buyerId);
});