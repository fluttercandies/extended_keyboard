import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:extended_keyboard_example/extended_keyboard_example_routes.dart';
import 'package:extended_keyboard_example/src/widget/button.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://TestPage1',
  routeName: 'TestPage1',
  description: 'Show how to build chat list quickly',
  exts: <String, dynamic>{
    'order': 10,
    'group': 'Simple',
  },
)
class TestPage1 extends StatefulWidget {
  const TestPage1({Key? key}) : super(key: key);

  @override
  State<TestPage1> createState() => _TestPage1State();
}

class _TestPage1State extends State<TestPage1> {
  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  late List<KeyboardConfiguration> _configurations;
  @override
  void initState() {
    super.initState();
    _configurations = <KeyboardConfiguration>[
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 200,
        builder: () {
          return _buildCustomKeyboard(true);
        },
        textInputTypeName: '测试',
      ),
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 200,
        builder: () {
          return _buildCustomKeyboard(false);
        },
        textInputTypeName: '测试1',
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
              Navigator.of(context).pushNamed(Routes.fluttercandiesTestPage1);
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
              _focusNode.unfocus();
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
                  focusNode: _focusNode,
                  keyboardType: _configurations[0].textInputType,
                  controller: _controller,
                  decoration: const InputDecoration(hintText: '测试'),
                  // maxLines: null,
                  // keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  keyboardType: _configurations[1].textInputType,
                  controller: _controller,
                  decoration: const InputDecoration(hintText: '测试1'),
                  // maxLines: null,
                  // keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.next,
                ),
                const TextField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const TextField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          configurations: _configurations,
        ),
      ),
    );
  }

  Material _buildCustomKeyboard(bool test) {
    return Material(
      //shadowColor: Colors.grey,
      color: test ? Colors.blue : Colors.grey.withOpacity(0.3),
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
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 2,
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 3,
                              insertText: insertText,
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
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 5,
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 6,
                              insertText: insertText,
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
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 8,
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 9,
                              insertText: insertText,
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
                                insertText('.');
                              },
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: NumberButton(
                              number: 0,
                              insertText: insertText,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: CustomButton(
                              child: const Icon(Icons.arrow_downward),
                              onTap: () {
                                _focusNode.unfocus();
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
                          deleteText();
                        },
                      ),
                    ),
                    Expanded(
                        child: CustomButton(
                      child: const Icon(Icons.keyboard_return),
                      onTap: () {
                        _controller.performAction(TextInputAction.next);
                        // insertText('\n');
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

  void insertText(String text) {
    _controller.insertText(text);
  }

  void deleteText() {
    _controller.delete();
  }
}
