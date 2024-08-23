import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'keyboard_binary_messenger.dart';
import 'utils.dart';

class SystemKeyboard with WidgetsBindingObserver {
  factory SystemKeyboard() => _systemKeyboard;

  SystemKeyboard._();
  static final SystemKeyboard _systemKeyboard = SystemKeyboard._();

  final List<SystemKeyboardHeight> _systemKeyboardHeights =
      <SystemKeyboardHeight>[];

  /// The keyboardHeight = the height of keyboard
  ValueNotifier<double> afterKeyboardLayoutFinshed = ValueNotifier<double>(0);
  SystemKeyboardHeight? _lastKeyboardHeight;

  final void Function() _doJob = () {
    final double currentHeight =
        WidgetsBinding.instance.window.viewInsets.bottom /
            WidgetsBinding.instance.window.devicePixelRatio;
    if (currentHeight != 0) {
      _systemKeyboard.updateHeight(currentHeight);
    }
    SystemKeyboard().afterKeyboardLayoutFinshed.value = currentHeight;
  }.debounce(const Duration(milliseconds: 100));

  double? get lastKeyboardHeight {
    if (_lastKeyboardHeight == null) {
      init();
    }
    return _lastKeyboardHeight?.height;
  }

  double? getSystemKeyboardHeightByName() {
    for (final SystemKeyboardHeight element in _systemKeyboardHeights) {
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
          SystemKeyboardHeight.fromJson(element as Map<String, dynamic>),
        );
      }
      if (_systemKeyboardHeights.isNotEmpty) {
        _lastKeyboardHeight = _systemKeyboardHeights.last;
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

  void updateHeight(double currentHeight) {
    SystemKeyboardHeight info = SystemKeyboardHeight(
      name: KeyboardBindingMixin.binding.name ?? 'SystemKeyboard',
      height: currentHeight,
    );
    _lastKeyboardHeight = info;
    final int oldIndex = _systemKeyboardHeights.indexOf(info);
    if (oldIndex >= 0) {
      // The TextInputType maybe has many heights, alway use first one.
      final SystemKeyboardHeight oldInfo =
          _systemKeyboardHeights.removeAt(oldIndex);
      if (info.name != 'SystemKeyboard') {
        info = oldInfo;
      }
    }
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
class SystemKeyboardHeight {
  const SystemKeyboardHeight({
    required this.name,
    required this.height,
  });
  factory SystemKeyboardHeight.fromJson(Map<String, dynamic> json) {
    return SystemKeyboardHeight(
      name: json['name'] as String,
      height: json['height'] as double,
    );
  }
  final String name;
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemKeyboardHeight &&
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
