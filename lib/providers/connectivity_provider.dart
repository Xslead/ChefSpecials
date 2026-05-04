import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;

  bool _isOnline = true;
  bool _isSyncing = false;
  StreamSubscription<bool>? _subscription;

  ConnectivityProvider({
    ConnectivityService? connectivityService,
    CacheService? cacheService,
  })  : _connectivityService = connectivityService ?? ConnectivityService(),
        _cacheService = cacheService ?? CacheService();

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  Future<void> init() async {
    _isOnline = await _connectivityService.isOnline();
    notifyListeners();
    _subscription = _connectivityService.onConnectivityChanged.listen((online) {
      final wasOffline = !_isOnline;
      _isOnline = online;
      notifyListeners();
      if (online && wasOffline) _onReconnect();
    });
  }

  void _onReconnect() {
    _isSyncing = true;
    notifyListeners();
    // Show "Back online" banner for 2 s, then hide
    Future.delayed(const Duration(seconds: 2), () {
      _isSyncing = false;
      notifyListeners();
    });
  }

  Future<void> syncQueue(String userId) async {
    if (!_isOnline) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await SyncService(cacheService: _cacheService).syncOfflineQueue(userId);
    } catch (e) {
      debugPrint('ConnectivityProvider: sync failed: $e');
    }
    _isSyncing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
