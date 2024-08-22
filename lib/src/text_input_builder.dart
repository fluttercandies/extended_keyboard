import 'dart:math';

import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:flutter/material.dart';

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

  final Widget body;

  /// The default height of the keyboard.
  final double keyboardHeight;

  final List<KeyboardConfiguration> configurations;

  @override
  State<TextInputBuilder> createState() => _TextInputBuilderState();
}

class _TextInputBuilderState extends State<TextInputBuilder> {
  ModalRoute<Object?>? _route;
  @override
  void initState() {
    super.initState();
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
    KeyboardBindingMixin.binding.unregister(route: _route!);
    super.dispose();
  }

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

        final double customKeyboardHeight = (keyboardHandler
                    ?.getKeyboardHeight(SystemKeyboard().keyboardHeight) ??
                SystemKeyboard().keyboardHeight ??
                widget.keyboardHeight) -
            SystemKeyboard.safeBottom;

        Duration duration = (show
                ? keyboardHandler?.showDuration
                : keyboardHandler?.hideDuration) ??
            const Duration();

        final double systemKeyboardHeight =
            MediaQuery.of(context).viewInsets.bottom;
        if (systemKeyboardHeight != 0) {
          duration = const Duration();
        }
        final double viewPaddingBottom =
            MediaQuery.of(context).viewPadding.bottom;
        return Material(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: resizeToAvoidBottomInset
                    ? (show
                        ? customKeyboardHeight + viewPaddingBottom
                        : systemKeyboardHeight)
                    : 0,
                //duration: duration,
                child: child!,
              ),
              AnimatedPositioned(
                left: 0,
                right: 0,
                bottom: viewPaddingBottom,
                duration: duration,
                child: SizedBox(
                  height: customKeyboardHeight,
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
