import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  /// Returns true if the device is connected to Mobile, Wi-Fi, or Ethernet.
  /// Use this before calling your Load functions.
  Future<bool> get isConnected async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    return _isValidConnection(results);
  }

  /// A stream that emits TRUE only when connection is restored.
  /// Your Ad Controller can listen to this to "Auto-Retry" a failed ad.
  Stream<bool> get onConnected {
    return _connectivity.onConnectivityChanged.map((results) {
      return _isValidConnection(results);
    });
  }

  /// Internal logic to check if any of the active interfaces are valid.
  bool _isValidConnection(List<ConnectivityResult> results) {
    // connectivity_plus 6.0+ returns a List
    if (results.isEmpty) return false;

    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }
}
