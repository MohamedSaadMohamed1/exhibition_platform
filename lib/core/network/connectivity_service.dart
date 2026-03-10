import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';

/// Service to monitor network connectivity
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectionStatusController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        _connectionStatusController = StreamController<bool>.broadcast() {
    _init();
  }

  /// Stream of connectivity status changes
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> _init() async {
    // Check initial status
    await _checkConnectivity();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      AppLogger.error('Failed to check connectivity', error: e);
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _updateConnectionStatus(results);
  }

  /// Update connection status based on results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = !results.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      AppLogger.info(
        'Network connectivity changed: ${_isConnected ? 'online' : 'offline'}',
        tag: 'Connectivity',
      );
      _connectionStatusController.add(_isConnected);
    }
  }

  /// Force check connectivity
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return _isConnected;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}

/// Mixin to add connectivity awareness to widgets
mixin ConnectivityAwareMixin<T extends StatefulWidget> on State<T> {
  late ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivitySubscription = _connectivityService.connectionStatus.listen(
      (isConnected) {
        if (mounted) {
          setState(() {
            _isOnline = isConnected;
          });
          onConnectivityChanged(isConnected);
        }
      },
    );
  }

  /// Override this to handle connectivity changes
  void onConnectivityChanged(bool isConnected) {}

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}
