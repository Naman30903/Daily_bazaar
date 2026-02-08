import 'dart:async';

/// A utility class for debouncing function calls.
/// Useful for search input fields to reduce API calls.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  /// Creates a debouncer with the specified delay.
  /// Default delay is 300 milliseconds.
  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Runs the callback after the delay.
  /// If called again before the delay expires, the previous call is cancelled.
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancels any pending callback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes the debouncer and cancels any pending callback.
  void dispose() {
    cancel();
  }

  /// Whether a callback is currently pending.
  bool get isPending => _timer?.isActive ?? false;
}
