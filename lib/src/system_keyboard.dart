import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'text_input/keyboard_binding.dart';
import 'utils.dart';

/// A singleton class that manages system keyboard height and provides
/// functionality to handle keyboard layout changes.
///
/// The `SystemKeyboard` class tracks keyboard heights across different routes
/// and stores these values in a file for persistence. It also provides
/// mechanisms to update and retrieve the current keyboard height.
class SystemKeyboard with WidgetsBindingObserver {
  factory SystemKeyboard() => _systemKeyboard;
  SystemKeyboard._();
  static final SystemKeyboard _systemKeyboard = SystemKeyboard._();

  /// A list that stores recorded system keyboard heights.
  final List<SystemKeyboardHeight> _systemKeyboardHeights =
      <SystemKeyboardHeight>[];

  /// A `ValueNotifier` that notifies listeners after the system keyboard layout has finished.
  ValueNotifier<double> afterSystemKeyboardLayoutFinished =
      ValueNotifier<double>(0);

  /// Stores the last known keyboard height.
  SystemKeyboardHeight? _lastKeyboardHeight;

  /// A map that stores the last keyboard height associated with each route.
  final Map<ModalRoute<Object?>, SystemKeyboardHeight?>
      _currentRouteLastKeyboardHeightMap =
      <ModalRoute<Object?>, SystemKeyboardHeight?>{};

  /// A debounced function that updates the keyboard height.
  final void Function() _doJob = () {
    final double currentHeight =
        WidgetsBinding.instance.window.viewInsets.bottom /
            WidgetsBinding.instance.window.devicePixelRatio;
    if (currentHeight != 0) {
      _systemKeyboard.updateHeight(currentHeight);
    }
    _systemKeyboard.afterSystemKeyboardLayoutFinished.value = currentHeight;
  }.debounce(const Duration(milliseconds: 100));

  /// Gets the last known app-wide keyboard height.
  double? get appLastKeyboardHeight {
    if (_lastKeyboardHeight == null) {
      init();
    }
    return _lastKeyboardHeight?.height;
  }

  /// Retrieves the last keyboard height for the current route.
  double? getCurrentRouteLastKeyboardHeight(ModalRoute<Object?>? route) {
    return _currentRouteLastKeyboardHeightMap[route]?.height ??
        appLastKeyboardHeight;
  }

  /// Retrieves the keyboard height for the current system keyboard by its name.
  double? getSystemKeyboardHeightByName() {
    for (final SystemKeyboardHeight element in _systemKeyboardHeights) {
      if (element.name == KeyboardBindingMixin.binding.name) {
        return element.height;
      }
    }
    return null;
  }

  /// Gets the safe area padding at the bottom of the screen.
  static double get safeBottom =>
      WidgetsBinding.instance.window.viewPadding.bottom /
      WidgetsBinding.instance.window.devicePixelRatio;

  @override
  void didChangeMetrics() {
    _doJob();
  }

  /// Initializes the `SystemKeyboard` by reading stored keyboard heights from a file
  /// and adding itself as an observer to listen for changes in screen metrics.
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
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.addObserver(this);
  }

  /// Retrieves the file where keyboard heights are stored.
  Future<File> _getFile() async {
    final File file = File(join((await getTemporaryDirectory()).path,
        'extended_keyboard', 'keyboard_height.txt'));
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  /// Updates the current keyboard height and optionally associates it with a route.
  ///
  /// The method checks for existing heights, updates the list, and writes
  /// the data to the storage file.
  void updateHeight(double currentHeight, {ModalRoute<Object?>? route}) {
    SystemKeyboardHeight info = SystemKeyboardHeight(
      name: KeyboardBindingMixin.binding.name ?? 'SystemKeyboard',
      height: currentHeight,
    );
    _lastKeyboardHeight = info;
    route ??= KeyboardBindingMixin.binding.currentRoute;
    if (route != null) {
      _currentRouteLastKeyboardHeightMap[route] = info;
    }

    final int oldIndex = _systemKeyboardHeights.indexOf(info);
    if (oldIndex >= 0) {
      // The TextInputType may have multiple heights, always use the first one.
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

  /// Clears the keyboard height associated with the specified route.
  void clearCurrentRouteLastKeyboardHeight(ModalRoute<Object?>? route) {
    _currentRouteLastKeyboardHeightMap.remove(route);
  }
}

/// An immutable class representing the height of the system keyboard.
@immutable
class SystemKeyboardHeight {
  const SystemKeyboardHeight({
    required this.name,
    required this.height,
  });

  /// Creates an instance of `SystemKeyboardHeight` from JSON data.
  factory SystemKeyboardHeight.fromJson(Map<String, dynamic> json) {
    return SystemKeyboardHeight(
      name: json['name'] as String,
      height: json['height'] as double,
    );
  }

  /// The name associated with the keyboard, used for identification.
  final String name;

  /// The height of the system keyboard.
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemKeyboardHeight &&
          runtimeType == other.runtimeType &&
          name == other.name;
  // && height == other.height

  @override
  int get hashCode => name.hashCode;

  /// Converts the `SystemKeyboardHeight` instance to a JSON object.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'height': height,
    };
  }
}
