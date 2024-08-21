import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';

import 'package:flutter/material.dart';

import 'extended_keyboard_example_route.dart';
import 'extended_keyboard_example_routes.dart';

Future<void> main() async {
  KeyboardBinding();
  // await SystemKeyboard().init();
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
      builder: (BuildContext context, Widget? child) {
        return KeyboardApp(
          body: child!,
        );
      },
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

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    this.child,
    this.title,
    super.key,
  });
  final Widget? child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          title!,
        ),
      ),
      body: child,
    );
  }
}
