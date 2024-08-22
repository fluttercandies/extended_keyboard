import 'dart:math';

import 'keyboard_height.dart';
import 'system_keyboard.dart';
import 'utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum representing different types of keyboards.
enum KeyboardType {
  /// system keyboard
  system,

  /// custom keyboard
  custom,
  _customToSystem,
}

typedef KeyboardBuilderCallback = Widget Function(
  BuildContext context,
  double? keyboardHeight,
);

/// A widget that builds a custom keyboard based on the provided builder function.
class KeyboardBuilder extends StatefulWidget {
  const KeyboardBuilder({
    Key? key,
    required this.body,
    required this.builder,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  /// A builder function that returns a widget based on the keyboard height.
  final KeyboardBuilderCallback builder;

  /// The main body widget that is displayed behind the keyboard.
  final Widget body;

  /// If true the [body] and the scaffold's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  @override
  State<KeyboardBuilder> createState() => _KeyboardBuilderState();
}

class _KeyboardBuilderState extends State<KeyboardBuilder>
    with WidgetsBindingObserver {
  double _preKeyboardHeight = 0;

  final List<KeyboardHeight> _keyboardHeights = <KeyboardHeight>[];

  void Function()? _doJob;
  final CustomKeyboardController _controller =
      CustomKeyboardController(KeyboardType.system);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateKeyboardState();
  }

  void _updateKeyboardState() {
    if (_controller.isCustom &&
        _preKeyboardHeight == 0 &&
        WidgetsBinding.instance.window.viewInsets.bottom != 0) {
      _controller._updateValue(KeyboardType.system);
    }
    _doJob ??= () {
      if (mounted) {
        final double currentHeight =
            WidgetsBinding.instance.window.viewInsets.bottom /
                WidgetsBinding.instance.window.devicePixelRatio;

        if (currentHeight != 0) {
          if (_controller.value != KeyboardType.system) {
            _controller._setValue(KeyboardType.system);
          }

          final KeyboardHeight height =
              KeyboardHeight(height: currentHeight, isActive: true);

          if (!_keyboardHeights.contains(height)) {
            _keyboardHeights.add(height);
          }

          for (final KeyboardHeight element in _keyboardHeights) {
            element.isActive = element == height;
          }
        } else if (_controller.value == KeyboardType.system) {
          _keyboardHeights.clear();
        }
      }
    }.debounce(
      const Duration(
        milliseconds: 100,
      ),
    );

    _doJob?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resizeToAvoidBottomInset) {
      return Column(
        children: <Widget>[
          Expanded(
            child: widget.body,
          ),
          ValueListenableBuilder<KeyboardType>(
            valueListenable: _controller,
            builder: (BuildContext context, KeyboardType value, Widget? child) {
              final double keyboardHeight =
                  MediaQuery.of(context).viewInsets.bottom;

              _preKeyboardHeight = keyboardHeight;

              switch (value) {
                case KeyboardType.system:
                  return Container(
                    height: keyboardHeight,
                  );
                case KeyboardType._customToSystem:
                  final double height = _keyboardHeights.isEmpty
                      ? SystemKeyboard().keyboardHeight ?? keyboardHeight
                      : _keyboardHeights.first.height;

                  return Container(
                    height: max(
                      // keybaord height includes the safe bottom padding
                      height -
                          SystemKeyboard.safeBottom +
                          // view padding bottom animate
                          MediaQuery.of(context).viewPadding.bottom,
                      keyboardHeight,
                    ),
                  );

                case KeyboardType.custom:
                  double? height = _keyboardHeights.isEmpty
                      ? SystemKeyboard().keyboardHeight
                      : _keyboardHeights
                          .firstWhere(
                              (KeyboardHeight element) => element.isActive)
                          .height;

                  if (height != null) {
                    // keybaord height includes the safe bottom padding
                    height -= SystemKeyboard.safeBottom;
                    // view padding bottom animate
                    height += MediaQuery.of(context).viewPadding.bottom;
                  }

                  return widget.builder(
                    context,
                    height,
                  );

                default:
                  return Container(
                    height: 0,
                  );
              }
            },
          ),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: widget.body,
          ),
          Positioned.fill(
            child: ValueListenableBuilder<KeyboardType>(
              valueListenable: _controller,
              builder:
                  (BuildContext context, KeyboardType value, Widget? child) {
                final double keyboardHeight =
                    MediaQuery.of(context).viewInsets.bottom;

                _preKeyboardHeight = keyboardHeight;

                switch (value) {
                  case KeyboardType.custom:
                    double? height = _keyboardHeights.isEmpty
                        ? SystemKeyboard().keyboardHeight
                        : _keyboardHeights
                            .firstWhere(
                                (KeyboardHeight element) => element.isActive)
                            .height;

                    if (height != null) {
                      height += MediaQuery.of(context).viewPadding.bottom;
                    }

                    return Column(
                      children: <Widget>[
                        const Spacer(),
                        widget.builder(
                          context,
                          height,
                        ),
                      ],
                    );

                  default:
                    return Container();
                }
              },
            ),
          ),
        ],
      );
    }
  }
}

/// A controller for managing the keyboard type and notifying listeners.
class CustomKeyboardController extends ChangeNotifier
    implements ValueListenable<KeyboardType> {
  /// Creates a [ChangeNotifier] that wraps this value.
  CustomKeyboardController(this._value);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  KeyboardType get value => _value;
  KeyboardType _value;

  void _updateValue(KeyboardType newValue) {
    if (newValue == KeyboardType.system && _value == KeyboardType.custom) {
      _value = KeyboardType._customToSystem;
    } else {
      _value = newValue;
    }

    notifyListeners();
  }

  void _setValue(KeyboardType newValue) {
    if (_value == newValue) {
      return;
    }

    _value = newValue;

    notifyListeners();
  }

  bool get isCustom => _value == KeyboardType.custom;

  void hideKeyboard() {
    _setValue(KeyboardType.system);
  }

  void showKeyboard() {
    final KeyboardType old = _value;
    _updateValue(KeyboardType.custom);
    if (old == KeyboardType.system) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

/// A widget that listens to changes in the [CustomKeyboardController] and builds a widget accordingly.
class KeyboardTypeBuilder extends StatelessWidget {
  const KeyboardTypeBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  /// A builder function that returns a widget based on the keyboard type controller.
  final Widget Function(BuildContext context, CustomKeyboardController notifier)
      builder;

  @override
  Widget build(BuildContext context) {
    final CustomKeyboardController notifier =
        context.findAncestorStateOfType<_KeyboardBuilderState>()!._controller;
    return ValueListenableBuilder<KeyboardType>(
      valueListenable: notifier,
      builder: (BuildContext context, KeyboardType value, Widget? child) {
        return builder(context, notifier);
      },
    );
  }
}
