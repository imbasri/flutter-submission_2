import 'package:flutter/material.dart';
import '../../utils/api_result.dart';

class ApiResultBuilder<T> extends StatelessWidget {
  final ApiResult<T> result;
  final Widget Function(T data) onSuccess;
  final Widget Function(String message)? onError;
  final Widget Function()? onLoading;
  final Widget Function(String message)? onEmpty;
  const ApiResultBuilder({
    super.key,
    required this.result,
    required this.onSuccess,
    this.onError,
    this.onLoading,
    this.onEmpty,
  });
  @override
  Widget build(BuildContext context) {
    return switch (result) {
      ApiLoading<T>() =>
        onLoading?.call() ??
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                ],
              ),
            ),
      ApiSuccess<T>(:final data) => onSuccess(data),
      ApiFailure<T>(:final message) =>
        onError?.call(message) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
      ApiEmpty<T>(:final message) =>
        onEmpty?.call(message) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
    };
  }
}

class ApiRefreshButton<T> extends StatelessWidget {
  final ApiResult<T> result;
  final VoidCallback onRefresh;
  final String? label;
  const ApiRefreshButton({
    super.key,
    required this.result,
    required this.onRefresh,
    this.label,
  });
  @override
  Widget build(BuildContext context) {
    final shouldShow = switch (result) {
      ApiFailure<T>() => true,
      ApiEmpty<T>() => true,
      _ => false,
    };
    if (!shouldShow) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh),
        label: Text(label ?? 'Coba Lagi'),
      ),
    );
  }
}

class ApiStatusIndicator<T> extends StatelessWidget {
  final ApiResult<T> result;
  final bool showCount;
  const ApiStatusIndicator({
    super.key,
    required this.result,
    this.showCount = false,
  });
  @override
  Widget build(BuildContext context) {
    return switch (result) {
      ApiLoading<T>() => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Memuat...'),
        ],
      ),
      ApiSuccess<T>(:final data) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            showCount && data is List
                ? 'Berhasil (${(data as List).length} item)'
                : 'Berhasil',
          ),
        ],
      ),
      ApiFailure<T>() => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red, size: 16),
          SizedBox(width: 8),
          Text('Gagal'),
        ],
      ),
      ApiEmpty<T>() => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.orange, size: 16),
          SizedBox(width: 8),
          Text('Kosong'),
        ],
      ),
    };
  }
}
