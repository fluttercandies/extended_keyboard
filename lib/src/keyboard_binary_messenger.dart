import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardBinding extends WidgetsFlutterBinding with KeyboardBindingMixin {}

mixin KeyboardBindingMixin on WidgetsFlutterBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    // SystemKeyboard().init();
    return KeyboardBinaryMessenger(super.createBinaryMessenger(), this);
  }

  static KeyboardBindingMixin get binding =>
      WidgetsBinding.instance as KeyboardBindingMixin;

  final Map<ExtendedTextInputType, KeyboardConfiguration> _configurations =
      <ExtendedTextInputType, KeyboardConfiguration>{};

  ValueNotifier<bool> showKeyboardNotifier = ValueNotifier<bool>(false);

  KeyboardConfiguration? keyboardHandler;
  void register({
    required ExtendedTextInputType textInputType,
    required KeyboardConfiguration configuration,
  }) {
    _configurations[textInputType] = configuration;
  }

  void unregister({required ExtendedTextInputType textInputType}) {
    _configurations.remove(textInputType);
  }

  void attach(MethodCall methodCall) {}

  void detach() {}

  MethodCodec get codec => SystemChannels.textInput.codec;

  bool get isShow => showKeyboardNotifier.value;

  int? connectionId;

  Future<ByteData?> _handleTextInputMsg(
      String channel, ByteData? message) async {
    if (channel == SystemChannels.textInput.name) {
      final MethodCall methodCall = codec.decodeMethodCall(message);

      if (kDebugMode) {
        print('xxx ${methodCall.method}');
      }
      switch (methodCall.method) {
        case 'TextInput.show':
          if (keyboardHandler != null) {
            showKeyboardNotifier.value = true;
            return codec.encodeSuccessEnvelope(null);
          }
          break;
        case 'TextInput.hide':
          showKeyboardNotifier.value = false;
          break;
        case 'TextInput.clearClient':
          connectionId = null;
          if (keyboardHandler != null) {
            showKeyboardNotifier.value = false;
            keyboardHandler = null;
            return null;
          }

          break;
        case 'TextInput.setClient':
          connectionId = methodCall.arguments[0] as int;
          final String name =
              methodCall.arguments[1]['inputType']['name'] as String;
          for (final ExtendedTextInputType key in _configurations.keys) {
            if (key.name == name) {
              keyboardHandler = _configurations[key];
              _hideSystemKeyBoardIfNeed();
              return null;
            }
          }
          break;
        default:
      }
    }

    return null;
  }

  void _hideSystemKeyBoardIfNeed() {
    if (WidgetsBinding.instance.window.viewInsets.bottom != 0) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }
  }
}

class KeyboardBinaryMessenger extends BinaryMessenger {
  KeyboardBinaryMessenger(
    this.origin,
    this.binding,
  );

  final BinaryMessenger origin;

  final KeyboardBindingMixin binding;
  @override
  Future<void> handlePlatformMessage(String channel, ByteData? data,
      PlatformMessageResponseCallback? callback) {
    return origin.handlePlatformMessage(channel, data, callback);
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) async {
    return (await binding._handleTextInputMsg(channel, message)) ??
        await origin.send(channel, message);
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    return origin.setMessageHandler(channel, handler);
  }
}

class ExtendedTextInputType extends TextInputType {
  const ExtendedTextInputType({
    required this.name,
  }) : super.numberWithOptions(
          signed: null,
          decimal: null,
        );

  final String name;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ExtendedTextInputType && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

class KeyboardConfiguration {
  KeyboardConfiguration({
    required this.builder,
    required this.getKeyboardHeight,
    this.showDuration = const Duration(milliseconds: 300),
    this.hideDuration = const Duration(milliseconds: 300),
    this.resizeToAvoidBottomInset,
    this.safeAreaBottom,
  });

  final double Function(double? systemKeyboardHeight) getKeyboardHeight;

  final Widget Function() builder;

  final Duration showDuration;

  final Duration hideDuration;

  final bool? resizeToAvoidBottomInset;

  /// Whether to add a bottom padding to avoid overlapping with system's safe area.
  final bool? safeAreaBottom;
}
