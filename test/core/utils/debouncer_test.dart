import 'package:flutter_test/flutter_test.dart';
import 'package:exhibition_platform/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('delays execution', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.run(() => callCount++);

      expect(callCount, equals(0));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('cancels previous calls', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('cancel stops pending action', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, equals(0));

      debouncer.dispose();
    });

    test('isPending returns correct state', () {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));

      expect(debouncer.isPending, isFalse);

      debouncer.run(() {});
      expect(debouncer.isPending, isTrue);

      debouncer.cancel();
      expect(debouncer.isPending, isFalse);

      debouncer.dispose();
    });
  });

  group('Throttler', () {
    test('executes immediately on first call', () {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));
      int callCount = 0;

      throttler.run(() => callCount++);

      expect(callCount, equals(1));

      throttler.dispose();
    });

    test('throttles subsequent calls', () async {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));
      int callCount = 0;

      throttler.run(() => callCount++);
      throttler.run(() => callCount++);
      throttler.run(() => callCount++);

      expect(callCount, equals(1));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, equals(2)); // First + one scheduled

      throttler.dispose();
    });
  });

  group('SearchDebouncer', () {
    test('calls onSearch with query', () async {
      String? lastQuery;
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 50),
        onSearch: (query) => lastQuery = query,
      );

      debouncer.search('test');

      await Future.delayed(const Duration(milliseconds: 100));
      expect(lastQuery, equals('test'));

      debouncer.dispose();
    });

    test('ignores duplicate queries', () async {
      int callCount = 0;
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 50),
        onSearch: (query) => callCount++,
      );

      debouncer.search('test');
      debouncer.search('test');
      debouncer.search('test');

      await Future.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('calls immediately for empty query', () {
      String? lastQuery;
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 100),
        onSearch: (query) => lastQuery = query,
      );

      debouncer.search('');

      expect(lastQuery, equals(''));

      debouncer.dispose();
    });
  });

  group('RateLimiter', () {
    test('allows calls within limit', () {
      final limiter = RateLimiter(maxCalls: 3, window: const Duration(seconds: 1));

      expect(limiter.canProceed, isTrue);
      expect(limiter.remainingCalls, equals(3));

      int callCount = 0;
      limiter.tryExecute(() => callCount++);
      limiter.tryExecute(() => callCount++);
      limiter.tryExecute(() => callCount++);

      expect(callCount, equals(3));
      expect(limiter.remainingCalls, equals(0));
    });

    test('blocks calls over limit', () {
      final limiter = RateLimiter(maxCalls: 2, window: const Duration(seconds: 1));

      int callCount = 0;
      limiter.tryExecute(() => callCount++);
      limiter.tryExecute(() => callCount++);
      final blocked = limiter.tryExecute(() => callCount++);

      expect(callCount, equals(2));
      expect(blocked, isFalse);
      expect(limiter.canProceed, isFalse);
    });

    test('resets after window expires', () async {
      final limiter = RateLimiter(
        maxCalls: 2,
        window: const Duration(milliseconds: 100),
      );

      limiter.tryExecute(() {});
      limiter.tryExecute(() {});
      expect(limiter.canProceed, isFalse);

      await Future.delayed(const Duration(milliseconds: 150));
      expect(limiter.canProceed, isTrue);
    });
  });
}
