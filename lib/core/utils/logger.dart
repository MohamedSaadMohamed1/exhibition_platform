import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Logger utility for consistent logging across the app
class AppLogger {
  AppLogger._();

  static bool get _shouldLog =>
      kDebugMode || AppEnvironment.config.enableLogging;

  /// Log debug message
  static void debug(String message, {String? tag, Object? error}) {
    if (_shouldLog) {
      _log('DEBUG', message, tag: tag, error: error);
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (_shouldLog) {
      _log('INFO', message, tag: tag);
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag, Object? error}) {
    if (_shouldLog) {
      _log('WARNING', message, tag: tag, error: error);
    }
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log network request
  static void network(String method, String url, {Map<String, dynamic>? body}) {
    if (_shouldLog) {
      _log('NETWORK', '$method: $url', tag: 'Network');
      if (body != null) {
        _log('NETWORK', 'Body: $body', tag: 'Network');
      }
    }
  }

  /// Log network response
  static void networkResponse(
    String url,
    int statusCode, {
    dynamic response,
  }) {
    if (_shouldLog) {
      _log('NETWORK', 'Response [$statusCode]: $url', tag: 'Network');
    }
  }

  /// Log Firebase operation
  static void firebase(String operation, {Map<String, dynamic>? data}) {
    if (_shouldLog) {
      _log('FIREBASE', operation, tag: 'Firebase');
      if (data != null) {
        _log('FIREBASE', 'Data: $data', tag: 'Firebase');
      }
    }
  }

  /// Log navigation
  static void navigation(String route, {Map<String, dynamic>? params}) {
    if (_shouldLog) {
      _log('NAV', 'Navigate to: $route', tag: 'Navigation');
      if (params != null) {
        _log('NAV', 'Params: $params', tag: 'Navigation');
      }
    }
  }

  /// Log user action
  static void userAction(String action, {Map<String, dynamic>? data}) {
    if (_shouldLog) {
      _log('ACTION', action, tag: 'UserAction');
      if (data != null) {
        _log('ACTION', 'Data: $data', tag: 'UserAction');
      }
    }
  }

  /// Internal log method
  static void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? 'App';
    final logMessage = '[$timestamp] [$level] [$logTag] $message';

    if (kDebugMode) {
      developer.log(
        logMessage,
        name: logTag,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // In production, you would send errors to a crash reporting service
    if (level == 'ERROR' && AppEnvironment.config.enableCrashlytics) {
      // TODO: Send to crash reporting service (Firebase Crashlytics)
    }
  }
}
