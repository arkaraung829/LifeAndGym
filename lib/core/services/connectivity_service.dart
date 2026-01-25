import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'logger_service.dart';

/// Service for monitoring network connectivity.
///
/// Provides methods to check current connectivity status and
/// stream connectivity changes.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _connectionController = StreamController<bool>.broadcast();

  /// Stream of connectivity status changes.
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Initialize the connectivity service and start listening for changes.
  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      _connectionController.add(isConnected);
      AppLogger.network('Connectivity changed: ${isConnected ? 'connected' : 'disconnected'}');
    });
    AppLogger.network('ConnectivityService initialized');
  }

  /// Check if the device currently has network connectivity.
  Future<bool> get hasConnection async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      AppLogger.error('Error checking connectivity', error: e);
      return false;
    }
  }

  /// Get the current connectivity type.
  Future<ConnectivityType> get connectivityType async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectivityType.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        return ConnectivityType.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectivityType.ethernet;
      } else if (results.contains(ConnectivityResult.vpn)) {
        return ConnectivityType.vpn;
      } else {
        return ConnectivityType.none;
      }
    } catch (e) {
      AppLogger.error('Error getting connectivity type', error: e);
      return ConnectivityType.none;
    }
  }

  /// Dispose of resources.
  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}

/// Types of network connectivity.
enum ConnectivityType {
  none,
  wifi,
  mobile,
  ethernet,
  vpn,
}
