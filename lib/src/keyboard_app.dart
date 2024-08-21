import 'dart:math';

import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:flutter/material.dart';

class KeyboardApp extends StatefulWidget {
  const KeyboardApp({
    Key? key,
    this.resizeToAvoidBottomInset = true,
    required this.body,
    this.safeAreaBottom = true,
    this.keyboardHeight = 200,
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

  final Widget body;

  /// Whether to add a bottom padding to avoid overlapping with system's safe area.
  final bool safeAreaBottom;

  /// The default height of the keyboard.
  final double keyboardHeight;

  @override
  State<KeyboardApp> createState() => _KeyboardAppState();
}

class _KeyboardAppState extends State<KeyboardApp> {
  double _viewPaddingBottom = 0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KeyboardBindingMixin.binding.showKeyboardNotifier,
      builder: (BuildContext context, bool show, Widget? child) {
        final KeyboardConfiguration? keyboardHandler =
            KeyboardBindingMixin.binding.keyboardHandler;
        final bool resizeToAvoidBottomInset =
            keyboardHandler?.resizeToAvoidBottomInset ??
                widget.resizeToAvoidBottomInset;
        _viewPaddingBottom = max(
          max(
            MediaQuery.of(context).viewPadding.bottom,
            _viewPaddingBottom,
          ),
          MediaQuery.of(context).padding.bottom,
        );
        final double keyboardHeight = keyboardHandler
                ?.getKeyboardHeight(SystemKeyboard().keyboardHeight) ??
            SystemKeyboard().keyboardHeight ??
            widget.keyboardHeight;
        final bool safeAreaBottom =
            keyboardHandler?.safeAreaBottom ?? widget.safeAreaBottom;
        final double bottomPadding = safeAreaBottom ? _viewPaddingBottom : 0.0;
        final Duration duration = (show
                ? keyboardHandler?.showDuration
                : keyboardHandler?.hideDuration) ??
            const Duration();

        // double systemKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Material(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              AnimatedPositioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: (resizeToAvoidBottomInset && show) ? keyboardHeight : 0,
                // hanle by SafeArea
                //+
                //  bottomPadding,

                duration: duration,
                child: child!,
              ),
              AnimatedPositioned(
                left: 0,
                right: 0,
                bottom: show ? bottomPadding : -keyboardHeight,
                duration: duration,
                child: SizedBox(
                  height: keyboardHeight,
                  child: show
                      ? KeyboardBindingMixin.binding.keyboardHandler?.builder()
                      : null,
                ),
              )
            ],
          ),
        );
      },
      child: widget.body,
    );
  }
}
