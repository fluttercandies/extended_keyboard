import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'utils.dart';

class SystemKeyboard with WidgetsBindingObserver {
  factory SystemKeyboard() => _systemKeyboard;

  SystemKeyboard._();
  static final SystemKeyboard _systemKeyboard = SystemKeyboard._();
  static final List<double> _keyboardHeights = <double>[];

  /// The keyboardHeight = the height of keyboard
  ValueNotifier<double> afterKeyboardLayoutFinshed = ValueNotifier<double>(0);
  double? _keyboardHeight;
  final void Function() _doJob = () {
    final double currentHeight =
        WidgetsBinding.instance.window.viewInsets.bottom /
            WidgetsBinding.instance.window.devicePixelRatio;
    if (currentHeight != 0) {
      if (_keyboardHeights.isEmpty) {
        _systemKeyboard._updateHeight(currentHeight);
      }

      if (!_keyboardHeights.contains(currentHeight)) {
        _keyboardHeights.add(currentHeight);
      }
    } else {
      _keyboardHeights.clear();
    }
    SystemKeyboard().afterKeyboardLayoutFinshed.value = max(0, currentHeight);
  }.debounce(const Duration(milliseconds: 100));

  double? get keyboardHeight {
    if (_keyboardHeight == null) {
      init();
    }
    return _keyboardHeight;
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
    _keyboardHeight = double.tryParse(content);
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

  void _updateHeight(double height) {
    if (_keyboardHeight != height) {
      _keyboardHeight = height;
      _getFile().then((File file) {
        file.writeAsStringSync(height.toString());
      });
    }
  }
}
