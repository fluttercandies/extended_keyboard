import 'dart:math';

import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:flutter/material.dart';

/// A stateful widget that builds a customizable text input UI.
///
/// `TextInputBuilder` is designed to provide a custom text input experience
/// by managing different keyboard configurations and handling UI resizing
/// to avoid keyboard overlap.
class TextInputBuilder extends StatefulWidget {
  const TextInputBuilder({
    Key? key,
    this.resizeToAvoidBottomInset = true,
    required this.body,
    this.keyboardHeight = 200,
    required this.configurations,
  }) : super(key: key);

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

  /// The main body widget that is displayed behind the keyboard.
  final Widget body;

  /// The default height of the keyboard.
  final double keyboardHeight;

  /// A list of `KeyboardConfiguration`.
  ///
  /// This list allows you to manage multiple configurations for different keyboards.
  /// Each configuration defines a different keyboard behavior and appearance.
  final List<KeyboardConfiguration> configurations;

  @override
  State<TextInputBuilder> createState() => _TextInputBuilderState();
}

class _TextInputBuilderState extends State<TextInputBuilder> {
  ModalRoute<Object?>? _route;
  double _currentKeyboardHeight = 0;
  double _preSystemKeyboardHeight = 0;
  @override
  void initState() {
    super.initState();
    SystemKeyboard()
        .afterSystemKeyboardLayoutFinshed
        .addListener(_afterKeyboardLayoutFinshed);
  }

  void _afterKeyboardLayoutFinshed() {
    if (_currentKeyboardHeight == 0) {
      return;
    }
    if (_currentKeyboardHeight != systemKeyboardHeight) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    KeyboardBindingMixin.binding.register(
      route: _route!,
      configurations: widget.configurations,
    );
  }

  @override
  void didUpdateWidget(covariant TextInputBuilder oldWidget) {
    if (oldWidget.configurations != widget.configurations) {
      KeyboardBindingMixin.binding.unregister(route: _route!);
      KeyboardBindingMixin.binding.register(
        route: _route!,
        configurations: widget.configurations,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    SystemKeyboard()
        .afterSystemKeyboardLayoutFinshed
        .removeListener(_afterKeyboardLayoutFinshed);
    SystemKeyboard().clearCurrentRouteLastKeyboardHeight(_route!);
    KeyboardBindingMixin.binding.unregister(route: _route!);
    super.dispose();
  }

  double? get systemKeyboardHeight {
    return SystemKeyboard().getCurrentRouteLastKeyboardHeight(
      ModalRoute.of(context),
    );
  }

  KeyboardConfiguration? preConfiguration;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KeyboardConfiguration?>(
      valueListenable: KeyboardBindingMixin.binding.showKeyboardNotifier,
      builder: (
        BuildContext context,
        KeyboardConfiguration? configuration,
        Widget? child,
      ) {
        final bool show = KeyboardBindingMixin.binding.keyboardHandler != null;

        final KeyboardConfiguration? keyboardHandler =
            configuration ?? preConfiguration;

        preConfiguration = configuration;
        final bool resizeToAvoidBottomInset =
            keyboardHandler?.resizeToAvoidBottomInset ??
                widget.resizeToAvoidBottomInset;

        final double customKeyboardHeight = max(
            0,
            (keyboardHandler?.getKeyboardHeight(systemKeyboardHeight) ??
                    systemKeyboardHeight ??
                    widget.keyboardHeight) -
                SystemKeyboard.safeBottom);

        Duration duration = (show
                ? keyboardHandler?.showDuration
                : keyboardHandler?.hideDuration) ??
            const Duration();

        final double currentSystemKeyboardHeight =
            MediaQuery.of(context).viewInsets.bottom;

        if (currentSystemKeyboardHeight != 0) {
          duration = const Duration();
        }
        final double viewPaddingBottom =
            MediaQuery.of(context).viewPadding.bottom;

        _currentKeyboardHeight = currentSystemKeyboardHeight;

        if (currentSystemKeyboardHeight > _preSystemKeyboardHeight) {
          if (preConfiguration != null) {
            // custom keyboard to system keyboard
            // try to find cache keyboard height by input type name
            _currentKeyboardHeight =
                SystemKeyboard().getSystemKeyboardHeightByName() ??
                    customKeyboardHeight + viewPaddingBottom;
          }
        } else if (currentSystemKeyboardHeight < _preSystemKeyboardHeight) {
        } else {}
        _preSystemKeyboardHeight = currentSystemKeyboardHeight;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            AnimatedPositioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: resizeToAvoidBottomInset
                  ? (show
                      ? customKeyboardHeight + viewPaddingBottom
                      : _currentKeyboardHeight)
                  : 0,
              duration: duration,
              child: child!,
            ),
            AnimatedPositioned(
              left: 0,
              right: 0,
              bottom: show ? viewPaddingBottom : -customKeyboardHeight,
              duration: duration,
              child: SizedBox(
                height: customKeyboardHeight,
                child: keyboardHandler?.builder(),
              ),
            )
          ],
        );
      },
      child: widget.body,
    );
  }
}
