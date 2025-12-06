// lib/data/request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a buy or barter request between two users.
class RequestModel {
  final String id;              // Firestore document ID
  final String listingId;       // The item being requested
  final String buyerId;         // User who wants the item
  final String sellerId;        // Owner of the item
  final RequestType type;       // BUY or BARTER
  final RequestStatus status;   // PENDING, ACCEPTED, etc.
  final String? message;        // Optional note from the buyer
  final num? priceOffered;      // For BUY requests
  final List<Map<String, dynamic>>? barterItems; // For BARTER requests
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestModel({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.type,
    required this.status,
    this.message,
    this.priceOffered,
    this.barterItems,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Build a RequestModel from a Firestore document.
  factory RequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RequestModel(
      id: doc.id,
      listingId: data['listingId'] as String,
      buyerId: data['buyerId'] as String,
      sellerId: data['sellerId'] as String,
      type: (data['type'] as String) == 'BUY'
          ? RequestType.buy
          : RequestType.barter,
      status: RequestStatusX.fromString(data['status'] as String),
      message: data['message'] as String?,
      priceOffered: data['priceOffered'] as num?,
      // Firestore stores lists as List<dynamic>, so we cast to the map type we expect.
      barterItems:
          (data['barterItems'] as List?)?.cast<Map<String, dynamic>>(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert this RequestModel into a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'type': type == RequestType.buy ? 'BUY' : 'BARTER',
      'status': status.name.toUpperCase(),
      'message': message,
      'priceOffered': priceOffered,
      'barterItems': barterItems,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Helps us update individual fields without mutating the original object.
  RequestModel copyWith({
    RequestStatus? status,
    num? priceOffered,
    List<Map<String, dynamic>>? barterItems,
    DateTime? updatedAt,
  }) {
    return RequestModel(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      type: type,
      status: status ?? this.status,
      message: message,
      priceOffered: priceOffered ?? this.priceOffered,
      barterItems: barterItems ?? this.barterItems,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Whether this is a straightforward purchase or a barter offer.
enum RequestType { buy, barter }

/// The lifecycle stage of a request.
enum RequestStatus {
  pending,
  accepted,
  countered,
  declined,
  withdrawn,
  completed,
}

/// Helper methods for converting status strings to enum values.
extension RequestStatusX on RequestStatus {
  static RequestStatus fromString(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return RequestStatus.pending;
      case 'ACCEPTED':
        return RequestStatus.accepted;
      case 'COUNTERED':
        return RequestStatus.countered;
      case 'DECLINED':
        return RequestStatus.declined;
      case 'WITHDRAWN':
        return RequestStatus.withdrawn;
      case 'COMPLETED':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }
}
