import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity status
enum NetworkStatus {
  online,
  offline,
}

/// Network info interface
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<NetworkStatus> get onStatusChange;
}

/// Network info implementation using connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<NetworkStatus> get onStatusChange {
    return _connectivity.onConnectivityChanged.map((results) {
      if (results.contains(ConnectivityResult.none)) {
        return NetworkStatus.offline;
      }
      return NetworkStatus.online;
    });
  }
}

/// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Network status stream provider
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  return ref.watch(networkInfoProvider).onStatusChange;
});

/// Is connected provider
final isConnectedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(networkInfoProvider).isConnected;
});
