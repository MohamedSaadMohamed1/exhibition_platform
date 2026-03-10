import 'dart:async';
import 'dart:collection';

/// In-memory cache with TTL support
class CacheManager<T> {
  final Duration defaultTtl;
  final int maxEntries;
  final LinkedHashMap<String, _CacheEntry<T>> _cache = LinkedHashMap();

  CacheManager({
    this.defaultTtl = const Duration(minutes: 5),
    this.maxEntries = 100,
  });

  /// Get item from cache
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    // Move to end for LRU
    _cache.remove(key);
    _cache[key] = entry;

    return entry.value;
  }

  /// Put item in cache
  void put(String key, T value, {Duration? ttl}) {
    // Remove oldest entries if at capacity
    while (_cache.length >= maxEntries) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = _CacheEntry(
      value: value,
      expiry: DateTime.now().add(ttl ?? defaultTtl),
    );
  }

  /// Check if key exists and is not expired
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Remove item from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all items
  void clear() {
    _cache.clear();
  }

  /// Clear expired items
  void clearExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Get or compute value
  Future<T> getOrCompute(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    final cached = get(key);
    if (cached != null) return cached;

    final value = await compute();
    put(key, value, ttl: ttl);
    return value;
  }

  /// Get cache statistics
  CacheStats get stats => CacheStats(
        size: _cache.length,
        maxSize: maxEntries,
      );
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiry;

  _CacheEntry({
    required this.value,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class CacheStats {
  final int size;
  final int maxSize;

  CacheStats({
    required this.size,
    required this.maxSize,
  });

  double get usagePercent => size / maxSize;
}

/// Global cache instances
class AppCache {
  static final events = CacheManager<dynamic>(
    defaultTtl: const Duration(minutes: 10),
    maxEntries: 50,
  );

  static final suppliers = CacheManager<dynamic>(
    defaultTtl: const Duration(minutes: 10),
    maxEntries: 50,
  );

  static final services = CacheManager<dynamic>(
    defaultTtl: const Duration(minutes: 15),
    maxEntries: 100,
  );

  static final users = CacheManager<dynamic>(
    defaultTtl: const Duration(minutes: 5),
    maxEntries: 30,
  );

  static final images = CacheManager<String>(
    defaultTtl: const Duration(hours: 1),
    maxEntries: 200,
  );

  /// Clear all caches
  static void clearAll() {
    events.clear();
    suppliers.clear();
    services.clear();
    users.clear();
    images.clear();
  }

  /// Clear all expired entries
  static void clearAllExpired() {
    events.clearExpired();
    suppliers.clearExpired();
    services.clearExpired();
    users.clearExpired();
    images.clearExpired();
  }
}
