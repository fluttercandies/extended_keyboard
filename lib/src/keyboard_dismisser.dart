import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// the tapped area is also an input field.
/// and it's not readOnly
bool _stopDismiss(HitTestTarget target) {
  if (target is RenderEditable && target.attached) {
    return !target.readOnly;
  }
  return false;
}

/// A custom Flutter widget that automatically dismisses the on-screen keyboard
/// when the user taps outside of an input field. This is especially useful
/// in forms or other text input scenarios where the keyboard may obscure
/// important parts of the UI, and the user needs a convenient way to close it.
///
/// Features:
/// - **Automatic Keyboard Dismissal**: Taps outside of input fields will
///   unfocus the current text input, effectively closing the keyboard.
/// - **Smart Detection**: The widget intelligently checks if the tap occurred
///   outside the currently focused input field and dismisses the keyboard only
///   when appropriate.
/// - **Seamless Integration**: Wrap this widget around any part of your UI
///   where you want this behavior, and it will work in harmony with your
///   existing components.
///
/// Usage:
///
/// To use `KeyboardDismisser`, simply wrap it around the part of your widget tree
/// where you want the keyboard to be dismissed on an outside tap:
///
/// ```dart
/// KeyboardDismisser(
///   child: YourWidget(),
/// )
/// ```
///
/// This widget is particularly useful in scenarios where you want to improve user
/// experience by automatically dismissing the keyboard when the user is done typing
/// or interacts with other parts of the UI.
class KeyboardDismisser extends StatelessWidget {
  const KeyboardDismisser({
    Key? key,
    required this.child,
    this.stopDismiss = _stopDismiss,
  }) : super(key: key);

  /// The widget that contains the keyboard.
  final Widget child;

  /// Whether stop dismiss keyboard.
  final bool Function(HitTestTarget target) stopDismiss;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent d) {
        // Dismiss the keyboard when touching outside of the input field.
        final FocusScopeNode currentFocus = FocusScope.of(context);
        final FocusNode? focusedChild = currentFocus.focusedChild;

        if (!currentFocus.hasPrimaryFocus && focusedChild != null) {
          // Close the keyboard when the tapped area is not an input field.
          // It's also possible that the tapped area is another input field.
          final Offset position = d.original?.position ?? d.localPosition;
          if (!focusedChild.rect.contains(position)) {
            // Check if the tapped area is an input field.
            final HitTestResult result = HitTestResult();
            WidgetsBinding.instance.hitTest(result, position);

            for (final HitTestEntry<HitTestTarget> element in result.path) {
              final HitTestTarget target = element.target;

              // If the tapped area is also an input field.
              if (stopDismiss(target)) {
                return;
              }
            }
            // Unfocus the current focus, which closes the keyboard.
            FocusManager.instance.primaryFocus?.unfocus();
          }
        }
      },
      child: child,
    );
  }
}
