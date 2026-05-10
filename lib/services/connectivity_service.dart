import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to track and manage offline state
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  
  // Current connectivity state
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  // Initialize and start listening
  Future<void> initialize() async {
    // Check initial state
    final results = await _connectivity.checkConnectivity();
    _updateConnectivity(results);
    
    // Listen for changes
    _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }
  
  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
      debugPrint('[Connectivity] Online: $_isOnline');
    }
  }
  
  /// Check if currently online
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
  
  /// Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}

/// Mixin for widgets that need connectivity awareness
mixin ConnectivityAware<T extends StatefulWidget> on State<T> {
  StreamSubscription<bool>? _connectivitySubscription;
  bool _wasOffline = false;
  
  void initConnectivityListener(VoidCallback onConnectivityChanged) {
    _connectivitySubscription = ConnectivityService.instance.connectivityStream.listen((isOnline) {
      if (isOnline && _wasOffline) {
        _wasOffline = false;
        onConnectivityChanged();
      } else if (!isOnline) {
        _wasOffline = true;
      }
    });
  }
  
  void disposeConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}

/// Widget that shows offline banner when disconnected
class OfflineBanner extends StatelessWidget {
  final Widget child;
  
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.instance.connectivityStream,
      initialData: ConnectivityService.instance.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        return Column(
          children: [
            if (!isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.orange.shade700,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'You are offline',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
