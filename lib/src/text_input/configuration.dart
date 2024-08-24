import 'package:flutter/widgets.dart';
import 'text_input_type.dart';

/// A class that represents the configuration for a custom keyboard.
/// This configuration includes how the keyboard should be built,
/// its animation durations, and how it should behave with respect to resizing.
class KeyboardConfiguration {
  /// Constructor for `KeyboardConfiguration`.
  ///
  /// - [builder]: A function that returns a widget, used to build the custom keyboard.
  /// - [getKeyboardHeight]: A function that calculates the height of the keyboard.
  /// - [showDuration]: Duration for the show animation of the keyboard (default is 200ms).
  /// - [hideDuration]: Duration for the hide animation of the keyboard (default is 200ms).
  /// - [resizeToAvoidBottomInset]: Determines whether the UI should resize to avoid the keyboard.
  /// - [keyboardName]: The name of the keyboard, used to initialize `ExtendedTextInputType` with a unique identifier.
  KeyboardConfiguration({
    required this.builder, // A function to build the keyboard widget.
    required this.getKeyboardHeight, // A function to determine keyboard height.
    this.showDuration =
        const Duration(milliseconds: 200), // Duration for showing the keyboard.
    this.hideDuration =
        const Duration(milliseconds: 200), // Duration for hiding the keyboard.
    this.resizeToAvoidBottomInset, // Option to resize UI to avoid keyboard overlapping.
    required String keyboardName, // The name of the custom keyboard.
  }) : keyboardType = ExtendedTextInputType(
          // Initializes `keyboardType` with a unique name by appending a timestamp.
          name: '$keyboardName---${DateTime.now().millisecondsSinceEpoch}',
        );

  /// Function that calculates the height of the custom keyboard.
  /// This is a callback that takes the system keyboard height as a parameter and returns the desired height.
  final double Function(double? systemKeyboardHeight) getKeyboardHeight;

  /// Builder function that returns the widget representing the custom keyboard.
  final Widget Function() builder;

  /// Duration for the keyboard's show animation.
  final Duration showDuration;

  /// Duration for the keyboard's hide animation.
  final Duration hideDuration;

  /// A boolean that determines if the UI should resize to avoid the keyboard.
  /// If true, the UI will adjust to prevent overlap with the keyboard.
  final bool? resizeToAvoidBottomInset;

  /// The type of the keyboard, represented as an `ExtendedTextInputType` with a unique name.
  final ExtendedTextInputType keyboardType;
}
