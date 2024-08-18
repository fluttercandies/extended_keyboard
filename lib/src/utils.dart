import 'dart:async';

/// Extension on [Function] to add debounce and throttle capabilities.
extension DebounceThrottlingE on Function {
  /// Creates a debounced version of the function.
  ///
  /// The returned function will delay its execution until after the specified
  /// duration has passed since the last time it was invoked. If the function
  /// is called again before the duration ends, the timer resets.
  ///
  /// [duration] specifies the delay, with a default value of 1 second.
  /// Returns a [VoidFunction] that, when called, will be debounced.
  VoidFunction debounce([Duration duration = const Duration(seconds: 1)]) {
    Timer? debounce;
    return () {
      if (debounce?.isActive ?? false) {
        debounce!.cancel();
      }
      debounce = Timer(duration, () {
        this.call();
      });
    };
  }

  /// Creates a throttled version of the function.
  ///
  /// The returned function ensures that the wrapped function is only called
  /// once within the specified duration. If the function is called again
  /// within the duration, the call is ignored until the timer completes.
  ///
  /// [duration] specifies the throttle duration, with a default value of 1 second.
  /// Returns a [VoidFunction] that, when called, will be throttled.
  VoidFunction throttle([Duration duration = const Duration(seconds: 1)]) {
    Timer? throttle;
    return () {
      if (throttle?.isActive ?? false) {
        return;
      }
      this.call();
      throttle = Timer(duration, () {});
    };
  }
}

/// Typedef for a function that takes no arguments and returns void.
typedef VoidFunction = void Function();
