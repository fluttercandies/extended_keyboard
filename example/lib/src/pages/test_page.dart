import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:extended_keyboard_example/src/widget/button.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';

@FFRoute(
  name: 'fluttercandies://TestPage',
  routeName: 'TestPage',
  description: 'Show how to build chat list quickly',
  exts: <String, dynamic>{
    'order': 10,
    'group': 'Simple',
  },
)
class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TextEditingController _controller = TextEditingController();
  final ExtendedTextInputType _textInputType =
      const ExtendedTextInputType(name: '测试');
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    KeyboardBindingMixin.binding.register(
      textInputType: _textInputType,
      configuration: KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 200,
        builder: () {
          return _buildCustomKeyboard();
        },
      ),
    );
  }

  @override
  void dispose() {
    KeyboardBindingMixin.binding.unregister(
      textInputType: _textInputType,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TestPage')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: true,
        child: GestureDetector(
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
                keyboardType: _textInputType,
                controller: _controller,
                decoration: const InputDecoration(hintText: '测试'),
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
      ),
    );
  }

  Material _buildCustomKeyboard() {
    return Material(
      //shadowColor: Colors.grey,
      color: Colors.grey.withOpacity(0.3),
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
