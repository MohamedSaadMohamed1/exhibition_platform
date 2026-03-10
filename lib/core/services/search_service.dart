import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/event_model.dart';
import '../../shared/models/supplier_model.dart';
import '../../shared/models/service_model.dart';
import '../../shared/models/job_model.dart';

/// Search result types
enum SearchResultType { event, supplier, service, job }

/// Search result item
class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final dynamic data;

  const SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.type,
    this.data,
  });

  /// Get route for navigation
  String get route {
    switch (type) {
      case SearchResultType.event:
        return '/events/$id';
      case SearchResultType.supplier:
        return '/suppliers/$id';
      case SearchResultType.service:
        return '/services/$id';
      case SearchResultType.job:
        return '/jobs/$id';
    }
  }
}

/// Search filter options
class SearchFilters {
  final List<SearchResultType>? types;
  final String? category;
  final String? location;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  const SearchFilters({
    this.types,
    this.category,
    this.location,
    this.fromDate,
    this.toDate,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  SearchFilters copyWith({
    List<SearchResultType>? types,
    String? category,
    String? location,
    DateTime? fromDate,
    DateTime? toDate,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) {
    return SearchFilters(
      types: types ?? this.types,
      category: category ?? this.category,
      location: location ?? this.location,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
    );
  }

  bool get hasActiveFilters =>
      types != null ||
      category != null ||
      location != null ||
      fromDate != null ||
      toDate != null ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null;
}

/// Search service
class SearchService {
  final FirebaseFirestore _firestore;

  SearchService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Global search across all content types
  Future<List<SearchResult>> search(
    String query, {
    SearchFilters? filters,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final results = <SearchResult>[];

    // Determine which types to search
    final typesToSearch = filters?.types ?? SearchResultType.values;

    // Search in parallel
    await Future.wait([
      if (typesToSearch.contains(SearchResultType.event))
        _searchEvents(queryLower, filters, limit).then((r) => results.addAll(r)),
      if (typesToSearch.contains(SearchResultType.supplier))
        _searchSuppliers(queryLower, filters, limit).then((r) => results.addAll(r)),
      if (typesToSearch.contains(SearchResultType.service))
        _searchServices(queryLower, filters, limit).then((r) => results.addAll(r)),
      if (typesToSearch.contains(SearchResultType.job))
        _searchJobs(queryLower, filters, limit).then((r) => results.addAll(r)),
    ]);

    // Sort by relevance (title match first)
    results.sort((a, b) {
      final aStartsWith = a.title.toLowerCase().startsWith(queryLower);
      final bStartsWith = b.title.toLowerCase().startsWith(queryLower);
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return a.title.compareTo(b.title);
    });

    return results.take(limit).toList();
  }

  /// Search events
  Future<List<SearchResult>> _searchEvents(
    String query,
    SearchFilters? filters,
    int limit,
  ) async {
    try {
      Query<Map<String, dynamic>> dbQuery = _firestore
          .collection('events')
          .where('status', isEqualTo: 'published')
          .orderBy('title')
          .limit(limit * 2); // Get more to filter client-side

      // Apply date filter
      if (filters?.fromDate != null) {
        dbQuery = dbQuery.where(
          'startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filters!.fromDate!),
        );
      }

      final snapshot = await dbQuery.get();

      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) {
            // Client-side text search
            final titleMatch = event.title.toLowerCase().contains(query);
            final descMatch = event.description.toLowerCase().contains(query);
            final locationMatch = event.location.toLowerCase().contains(query);
            final tagMatch = event.tags.any((t) => t.toLowerCase().contains(query));

            if (!titleMatch && !descMatch && !locationMatch && !tagMatch) {
              return false;
            }

            // Apply additional filters
            if (filters?.category != null && event.category != filters!.category) {
              return false;
            }
            if (filters?.location != null &&
                !event.location.toLowerCase().contains(filters!.location!.toLowerCase())) {
              return false;
            }

            return true;
          })
          .take(limit)
          .map((event) => SearchResult(
                id: event.id,
                title: event.title,
                subtitle: event.location,
                imageUrl: event.images.isNotEmpty ? event.images.first : null,
                type: SearchResultType.event,
                data: event,
              ))
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  /// Search suppliers
  Future<List<SearchResult>> _searchSuppliers(
    String query,
    SearchFilters? filters,
    int limit,
  ) async {
    try {
      Query<Map<String, dynamic>> dbQuery = _firestore
          .collection('suppliers')
          .where('isActive', isEqualTo: true)
          .orderBy('businessName')
          .limit(limit * 2);

      // Apply rating filter
      if (filters?.minRating != null) {
        dbQuery = dbQuery.where('rating', isGreaterThanOrEqualTo: filters!.minRating);
      }

      final snapshot = await dbQuery.get();

      return snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .where((supplier) {
            // Client-side text search
            final nameMatch = supplier.name.toLowerCase().contains(query);
            final descMatch = supplier.description.toLowerCase().contains(query);
            final categoryMatch =
                supplier.category?.toLowerCase().contains(query) ?? false;
            final servicesMatch =
                supplier.services.any((s) => s.toLowerCase().contains(query));

            if (!nameMatch && !descMatch && !categoryMatch && !servicesMatch) {
              return false;
            }

            // Apply category filter
            if (filters?.category != null && supplier.category != filters!.category) {
              return false;
            }

            return true;
          })
          .take(limit)
          .map((supplier) => SearchResult(
                id: supplier.id,
                title: supplier.name,
                subtitle: supplier.category ?? supplier.services.take(2).join(' • '),
                imageUrl: supplier.coverImage,
                type: SearchResultType.supplier,
                data: supplier,
              ))
          .toList();
    } catch (e) {
      print('Error searching suppliers: $e');
      return [];
    }
  }

  /// Search services
  Future<List<SearchResult>> _searchServices(
    String query,
    SearchFilters? filters,
    int limit,
  ) async {
    try {
      Query<Map<String, dynamic>> dbQuery = _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .orderBy('title')
          .limit(limit * 2);

      // Apply price filters
      if (filters?.minPrice != null) {
        dbQuery = dbQuery.where('price', isGreaterThanOrEqualTo: filters!.minPrice);
      }
      if (filters?.maxPrice != null) {
        dbQuery = dbQuery.where('price', isLessThanOrEqualTo: filters!.maxPrice);
      }

      final snapshot = await dbQuery.get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .where((service) {
            // Client-side text search
            final titleMatch = service.title.toLowerCase().contains(query);
            final descMatch = service.description.toLowerCase().contains(query);
            final categoryMatch = service.category.toLowerCase().contains(query);

            if (!titleMatch && !descMatch && !categoryMatch) {
              return false;
            }

            // Apply category filter
            if (filters?.category != null && service.category != filters!.category) {
              return false;
            }
            if (filters?.minRating != null && service.rating < filters!.minRating!) {
              return false;
            }

            return true;
          })
          .take(limit)
          .map((service) => SearchResult(
                id: service.id,
                title: service.title,
                subtitle: service.formattedPrice,
                imageUrl: service.primaryImage,
                type: SearchResultType.service,
                data: service,
              ))
          .toList();
    } catch (e) {
      print('Error searching services: $e');
      return [];
    }
  }

  /// Search jobs
  Future<List<SearchResult>> _searchJobs(
    String query,
    SearchFilters? filters,
    int limit,
  ) async {
    try {
      Query<Map<String, dynamic>> dbQuery = _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'open')
          .orderBy('title')
          .limit(limit * 2);

      final snapshot = await dbQuery.get();

      return snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc))
          .where((job) {
            // Client-side text search
            final titleMatch = job.title.toLowerCase().contains(query);
            final descMatch = job.description.toLowerCase().contains(query);
            final locationMatch = job.location?.toLowerCase().contains(query) ?? false;

            if (!titleMatch && !descMatch && !locationMatch) {
              return false;
            }

            // Apply location filter
            if (filters?.location != null &&
                !(job.location?.toLowerCase().contains(filters!.location!.toLowerCase()) ?? false)) {
              return false;
            }

            return true;
          })
          .take(limit)
          .map((job) => SearchResult(
                id: job.id,
                title: job.title,
                subtitle: job.eventTitle ?? job.jobType,
                type: SearchResultType.job,
                data: job,
              ))
          .toList();
    } catch (e) {
      print('Error searching jobs: $e');
      return [];
    }
  }

  /// Get search suggestions based on recent/popular searches
  Future<List<String>> getSuggestions(String query, {int limit = 5}) async {
    if (query.length < 2) return [];

    final suggestions = <String>[];

    // Search event titles
    final events = await _firestore
        .collection('events')
        .where('status', isEqualTo: 'published')
        .orderBy('title')
        .startAt([query.toLowerCase()])
        .endAt(['${query.toLowerCase()}\uf8ff'])
        .limit(limit)
        .get();

    for (final doc in events.docs) {
      suggestions.add(doc['title'] as String);
    }

    // Search supplier names
    final suppliers = await _firestore
        .collection('suppliers')
        .where('isActive', isEqualTo: true)
        .orderBy('businessName')
        .startAt([query.toLowerCase()])
        .endAt(['${query.toLowerCase()}\uf8ff'])
        .limit(limit)
        .get();

    for (final doc in suppliers.docs) {
      suggestions.add(doc['businessName'] as String);
    }

    return suggestions.take(limit).toList();
  }
}

/// Search service provider
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

/// Search state
class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool isLoading;
  final String? error;
  final SearchFilters filters;
  final List<String> recentSearches;
  final List<String> suggestions;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.filters = const SearchFilters(),
    this.recentSearches = const [],
    this.suggestions = const [],
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
    SearchFilters? filters,
    List<String>? recentSearches,
    List<String>? suggestions,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      recentSearches: recentSearches ?? this.recentSearches,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

/// Search notifier
class SearchNotifier extends Notifier<SearchState> {
  late final SearchService _searchService;

  @override
  SearchState build() {
    _searchService = ref.watch(searchServiceProvider);
    return const SearchState();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: []);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final results = await _searchService.search(
        query,
        filters: state.filters,
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
      );

      // Add to recent searches
      _addToRecentSearches(query);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  Future<void> getSuggestions(String query) async {
    if (query.length < 2) {
      state = state.copyWith(suggestions: []);
      return;
    }

    final suggestions = await _searchService.getSuggestions(query);
    state = state.copyWith(suggestions: suggestions);
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  void clearFilters() {
    state = state.copyWith(filters: const SearchFilters());
    if (state.query.isNotEmpty) {
      search(state.query);
    }
  }

  void clearSearch() {
    state = state.copyWith(query: '', results: [], suggestions: []);
  }

  void _addToRecentSearches(String query) {
    final recent = [...state.recentSearches];
    recent.remove(query);
    recent.insert(0, query);
    state = state.copyWith(
      recentSearches: recent.take(10).toList(),
    );
  }

  void removeFromRecentSearches(String query) {
    final recent = [...state.recentSearches];
    recent.remove(query);
    state = state.copyWith(recentSearches: recent);
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }
}

/// Search notifier provider
final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
