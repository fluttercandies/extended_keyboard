import 'dart:math';

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

/// A builder function that returns a widget based on the keyboard height.
typedef KeyboardBuilderCallback = Widget Function(
  BuildContext context,
  double? systemKeyboardHeight,
);

/// A widget that builds a custom keyboard based on the provided builder function.
class KeyboardBuilder extends StatefulWidget {
  const KeyboardBuilder({
    Key? key,
    required this.bodyBuilder,
    required this.builder,
    this.resizeToAvoidBottomInset = true,
    this.controller,
  }) : super(key: key);

  /// A builder function that returns a widget based on the system keyboard height.
  final KeyboardBuilderCallback builder;

  /// The main body widget.
  final Widget Function(bool readOnly) bodyBuilder;

  /// If true the [body] and the [KeyboardBuilder]'s floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// [KeyboardBuilder], the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  /// The controller for the custom keyboard.
  final CustomKeyboardController? controller;

  @override
  State<KeyboardBuilder> createState() => _KeyboardBuilderState();
}

class _KeyboardBuilderState extends State<KeyboardBuilder>
    with WidgetsBindingObserver {
  double _preKeyboardHeight = 0;
  ModalRoute<Object?>? _route;
  void Function()? _doJob;
  late CustomKeyboardController _controller;

  CustomKeyboardController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? CustomKeyboardController(KeyboardType.system);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant KeyboardBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller =
          widget.controller ?? CustomKeyboardController(KeyboardType.system);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
  }

  @override
  void dispose() {
    SystemKeyboard().clearCurrentRouteLastKeyboardHeight(_route!);
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
          SystemKeyboard().updateHeight(
            currentHeight,
            route: ModalRoute.of(context),
          );
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
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller._readOnly,
              builder: (BuildContext context, bool readOnly, Widget? child) {
                return widget.bodyBuilder(readOnly);
              },
            ),
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
                  final double height =
                      SystemKeyboard().getSystemKeyboardHeightByName() ??
                          keyboardHeight;

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
                  double? height =
                      SystemKeyboard().getCurrentRouteLastKeyboardHeight(
                    ModalRoute.of(context),
                  );

                  if (height != null) {
                    // keybaord height includes the safe bottom padding
                    height -= SystemKeyboard.safeBottom;
                    // view padding bottom animate
                    height += MediaQuery.of(context).viewPadding.bottom;
                    height = max(0, height);
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
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller._readOnly,
              builder: (BuildContext context, bool readOnly, Widget? child) {
                return widget.bodyBuilder(readOnly);
              },
            ),
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
                    double? height =
                        SystemKeyboard().getCurrentRouteLastKeyboardHeight(
                      ModalRoute.of(context),
                    );

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
  CustomKeyboardController(
    this._value, {
    bool readOnly = false,
  }) : _readOnly = ValueNotifier<bool>(readOnly);

  /// The current keyboard type.

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

  /// whether current keyboard is custom
  bool get isCustom => _value == KeyboardType.custom;

  /// hide the custom keyboard
  void hideCustomKeyboard() {
    _setValue(KeyboardType.system);
    _readOnly.value = false;
  }

  /// show the custom keyboard
  void showCustomKeyboard() {
    _updateValue(KeyboardType.custom);
    _readOnly.value = true;
  }

  /// if we want to close the keyboard without losing textfield focus,
  /// we can't use `SystemChannels.textInput.invokeMethod<void>('TextInput.hide')` any more.
  /// related issue https://github.com/flutter/flutter/issues/16863
  ///
  /// TextField(
  /// showCursor: true,
  /// readOnly: true,
  /// )
  final ValueNotifier<bool> _readOnly;

  /// show the system keyboard (set readOnly to false， it works if the input is on hasFocus)
  void showSystemKeyboard() {
    _readOnly.value = false;
  }

  /// make the input lost focus and hide the system keyboard or custom keyboard
  void unfocus() {
    hideCustomKeyboard();
    FocusManager.instance.primaryFocus?.unfocus();
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
