import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void init() {
    _checkConnectivity();
    try {
      _subscription = Connectivity().onConnectivityChanged.listen((results) {
        isOnline.value = !results.contains(ConnectivityResult.none);
      });
    } catch (_) {
      // Connectivity not available (e.g., test environment)
    }
  }

  static Future<void> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      isOnline.value = !results.contains(ConnectivityResult.none);
    } catch (_) {
      // Connectivity not available (e.g., test environment)
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
