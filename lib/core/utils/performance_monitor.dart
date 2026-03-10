import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Performance monitoring utilities
class PerformanceMonitor {
  static final _instance = PerformanceMonitor._();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._();

  final Map<String, _MetricData> _metrics = {};
  bool _enabled = kDebugMode;

  /// Enable or disable monitoring
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Start a timer for an operation
  Stopwatch startTimer(String name) {
    if (!_enabled) return Stopwatch();

    final stopwatch = Stopwatch()..start();
    return stopwatch;
  }

  /// End timer and record metric
  void endTimer(String name, Stopwatch stopwatch) {
    if (!_enabled) return;

    stopwatch.stop();
    _recordMetric(name, stopwatch.elapsedMilliseconds.toDouble());
  }

  /// Measure async operation
  Future<T> measureAsync<T>(String name, Future<T> Function() operation) async {
    if (!_enabled) return operation();

    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _recordMetric(name, stopwatch.elapsedMilliseconds.toDouble());
    }
  }

  /// Measure sync operation
  T measureSync<T>(String name, T Function() operation) {
    if (!_enabled) return operation();

    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _recordMetric(name, stopwatch.elapsedMilliseconds.toDouble());
    }
  }

  /// Record a metric value
  void _recordMetric(String name, double value) {
    _metrics.putIfAbsent(name, () => _MetricData());
    _metrics[name]!.record(value);

    if (kDebugMode) {
      developer.log(
        '$name: ${value.toStringAsFixed(2)}ms',
        name: 'Performance',
      );
    }
  }

  /// Get metric statistics
  MetricStats? getStats(String name) {
    final data = _metrics[name];
    if (data == null || data.values.isEmpty) return null;

    return MetricStats(
      name: name,
      count: data.values.length,
      min: data.values.reduce((a, b) => a < b ? a : b),
      max: data.values.reduce((a, b) => a > b ? a : b),
      average: data.values.reduce((a, b) => a + b) / data.values.length,
      last: data.values.last,
    );
  }

  /// Get all metric statistics
  List<MetricStats> getAllStats() {
    return _metrics.entries
        .map((e) => getStats(e.key))
        .whereType<MetricStats>()
        .toList();
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
  }

  /// Print summary to console
  void printSummary() {
    if (!kDebugMode) return;

    developer.log('=== Performance Summary ===', name: 'Performance');
    for (final stats in getAllStats()) {
      developer.log(
        '${stats.name}: avg=${stats.average.toStringAsFixed(2)}ms, '
        'min=${stats.min.toStringAsFixed(2)}ms, '
        'max=${stats.max.toStringAsFixed(2)}ms, '
        'count=${stats.count}',
        name: 'Performance',
      );
    }
    developer.log('===========================', name: 'Performance');
  }
}

class _MetricData {
  final List<double> values = [];
  static const maxValues = 100;

  void record(double value) {
    values.add(value);
    if (values.length > maxValues) {
      values.removeAt(0);
    }
  }
}

class MetricStats {
  final String name;
  final int count;
  final double min;
  final double max;
  final double average;
  final double last;

  MetricStats({
    required this.name,
    required this.count,
    required this.min,
    required this.max,
    required this.average,
    required this.last,
  });
}

/// Frame rate monitor
class FrameRateMonitor {
  static final _instance = FrameRateMonitor._();
  factory FrameRateMonitor() => _instance;
  FrameRateMonitor._();

  final List<Duration> _frameTimes = [];
  DateTime? _lastFrameTime;
  bool _isMonitoring = false;

  /// Start monitoring frame rate
  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _frameTimes.clear();
  }

  /// Stop monitoring
  void stop() {
    _isMonitoring = false;
  }

  /// Record a frame
  void recordFrame() {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);

      // Keep only last 120 frames (2 seconds at 60fps)
      if (_frameTimes.length > 120) {
        _frameTimes.removeAt(0);
      }
    }
    _lastFrameTime = now;
  }

  /// Get current FPS
  double get fps {
    if (_frameTimes.isEmpty) return 0;

    final avgFrameTime = _frameTimes
            .map((d) => d.inMicroseconds)
            .reduce((a, b) => a + b) /
        _frameTimes.length;

    return 1000000 / avgFrameTime; // Convert microseconds to FPS
  }

  /// Get jank percentage (frames taking > 16.67ms)
  double get jankPercentage {
    if (_frameTimes.isEmpty) return 0;

    final jankFrames = _frameTimes
        .where((d) => d.inMilliseconds > 16)
        .length;

    return (jankFrames / _frameTimes.length) * 100;
  }
}

/// Memory monitor
class MemoryMonitor {
  static void logMemoryUsage([String? label]) {
    if (!kDebugMode) return;

    // Note: Actual memory stats require platform-specific code
    developer.log(
      '${label ?? 'Memory'}: Check DevTools for detailed memory info',
      name: 'Memory',
    );
  }
}

/// Performance trace for debugging
class PerformanceTrace {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  final List<_TraceEvent> _events = [];

  PerformanceTrace(this.name) {
    _stopwatch.start();
  }

  /// Add checkpoint
  void checkpoint(String label) {
    _events.add(_TraceEvent(
      label: label,
      elapsed: _stopwatch.elapsed,
    ));
  }

  /// End trace and log results
  void end() {
    _stopwatch.stop();

    if (!kDebugMode) return;

    developer.log('=== Trace: $name ===', name: 'Trace');
    Duration lastElapsed = Duration.zero;

    for (final event in _events) {
      final delta = event.elapsed - lastElapsed;
      developer.log(
        '  ${event.label}: +${delta.inMilliseconds}ms (total: ${event.elapsed.inMilliseconds}ms)',
        name: 'Trace',
      );
      lastElapsed = event.elapsed;
    }

    developer.log(
      '  Total: ${_stopwatch.elapsedMilliseconds}ms',
      name: 'Trace',
    );
    developer.log('========================', name: 'Trace');
  }
}

class _TraceEvent {
  final String label;
  final Duration elapsed;

  _TraceEvent({required this.label, required this.elapsed});
}
