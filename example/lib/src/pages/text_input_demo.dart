import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:extended_keyboard_example/extended_keyboard_example_routes.dart';
import 'package:extended_keyboard_example/src/widget/button.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://TextInputScope',
  routeName: 'TextInputScope',
  description:
      'Show how to build different custom keyboard with TextInputScope quickly',
  exts: <String, dynamic>{
    'order': 1,
    'group': 'Simple',
  },
)
class TextInputScopeDemo extends StatefulWidget {
  const TextInputScopeDemo({Key? key}) : super(key: key);

  @override
  State<TextInputScopeDemo> createState() => _TextInputScopeDemoState();
}

class _TextInputScopeDemoState extends State<TextInputScopeDemo> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  late List<KeyboardConfiguration> _configurations;
  @override
  void initState() {
    super.initState();
    _configurations = <KeyboardConfiguration>[
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 346,
        builder: () {
          return _buildCustomKeyboard(TextInputAction.next, _controller);
        },
        keyboardName: 'custom_number',
        // showDuration: const Duration(seconds: 1),
        // hideDuration: const Duration(seconds: 1),
      ),
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 346,
        builder: () {
          return _buildCustomKeyboard(TextInputAction.previous, _controller1);
        },
        keyboardName: 'custom_number1',
        // resizeToAvoidBottomInset: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextInputDemo'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(Routes.fluttercandiesTextInputScope);
            },
            icon: const Icon(Icons.next_plan),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: true,
        child: TextInputScope(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: KeyboardDismisser(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10.0),
                          child: Text('item $index'),
                        );
                      },
                      itemCount: 200,
                    ),
                  ),
                ),
                TextField(
                  keyboardType: _configurations[0].keyboardType,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        'The keyboardType is ${_configurations[0].keyboardType.name}',
                  ),
                ),
                TextField(
                  keyboardType: _configurations[1].keyboardType,
                  controller: _controller1,
                  decoration: InputDecoration(
                    hintText:
                        'The keyboardType is ${_configurations[1].keyboardType.name}',
                  ),
                ),
                const TextField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'The keyboardType is number',
                  ),
                ),
                const TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'The keyboardType is text',
                  ),
                ),
              ],
            ),
          ),
          configurations: _configurations,
        ),
      ),
    );
  }

  Material _buildCustomKeyboard(
    TextInputAction inputAction,
    TextEditingController controller,
  ) {
    return Material(
      //shadowColor: Colors.grey,

      //elevation: 8,
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 20,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 1,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 2,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 3,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 4,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 5,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 6,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 7,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 8,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 9,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: CustomButton(
                              child: const Text('.'),
                              onTap: () {
                                controller.insertText('.');
                              },
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 0,
                              insertText: (String text) =>
                                  controller.insertText(text),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: CustomButton(
                              child: const Icon(Icons.arrow_downward),
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        child: const Icon(Icons.backspace),
                        onTap: () {
                          controller.delete();
                        },
                      ),
                    ),
                    Expanded(
                        child: CustomButton(
                      child: Text(inputAction.name),
                      onTap: () {
                        controller.performAction(inputAction);
                      },
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
