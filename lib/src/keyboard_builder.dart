import 'dart:math';

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

/// A widget that builds a custom keyboard based on the provided builder function.
class KeyboardBuilder extends StatefulWidget {
  const KeyboardBuilder({
    Key? key,
    required this.body,
    required this.builder,
    this.safeAreaBottom = true,
  }) : super(key: key);

  /// A builder function that returns a widget based on the keyboard height.
  final Widget Function(
    BuildContext context,
    double? keyboardHeight,
  ) builder;

  /// The main body widget that is displayed behind the keyboard.
  final Widget body;

  /// Whether to add a bottom padding to avoid overlapping with system's safe area.
  final bool safeAreaBottom;

  @override
  State<KeyboardBuilder> createState() => _KeyboardBuilderState();
}

class _KeyboardBuilderState extends State<KeyboardBuilder>
    with WidgetsBindingObserver {
  double _preKeyboardHeight = 0;

  double _viewPaddingBottom = 0;

  final List<_KeyboardHeight> _keyboardHeights = <_KeyboardHeight>[];

  void Function()? _doJob;
  final KeyboardTypeController _keyboardType =
      KeyboardTypeController(KeyboardType.system);

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
    if (_keyboardType.isCustom &&
        _preKeyboardHeight == 0 &&
        WidgetsBinding.instance.window.viewInsets.bottom != 0) {
      _keyboardType._updateValue(KeyboardType.system);
    }
    _doJob ??= () {
      if (mounted) {
        final double currentHeight =
            WidgetsBinding.instance.window.viewInsets.bottom /
                WidgetsBinding.instance.window.devicePixelRatio;

        if (currentHeight != 0) {
          if (_keyboardType.value != KeyboardType.system) {
            _keyboardType._setValue(KeyboardType.system);
          }

          final _KeyboardHeight height =
              _KeyboardHeight(height: currentHeight, active: true);

          if (!_keyboardHeights.contains(height)) {
            _keyboardHeights.add(height);
          }

          for (final _KeyboardHeight element in _keyboardHeights) {
            element.active = element == height;
          }
        } else if (_keyboardType.value == KeyboardType.system) {
          _keyboardHeights.clear();
        }
      }
    }.debounce(
      const Duration(
        milliseconds: 200,
      ),
    );

    _doJob?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: widget.body,
        ),
        ValueListenableBuilder<KeyboardType>(
          valueListenable: _keyboardType,
          builder: (BuildContext context, KeyboardType value, Widget? child) {
            final double keyboardHeight =
                MediaQuery.of(context).viewInsets.bottom;

            _viewPaddingBottom = max(
              max(
                MediaQuery.of(context).viewPadding.bottom,
                _viewPaddingBottom,
              ),
              MediaQuery.of(context).padding.bottom,
            );

            _preKeyboardHeight = keyboardHeight;

            switch (value) {
              case KeyboardType.system:
                return Container(
                  height: keyboardHeight +
                      (widget.safeAreaBottom
                          ? MediaQuery.of(context).padding.bottom
                          : 0),
                );

              case KeyboardType._customToSystem:
                final double height = _keyboardHeights.isEmpty
                    ? keyboardHeight
                    : _keyboardHeights.first.height;

                return AnimatedContainer(
                  height: height,
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                );

              case KeyboardType.custom:
                double? height = _keyboardHeights.isEmpty
                    ? null
                    : _keyboardHeights
                        .firstWhere((_KeyboardHeight element) => element.active)
                        .height;

                if (widget.safeAreaBottom) {
                  if (height != null) {
                    height -= _viewPaddingBottom;
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: _viewPaddingBottom),
                    child: widget.builder(
                      context,
                      height,
                    ),
                  );
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
  }
}

/// Class representing the height of the keyboard and its active state.
class _KeyboardHeight {
  _KeyboardHeight({
    required this.height,
    required this.active,
  });
  final double height;
  bool active = false;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _KeyboardHeight &&
          runtimeType == other.runtimeType &&
          height == other.height;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => height.hashCode;
}

/// A controller for managing the keyboard type and notifying listeners.
class KeyboardTypeController extends ChangeNotifier
    implements ValueListenable<KeyboardType> {
  /// Creates a [ChangeNotifier] that wraps this value.
  KeyboardTypeController(this._value);

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

/// A widget that listens to changes in the [KeyboardTypeController] and builds a widget accordingly.
class KeyboardTypeBuilder extends StatelessWidget {
  const KeyboardTypeBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  /// A builder function that returns a widget based on the keyboard type controller.
  final Widget Function(BuildContext context, KeyboardTypeController notifier)
      builder;

  @override
  Widget build(BuildContext context) {
    final KeyboardTypeController notifier =
        context.findAncestorStateOfType<_KeyboardBuilderState>()!._keyboardType;
    return ValueListenableBuilder<KeyboardType>(
      valueListenable: notifier,
      builder: (BuildContext context, KeyboardType value, Widget? child) {
        return builder(context, notifier);
      },
    );
  }
}
