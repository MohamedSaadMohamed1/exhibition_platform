import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility for search and other frequent operations
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Run action after delay, canceling any pending action
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Run async action after delay
  void runAsync(Future<void> Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () async {
      await action();
    });
  }

  /// Cancel pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if there's a pending action
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose debouncer
  void dispose() {
    cancel();
  }
}

/// Throttler utility for rate-limiting operations
class Throttler {
  final Duration interval;
  DateTime? _lastRun;
  Timer? _pendingTimer;
  VoidCallback? _pendingAction;

  Throttler({this.interval = const Duration(milliseconds: 300)});

  /// Run action, throttling to interval
  void run(VoidCallback action) {
    final now = DateTime.now();

    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
    } else {
      // Schedule for later
      _pendingAction = action;
      _pendingTimer?.cancel();
      _pendingTimer = Timer(
        interval - now.difference(_lastRun!),
        () {
          _lastRun = DateTime.now();
          _pendingAction?.call();
          _pendingAction = null;
        },
      );
    }
  }

  /// Cancel pending action
  void cancel() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _pendingAction = null;
  }

  /// Dispose throttler
  void dispose() {
    cancel();
  }
}

/// Search debouncer with value tracking
class SearchDebouncer {
  final Duration delay;
  final void Function(String) onSearch;
  Timer? _timer;
  String _lastQuery = '';

  SearchDebouncer({
    this.delay = const Duration(milliseconds: 400),
    required this.onSearch,
  });

  /// Update search query
  void search(String query) {
    if (query == _lastQuery) return;

    _timer?.cancel();
    _lastQuery = query;

    if (query.isEmpty) {
      onSearch(query);
      return;
    }

    _timer = Timer(delay, () {
      onSearch(query);
    });
  }

  /// Clear and cancel
  void clear() {
    _timer?.cancel();
    _lastQuery = '';
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Rate limiter for API calls
class RateLimiter {
  final int maxCalls;
  final Duration window;
  final List<DateTime> _calls = [];

  RateLimiter({
    this.maxCalls = 10,
    this.window = const Duration(seconds: 1),
  });

  /// Check if action is allowed
  bool get canProceed {
    _cleanOldCalls();
    return _calls.length < maxCalls;
  }

  /// Try to execute action
  bool tryExecute(VoidCallback action) {
    if (!canProceed) return false;

    _calls.add(DateTime.now());
    action();
    return true;
  }

  /// Execute or wait
  Future<void> executeOrWait(Future<void> Function() action) async {
    _cleanOldCalls();

    if (_calls.length >= maxCalls) {
      // Wait for oldest call to expire
      final oldestCall = _calls.first;
      final waitTime = window - DateTime.now().difference(oldestCall);
      if (waitTime.isNegative == false) {
        await Future.delayed(waitTime);
      }
    }

    _calls.add(DateTime.now());
    await action();
  }

  void _cleanOldCalls() {
    final cutoff = DateTime.now().subtract(window);
    _calls.removeWhere((call) => call.isBefore(cutoff));
  }

  /// Get remaining calls allowed
  int get remainingCalls {
    _cleanOldCalls();
    return maxCalls - _calls.length;
  }
}
