import 'package:flutter_test/flutter_test.dart';
import 'package:exhibition_platform/core/utils/cache_manager.dart';

void main() {
  group('CacheManager', () {
    late CacheManager<String> cache;

    setUp(() {
      cache = CacheManager<String>(
        defaultTtl: const Duration(seconds: 1),
        maxEntries: 5,
      );
    });

    test('stores and retrieves values', () {
      cache.put('key1', 'value1');
      expect(cache.get('key1'), equals('value1'));
    });

    test('returns null for non-existent key', () {
      expect(cache.get('nonexistent'), isNull);
    });

    test('containsKey returns true for existing key', () {
      cache.put('key1', 'value1');
      expect(cache.containsKey('key1'), isTrue);
    });

    test('containsKey returns false for non-existent key', () {
      expect(cache.containsKey('nonexistent'), isFalse);
    });

    test('removes value correctly', () {
      cache.put('key1', 'value1');
      cache.remove('key1');
      expect(cache.get('key1'), isNull);
    });

    test('clears all values', () {
      cache.put('key1', 'value1');
      cache.put('key2', 'value2');
      cache.clear();
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNull);
    });

    test('respects max entries limit', () {
      for (var i = 0; i < 10; i++) {
        cache.put('key$i', 'value$i');
      }
      expect(cache.stats.size, lessThanOrEqualTo(5));
    });

    test('expires entries after TTL', () async {
      cache.put('key1', 'value1', ttl: const Duration(milliseconds: 100));
      expect(cache.get('key1'), equals('value1'));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(cache.get('key1'), isNull);
    });

    test('getOrCompute returns cached value', () async {
      cache.put('key1', 'cached');

      final result = await cache.getOrCompute('key1', () async => 'computed');
      expect(result, equals('cached'));
    });

    test('getOrCompute computes and caches missing value', () async {
      final result = await cache.getOrCompute('key1', () async => 'computed');
      expect(result, equals('computed'));
      expect(cache.get('key1'), equals('computed'));
    });

    test('clearExpired removes only expired entries', () async {
      cache.put('permanent', 'value1', ttl: const Duration(hours: 1));
      cache.put('temporary', 'value2', ttl: const Duration(milliseconds: 50));

      await Future.delayed(const Duration(milliseconds: 100));
      cache.clearExpired();

      expect(cache.get('permanent'), equals('value1'));
      expect(cache.get('temporary'), isNull);
    });
  });

  group('AppCache', () {
    test('clearAll clears all caches', () {
      AppCache.events.put('event1', 'data');
      AppCache.suppliers.put('supplier1', 'data');

      AppCache.clearAll();

      expect(AppCache.events.get('event1'), isNull);
      expect(AppCache.suppliers.get('supplier1'), isNull);
    });
  });
}
