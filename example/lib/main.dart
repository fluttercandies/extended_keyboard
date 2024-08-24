import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

import 'package:flutter/material.dart';

import 'extended_keyboard_example_route.dart';
import 'extended_keyboard_example_routes.dart';

Future<void> main() async {
  KeyboardBinding();
  await SystemKeyboard().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        return onGenerateRoute(
          settings: settings,
          getRouteSettings: getRouteSettings,
          routeSettingsWrapper: (FFRouteSettings ffRouteSettings) {
            if (ffRouteSettings.name == Routes.fluttercandiesMainpage ||
                ffRouteSettings.name == Routes.fluttercandiesDemogrouppage) {
              return ffRouteSettings;
            }
            return ffRouteSettings.copyWith(
                builder: () => ffRouteSettings.builder());
          },
        );
      },
    );
  }
}
