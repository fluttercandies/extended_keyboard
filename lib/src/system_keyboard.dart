import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'keyboard_binary_messenger.dart';
import 'keyboard_height.dart';
import 'utils.dart';
import 'dart:collection';

class SystemKeyboard with WidgetsBindingObserver {
  factory SystemKeyboard() => _systemKeyboard;

  SystemKeyboard._();
  static final SystemKeyboard _systemKeyboard = SystemKeyboard._();
  static final List<KeyboardHeight> _keyboardHeights = <KeyboardHeight>[];

  List<KeyboardHeight> get keyboardHeights => _keyboardHeights;
  final List<SystemKeyboardInfo> _systemKeyboardHeights =
      <SystemKeyboardInfo>[];

  /// The keyboardHeight = the height of keyboard
  ValueNotifier<double> afterKeyboardLayoutFinshed = ValueNotifier<double>(0);
  SystemKeyboardInfo? _keyboardHeight;

  final void Function() _doJob = () {
    final double currentHeight =
        WidgetsBinding.instance.window.viewInsets.bottom /
            WidgetsBinding.instance.window.devicePixelRatio;
    if (currentHeight != 0) {
      if (_keyboardHeights.isEmpty) {
        _systemKeyboard._updateHeight(
          SystemKeyboardInfo(
            name: KeyboardBindingMixin.binding.name ?? 'system',
            height: currentHeight,
          ),
        );
      }

      final KeyboardHeight height =
          KeyboardHeight(height: currentHeight, isActive: true);

      if (!_keyboardHeights.contains(height)) {
        _keyboardHeights.add(height);
      }

      for (final KeyboardHeight element in _keyboardHeights) {
        element.isActive = element == height;
      }
    } else {
      _keyboardHeights.clear();
    }
    SystemKeyboard().afterKeyboardLayoutFinshed.value = currentHeight;
  }.debounce(const Duration(milliseconds: 100));

  double? get keyboardHeight {
    if (_keyboardHeight == null) {
      init();
    }
    return _keyboardHeight?.height;
  }

  double? getSystemKeyboardHeightByName() {
    for (final SystemKeyboardInfo element in _systemKeyboardHeights) {
      if (element.name == KeyboardBindingMixin.binding.name) {
        return element.height;
      }
    }
    return null;
  }

  static double get safeBottom =>
      WidgetsBinding.instance.window.viewPadding.bottom /
      WidgetsBinding.instance.window.devicePixelRatio;

  @override
  void didChangeMetrics() {
    _doJob();
  }

  Future<void> init() async {
    final File file = await _getFile();
    final String content = file.readAsStringSync();
    if (content.isNotEmpty) {
      final List<dynamic> list = json.decode(content) as List<dynamic>;
      _systemKeyboardHeights.clear();
      for (final dynamic element in list) {
        _systemKeyboardHeights.add(
          SystemKeyboardInfo.fromJson(element as Map<String, dynamic>),
        );
      }
      if (_systemKeyboardHeights.isNotEmpty) {
        _keyboardHeight = _systemKeyboardHeights.last;
      }
    }

    WidgetsBinding.instance.addObserver(this);
  }

  Future<File> _getFile() async {
    final File file = File(join((await getTemporaryDirectory()).path,
        'extended_keyboard', 'keyboard_height.txt'));
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  void _updateHeight(SystemKeyboardInfo info) {
    final int oldIndex = _systemKeyboardHeights.indexOf(info);
    _systemKeyboardHeights.remove(info);
    _systemKeyboardHeights.add(info);
    final int newIndex = _systemKeyboardHeights.indexOf(info);
    if (oldIndex != newIndex) {
      _getFile().then((File file) {
        file.writeAsStringSync(json.encode(_systemKeyboardHeights));
      });
    }
  }
}

@immutable
class SystemKeyboardInfo {
  const SystemKeyboardInfo({
    required this.name,
    required this.height,
  });
  factory SystemKeyboardInfo.fromJson(Map<String, dynamic> json) {
    return SystemKeyboardInfo(
      name: json['name'] as String,
      height: json['height'] as double,
    );
  }
  final String name;
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemKeyboardInfo &&
          runtimeType == other.runtimeType &&
          name == other.name
      // && height == other.height
      ;

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'height': height,
    };
  }
}
