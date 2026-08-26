import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exception.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> ensureOnline() async {
    if (!await isOnline) {
      throw const ApiException(
        'No internet connection',
        isOffline: true,
        code: 'offline',
      );
    }
  }

  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map((results) {
        return results.any((r) => r != ConnectivityResult.none);
      });
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onStatusChange;
});
