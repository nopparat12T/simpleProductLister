import 'package:flutter/material.dart';
import 'package:simple_product_lister/main.dart';
import 'package:simple_product_lister/services/networkService.dart';

class NetworkAwareApp extends StatefulWidget {
  final Widget child;

  const NetworkAwareApp({super.key, required this.child});

  @override
  State<NetworkAwareApp> createState() => _NetworkAwareAppState();
}

class _NetworkAwareAppState extends State<NetworkAwareApp> {
  @override
  void initState() {
    super.initState();

    NetworkStatus.stream.listen((online) {
      final messenger = rootScaffoldMessengerKey.currentState;
      if (messenger == null) return;

      if (!online) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('อินเทอร์เน็ตขาดการเชื่อมต่อ'),
            backgroundColor: Colors.red,
            duration: Duration(days: 1),
          ),
        );
      } else {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('กลับมาออนไลน์แล้ว'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
