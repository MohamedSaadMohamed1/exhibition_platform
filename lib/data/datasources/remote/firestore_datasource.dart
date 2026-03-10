import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';

/// Query filter helper
class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  const QueryFilter(this.field, this.operator, this.value);
}

/// Filter operators for Firestore queries
enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}

/// Query order helper
class QueryOrder {
  final String field;
  final bool descending;

  const QueryOrder(this.field, {this.descending = false});
}

/// Batch operation types
abstract class BatchOperation {
  String get collection;
  String? get documentId;
}

class BatchCreate extends BatchOperation {
  @override
  final String collection;
  @override
  final String? documentId;
  final Map<String, dynamic> data;

  BatchCreate(this.collection, this.data, {this.documentId});
}

class BatchUpdate extends BatchOperation {
  @override
  final String collection;
  @override
  final String documentId;
  final Map<String, dynamic> data;

  BatchUpdate(this.collection, this.documentId, this.data);
}

class BatchDelete extends BatchOperation {
  @override
  final String collection;
  @override
  final String documentId;

  BatchDelete(this.collection, this.documentId);
}

/// Generic Firestore Data Source Interface
abstract class FirestoreDataSource {
  /// Get single document by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String documentId,
  );

  /// Get documents with optional filtering, ordering, and pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getDocuments(
    String collection, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    DocumentSnapshot? startAfter,
  });

  /// Stream a single document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collection,
    String documentId,
  );

  /// Stream a collection with optional filtering and ordering
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
  });

  /// Create a new document
  Future<DocumentReference<Map<String, dynamic>>> createDocument(
    String collection,
    Map<String, dynamic> data, {
    String? documentId,
  });

  /// Update existing document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  );

  /// Set document (create or overwrite)
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  });

  /// Delete document
  Future<void> deleteDocument(String collection, String documentId);

  /// Perform batch write operations
  Future<void> batchWrite(List<BatchOperation> operations);

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  );

  /// Get subcollection document
  Future<DocumentSnapshot<Map<String, dynamic>>> getSubcollectionDocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  );

  /// Stream subcollection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
  });

  /// Add document to subcollection
  Future<DocumentReference<Map<String, dynamic>>> addToSubcollection(
    String parentCollection,
    String parentId,
    String subcollection,
    Map<String, dynamic> data,
  );
}

/// Firestore Data Source Implementation
class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSourceImpl(this._firestore);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get document: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getDocuments(
    String collection, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = _applyFilter(query, filter);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        for (final order in orderBy) {
          query = query.orderBy(order.field, descending: order.descending);
        }
      }

      // Apply pagination cursor
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get documents: $e',
        originalException: e,
      );
    }
  }

  Query<Map<String, dynamic>> _applyFilter(
    Query<Map<String, dynamic>> query,
    QueryFilter filter,
  ) {
    switch (filter.operator) {
      case FilterOperator.isEqualTo:
        return query.where(filter.field, isEqualTo: filter.value);
      case FilterOperator.isNotEqualTo:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case FilterOperator.isLessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case FilterOperator.isLessThanOrEqualTo:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case FilterOperator.isGreaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case FilterOperator.isGreaterThanOrEqualTo:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case FilterOperator.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case FilterOperator.arrayContainsAny:
        return query.where(filter.field, arrayContainsAny: filter.value);
      case FilterOperator.whereIn:
        return query.where(filter.field, whereIn: filter.value);
      case FilterOperator.whereNotIn:
        return query.where(filter.field, whereNotIn: filter.value);
      case FilterOperator.isNull:
        return query.where(filter.field, isNull: filter.value);
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (filters != null) {
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
    }

    if (orderBy != null) {
      for (final order in orderBy) {
        query = query.orderBy(order.field, descending: order.descending);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  @override
  Future<DocumentReference<Map<String, dynamic>>> createDocument(
    String collection,
    Map<String, dynamic> data, {
    String? documentId,
  }) async {
    try {
      // Add timestamps
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (documentId != null) {
        final ref = _firestore.collection(collection).doc(documentId);
        await ref.set(data);
        return ref;
      } else {
        return await _firestore.collection(collection).add(data);
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to create document: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add updated timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw ServerException(
        message: 'Failed to update document: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      if (!merge) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      throw ServerException(
        message: 'Failed to set document: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete document: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        if (operation is BatchCreate) {
          final ref = operation.documentId != null
              ? _firestore.collection(operation.collection).doc(operation.documentId)
              : _firestore.collection(operation.collection).doc();
          final data = {
            ...operation.data,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          batch.set(ref, data);
        } else if (operation is BatchUpdate) {
          final ref = _firestore
              .collection(operation.collection)
              .doc(operation.documentId);
          final data = {
            ...operation.data,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          batch.update(ref, data);
        } else if (operation is BatchDelete) {
          final ref = _firestore
              .collection(operation.collection)
              .doc(operation.documentId);
          batch.delete(ref);
        }
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(
        message: 'Failed to perform batch write: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  ) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      throw ServerException(
        message: 'Transaction failed: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getSubcollectionDocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  ) async {
    try {
      return await _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection)
          .doc(documentId)
          .get();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get subcollection document: $e',
        originalException: e,
      );
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(parentCollection)
        .doc(parentId)
        .collection(subcollection);

    if (filters != null) {
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
    }

    if (orderBy != null) {
      for (final order in orderBy) {
        query = query.orderBy(order.field, descending: order.descending);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  @override
  Future<DocumentReference<Map<String, dynamic>>> addToSubcollection(
    String parentCollection,
    String parentId,
    String subcollection,
    Map<String, dynamic> data,
  ) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      return await _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection)
          .add(data);
    } catch (e) {
      throw ServerException(
        message: 'Failed to add to subcollection: $e',
        originalException: e,
      );
    }
  }
}
