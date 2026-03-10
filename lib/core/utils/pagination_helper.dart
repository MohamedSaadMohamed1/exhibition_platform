import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pagination state for infinite scroll
class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final int page;

  const PaginationState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.lastDocument,
    this.page = 0,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    String? error,
    DocumentSnapshot? lastDocument,
    int? page,
  }) {
    return PaginationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      page: page ?? this.page,
    );
  }

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get canLoadMore => hasMore && !isLoading;
}

/// Pagination configuration
class PaginationConfig {
  final int pageSize;
  final int prefetchDistance;

  const PaginationConfig({
    this.pageSize = 20,
    this.prefetchDistance = 5,
  });
}

/// Helper class for Firestore pagination
class FirestorePaginator<T> {
  final CollectionReference<Map<String, dynamic>> collection;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) fromFirestore;
  final PaginationConfig config;
  final Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)? queryBuilder;

  FirestorePaginator({
    required this.collection,
    required this.fromFirestore,
    this.config = const PaginationConfig(),
    this.queryBuilder,
  });

  /// Fetch first page
  Future<PaginationResult<T>> fetchFirst() async {
    Query<Map<String, dynamic>> query = queryBuilder?.call(collection) ?? collection;
    query = query.limit(config.pageSize);

    final snapshot = await query.get();

    return PaginationResult(
      items: snapshot.docs.map(fromFirestore).toList(),
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length >= config.pageSize,
    );
  }

  /// Fetch next page
  Future<PaginationResult<T>> fetchNext(DocumentSnapshot lastDoc) async {
    Query<Map<String, dynamic>> query = queryBuilder?.call(collection) ?? collection;
    query = query.startAfterDocument(lastDoc).limit(config.pageSize);

    final snapshot = await query.get();

    return PaginationResult(
      items: snapshot.docs.map(fromFirestore).toList(),
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length >= config.pageSize,
    );
  }
}

class PaginationResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginationResult({
    required this.items,
    this.lastDocument,
    required this.hasMore,
  });
}

/// Base class for paginated notifiers
abstract class PaginatedNotifier<T> extends Notifier<PaginationState<T>> {
  PaginationConfig get config => const PaginationConfig();

  @override
  PaginationState<T> build() => const PaginationState();

  /// Fetch first page - implement in subclass
  Future<void> fetchFirst();

  /// Fetch next page - implement in subclass
  Future<void> fetchNext();

  /// Refresh data
  Future<void> refresh() async {
    state = const PaginationState();
    await fetchFirst();
  }

  /// Helper to update state with loading
  void setLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }

  /// Helper to update state with results
  void setResults(List<T> newItems, {
    DocumentSnapshot? lastDocument,
    bool hasMore = true,
    bool append = false,
  }) {
    state = state.copyWith(
      items: append ? [...state.items, ...newItems] : newItems,
      isLoading: false,
      hasMore: hasMore,
      lastDocument: lastDocument,
      page: append ? state.page + 1 : 1,
    );
  }

  /// Helper to update state with error
  void setError(String error) {
    state = state.copyWith(
      isLoading: false,
      error: error,
    );
  }
}

/// Scroll controller extension for pagination
extension PaginationScrollController on ScrollController {
  void addPaginationListener({
    required VoidCallback onLoadMore,
    double threshold = 200,
  }) {
    addListener(() {
      if (position.pixels >= position.maxScrollExtent - threshold) {
        onLoadMore();
      }
    });
  }
}
