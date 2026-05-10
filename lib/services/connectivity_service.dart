import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Simple connectivity check - lightweight, minimal
/// Does NOT redirect or block - just shows an optional banner
class ConnectivityService {
  // Private constructor
  ConnectivityService._();
  
  // Singleton access
  static final ConnectivityService _instance = ConnectivityService._();
  static ConnectivityService get instance => _instance;

  // Current state (default to true for optimistic UX)
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  // Stream for listening
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get stream => _controller.stream;

  // Initialize (call once from main.dart)
  Future<void> init() async {
    _check();
    Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }
  
  void _check() async {
    final results = await Connectivity().checkConnectivity();
    _onConnectivityChanged(results);
  }
  
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      _controller.add(_isOnline);
    }
  }
  
  /// Force refresh
  Future<void> refresh() => _check();
  
  void dispose() => _controller.close();
}

/// Banner widget showing offline status
/// Use this INSIDE your pages - NOT as a wrapper that redirects
class OfflineBanner extends StatelessWidget {
  final Widget child;
  
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.instance.stream,
      initialData: true,
      builder: (context, snapshot) {
        final online = snapshot.data ?? true;
        
        return Column(
          children: [
            if (!online)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.orange.shade700,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Offline - Data may be limited',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      }
    );
  }
}