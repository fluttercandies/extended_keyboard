import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';

/// Custom Widgets binding class that mixes in keyboard-related functionality.
class KeyboardBinding extends WidgetsFlutterBinding with KeyboardBindingMixin {}

/// Mixin that provides custom keyboard handling functionality to the Flutter binding.
///
/// The `KeyboardBindingMixin` intercepts and manages communication with the
/// platform's text input system, allowing for the use of custom keyboards.
mixin KeyboardBindingMixin on WidgetsFlutterBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    return KeyboardBinaryMessenger(super.createBinaryMessenger(), this);
  }

  /// Provides access to the current instance of `KeyboardBindingMixin`.
  static KeyboardBindingMixin get binding =>
      WidgetsBinding.instance as KeyboardBindingMixin;

  /// Stores configurations for different routes, each containing a list of `KeyboardConfiguration`.
  final Map<ModalRoute<Object?>, List<KeyboardConfiguration>> _configurations =
      <ModalRoute<Object?>, List<KeyboardConfiguration>>{};

  /// Notifier that updates when a custom keyboard needs to be shown.
  ValueNotifier<KeyboardConfiguration?> showKeyboardNotifier =
      ValueNotifier<KeyboardConfiguration?>(null);

  /// Stores the current keyboard configuration handler.
  KeyboardConfiguration? keyboardHandler;

  /// Registers a route with its corresponding keyboard configurations.
  void register({
    required ModalRoute<Object?> route,
    required List<KeyboardConfiguration> configurations,
  }) {
    _configurations[route] = configurations;
  }

  /// Unregisters a route and removes its keyboard configurations.
  void unregister({required ModalRoute<Object?> route}) {
    _configurations.remove(route);
  }

  /// Retrieves the current route that is active.
  ModalRoute<Object?>? get currentRoute {
    for (final ModalRoute<Object?> route in _configurations.keys) {
      if (route.isCurrent) {
        return route;
      }
    }
    return null;
  }

  /// Provides access to the codec used for encoding and decoding text input messages.
  MethodCodec get codec => SystemChannels.textInput.codec;

  int? _connectionId;

  /// Stores the current text input connection ID.
  int? get connectionId => _connectionId;

  String? _name;

  /// Stores the name of the current input type.
  String? get name => _name;

  /// Handles incoming messages related to text input from the platform.
  Future<ByteData?> _handleTextInputMsg(
      String channel, ByteData? message) async {
    if (channel == SystemChannels.textInput.name) {
      final MethodCall methodCall = codec.decodeMethodCall(message);

      switch (methodCall.method) {
        case 'TextInput.show':
          if (keyboardHandler != null) {
            showKeyboardNotifier.value = keyboardHandler;
            return codec.encodeSuccessEnvelope(null);
          }
          break;
        case 'TextInput.hide':
          showKeyboardNotifier.value = keyboardHandler;
          break;
        case 'TextInput.clearClient':
          _connectionId = null;
          _name = null;
          if (keyboardHandler != null) {
            showKeyboardNotifier.value = keyboardHandler;
            keyboardHandler = null;
            return codec.encodeSuccessEnvelope(null);
          }
          break;
        case 'TextInput.setClient':
          _connectionId = methodCall.arguments[0] as int;
          _name = methodCall.arguments[1]['inputType']['name'] as String;

          for (final ModalRoute<Object?> route in _configurations.keys) {
            if (route.isCurrent) {
              final List<KeyboardConfiguration> configs =
                  _configurations[route]!;
              for (final KeyboardConfiguration config in configs) {
                if (_name == config.keyboardType.name) {
                  keyboardHandler = config;
                  _hideSystemKeyBoardIfNeed();
                  return codec.encodeSuccessEnvelope(null);
                }
              }
            }
          }
          break;
        default:
      }
    }

    return null;
  }

  /// Hides the system keyboard if it is currently visible.
  void _hideSystemKeyBoardIfNeed() {
    if (WidgetsBinding.instance.window.viewInsets.bottom != 0) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }
  }
}

/// A custom `BinaryMessenger` that intercepts platform messages related to text input.
///
/// This class allows for the customization of how text input messages are handled,
/// enabling the use of custom keyboards.
class KeyboardBinaryMessenger extends BinaryMessenger {
  KeyboardBinaryMessenger(
    this.origin,
    this.binding,
  );

  /// The original `BinaryMessenger` that handles platform communication.
  final BinaryMessenger origin;

  /// The binding that manages custom keyboard logic.
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
