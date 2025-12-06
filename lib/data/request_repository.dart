// lib/data/request_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_model.dart';

/// Handles all Firestore reads/writes related to requests.
/// This keeps your UI code clean and focused on presentation.
class RequestRepository {
  RequestRepository(this._db);

  final FirebaseFirestore _db;

  /// Convenience getter for the 'requests' collection.
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('requests');

  /// Create a BUY request document in Firestore.
  Future<void> createBuyRequest({
    required String listingId,
    required String sellerId,
    required String buyerId,
    required num priceOffered,
    String? message,
  }) async {
    final now = DateTime.now();
    final doc = _col.doc();

    final req = RequestModel(
      id: doc.id,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      type: RequestType.buy,
      status: RequestStatus.pending,
      message: message,
      priceOffered: priceOffered,
      barterItems: null,
      createdAt: now,
      updatedAt: now,
    );

    await doc.set(req.toMap());
  }

  /// Live stream of requests where the given user is the seller.
  Stream<List<RequestModel>> streamForSeller(String sellerId) {
    return _col
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RequestModel.fromDoc).toList());
  }

  /// Live stream of requests where the given user is the buyer.
  Stream<List<RequestModel>> streamForBuyer(String buyerId) {
    return _col
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RequestModel.fromDoc).toList());
  }
}
