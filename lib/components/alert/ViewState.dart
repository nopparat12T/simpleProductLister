import 'package:flutter/material.dart';

/// ===============================
/// View State Enum
/// ===============================
enum ViewState {
  loading,
  success,
  error,
  empty,
}

/// ===============================
/// ViewStateBuilder (Reusable)
/// ===============================
class ViewStateBuilder extends StatelessWidget {
  final ViewState state;
  final Widget success;
  final Widget? loading;
  final Widget? empty;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ViewStateBuilder({
    super.key,
    required this.state,
    required this.success,
    this.loading,
    this.empty,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return loading ?? const Center(child: CircularProgressIndicator());

      case ViewState.error:
        return _ErrorStateWidget(
          message: errorMessage ?? 'เกิดข้อผิดพลาดบางอย่าง',
          onRetry: onRetry,
        );

      case ViewState.empty:
        return empty ??
            const Center(
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(fontSize: 16),
              ),
            );

      case ViewState.success:
        return success;
    }
  }
}

/// ===============================
/// Error State Widget (Internal)
/// ===============================
class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorStateWidget({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่อีกครั้ง'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
