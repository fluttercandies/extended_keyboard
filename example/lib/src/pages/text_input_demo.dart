import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:extended_keyboard_example/extended_keyboard_example_routes.dart';
import 'package:extended_keyboard_example/src/widget/button.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://TextInput',
  routeName: 'TextInput',
  description: 'Show how to build custom TextInput quickly',
  exts: <String, dynamic>{
    'order': 10,
    'group': 'Simple',
  },
)
class TextInputDemo extends StatefulWidget {
  const TextInputDemo({Key? key}) : super(key: key);

  @override
  State<TextInputDemo> createState() => _TextInputDemoState();
}

class _TextInputDemoState extends State<TextInputDemo> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  late List<KeyboardConfiguration> _configurations;
  @override
  void initState() {
    super.initState();
    _configurations = <KeyboardConfiguration>[
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 200,
        builder: () {
          return _buildCustomKeyboard(TextInputAction.next, _controller);
        },
        textInputTypeName: '测试',
        // showDuration: const Duration(seconds: 1),
        // hideDuration: const Duration(seconds: 1),
      ),
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 200,
        builder: () {
          return _buildCustomKeyboard(TextInputAction.previous, _controller1);
        },
        textInputTypeName: '测试1',
        // resizeToAvoidBottomInset: false,
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TestPage'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.fluttercandiesTextInput);
            },
            icon: const Icon(Icons.pages),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: true,
        child: TextInputBuilder(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Column(
              children: <Widget>[
                Expanded(
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
                TextField(
                  keyboardType: _configurations[0].keyboardType,
                  controller: _controller,
                  decoration: const InputDecoration(hintText: '测试'),
                ),
                TextField(
                  keyboardType: _configurations[1].keyboardType,
                  controller: _controller1,
                  decoration: const InputDecoration(hintText: '测试1'),
                ),
                const TextField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const TextField(
                  textInputAction: TextInputAction.next,
                ),
                const TextField(
                  textInputAction: TextInputAction.done,
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
      color: const Color.fromARGB(255, 119, 116, 116),
      //elevation: 8,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 20,
          bottom: 20,
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
