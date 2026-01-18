import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static DateTime? _lastChecked;
  static bool _lastStatus = false;

  /// ตรวจว่ามี internet จริงหรือไม่
  static Future<bool> hasInternet({bool force = false}) async {
    // cache กัน ping บ่อย
    if (!force &&
        _lastChecked != null &&
        DateTime.now().difference(_lastChecked!) < const Duration(seconds: 5)) {
      return _lastStatus;
    }

    final results = await Connectivity().checkConnectivity();

    if (_isDisconnected(results)) {
      _update(false);
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      final ok = lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;

      _update(ok);
      return ok;
    } catch (_) {
      _update(false);
      return false;
    }
  }

  static bool _isDisconnected(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
  }

  static void _update(bool status) {
    _lastChecked = DateTime.now();
    _lastStatus = status;
  }
}

class NetworkStatus {
  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static Stream<bool> get stream => _controller.stream;

  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void start() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      // ถ้าไม่มี network เลย → offline ทันที
      if (_isDisconnected(results)) {
        _controller.add(false);
        return;
      }

      // มี network แต่ต้องเช็ก internet จริง
      final online = await NetworkService.hasInternet(force: true);
      _controller.add(online);
    });
  }

  static bool _isDisconnected(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
  }

  static void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
