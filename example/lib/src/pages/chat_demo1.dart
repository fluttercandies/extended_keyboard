import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:extended_keyboard/extended_keyboard.dart';
import 'package:extended_keyboard_example/assets.dart';
import 'package:extended_keyboard_example/src/widget/button.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../data/tu_chong_repository.dart';
import '../data/tu_chong_source.dart';
import '../special_text/emoji_text.dart' as emoji;
import '../special_text/my_special_text_span_builder.dart';
import '../widget/toggle_button.dart';

enum KeyboardPanelType {
  number,
  emoji,
  image,
}

@FFRoute(
  name: 'fluttercandies://ChatDemo1',
  routeName: 'ChatDemo1',
  description:
      'Show how to build chat page which include custom keyboard with TextInputBuilder quickly',
  exts: <String, dynamic>{
    'order': 1,
    'group': 'Simple',
  },
)
class ChatDemo1 extends StatefulWidget {
  const ChatDemo1({Key? key}) : super(key: key);

  @override
  State<ChatDemo1> createState() => _ChatDemo1State();
}

class _ChatDemo1State extends State<ChatDemo1> {
  KeyboardPanelType _keyboardPanelType = KeyboardPanelType.emoji;
  final GlobalKey<ExtendedTextFieldState> _key =
      GlobalKey<ExtendedTextFieldState>();
  final TextEditingController _textEditingController = TextEditingController();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();
  late TuChongRepository imageList = TuChongRepository(maxLength: 100);
  final ScrollController _controller = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Message> _messages = <Message>[];

  late List<KeyboardConfiguration> _configurations;

  @override
  void initState() {
    super.initState();

    _configurations = <KeyboardConfiguration>[
      for (int i = 0; i < KeyboardPanelType.values.length; i++)
        KeyboardConfiguration(
          getKeyboardHeight: (double? systemKeyboardHeight) =>
              systemKeyboardHeight ?? 200,
          builder: () {
            return _buildCustomKeyboard(
              KeyboardPanelType.values[i],
            );
          },
          textInputTypeName: KeyboardPanelType.values[i].toString(),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('ChatDemo')),
      body: SafeArea(
        bottom: true,
        child: TextInputBuilder(
          resizeToAvoidBottomInset: true,
          body: Column(children: <Widget>[
            Expanded(
              child: KeyboardDismisser(
                child: ListView.builder(
                  controller: _controller,
                  itemBuilder: (BuildContext context, int index) {
                    final Message message = _messages[index];
                    List<Widget> children = <Widget>[
                      ExtendedImage.asset(
                        Assets.assets_avatar_jpg,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: ExtendedText(
                          message.content,
                          specialTextSpanBuilder: _mySpecialTextSpanBuilder,
                          maxLines: 10,
                        ),
                      ),
                    ];
                    if (message.isMe) {
                      children = children.reversed.toList();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: message.isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: children,
                      ),
                    );
                  },
                  itemCount: _messages.length,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ExtendedTextField(
                      key: _key,
                      specialTextSpanBuilder: _mySpecialTextSpanBuilder,
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.done,
                      strutStyle: const StrutStyle(),
                      keyboardType: _getKeyboardType(),
                      decoration: InputDecoration(
                        hintText: 'Input something',
                        border: InputBorder.none,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              sendMessage(_textEditingController.text);
                              _textEditingController.clear();
                            });
                          },
                          child: const Icon(Icons.send),
                        ),
                        contentPadding: const EdgeInsets.all(
                          12.0,
                        ),
                      ),
                      maxLines: 2,
                      onTap: () {
                        setState(() {
                          _keyboardPanelType = KeyboardPanelType.number;
                        });
                      },
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      ToggleButton(
                        builder: (bool active) => Icon(
                          Icons.sentiment_very_satisfied,
                          color: active ? Colors.orange : null,
                        ),
                        activeChanged: (bool active) {
                          setState(() {
                            _keyboardPanelType = KeyboardPanelType.emoji;
                            if (active) {
                              _focusNode.requestFocus();
                            } else {
                              _keyboardPanelType = KeyboardPanelType.number;
                              _focusNode.unfocus();
                            }
                          });
                        },
                        active: _keyboardPanelType == KeyboardPanelType.emoji,
                      ),
                      ToggleButton(
                        builder: (bool active) => Icon(
                          Icons.image,
                          color: active ? Colors.orange : null,
                        ),
                        activeChanged: (bool active) {
                          setState(() {
                            _keyboardPanelType = KeyboardPanelType.image;
                            if (active) {
                              _focusNode.requestFocus();
                            } else {
                              _keyboardPanelType = KeyboardPanelType.number;
                              _focusNode.unfocus();
                            }
                          });
                        },
                        active: _keyboardPanelType == KeyboardPanelType.image,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
          configurations: _configurations,
        ),
      ),
    );
  }

  Widget _buildCustomKeyboard(
    KeyboardPanelType keyboardPanelType,
  ) {
    switch (_keyboardPanelType) {
      case KeyboardPanelType.number:
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
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 2,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 3,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
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
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 5,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 6,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
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
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 8,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 9,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
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
                                    _textEditingController.insertText('.');
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: NumberButton(
                                  number: 0,
                                  insertText: (String text) =>
                                      _textEditingController.insertText(text),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: CustomButton(
                                  child: const Icon(Icons.arrow_downward),
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
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
                              _textEditingController.delete();
                            },
                          ),
                        ),
                        Expanded(
                            child: CustomButton(
                          child: Text(TextInputAction.done.name),
                          onTap: () {
                            _textEditingController
                                .performAction(TextInputAction.done);
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
      case KeyboardPanelType.emoji:
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                insertText('[${index + 1}]');
              },
              child: Image.asset(
                  emoji.EmojiUitl.instance.emojiMap['[${index + 1}]']!),
            );
          },
          itemCount: emoji.EmojiUitl.instance.emojiMap.length,
          padding: const EdgeInsets.all(5.0),
        );
      case KeyboardPanelType.image:
        return LoadingMoreList<TuChongItem>(
          ListConfig<TuChongItem>(
            sourceList: imageList,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemBuilder: (BuildContext context, TuChongItem item, int index) {
              final String url = item.imageUrl;
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // <img src="http://pic2016.5442.com:82/2016/0513/12/3.jpg!960.jpg"/>
                  setState(() {
                    sendMessage(
                        "<img src='$url'  width='${item.imageSize.width}' height='${item.imageSize.height}'/>");
                  });
                },
                child: ExtendedImage.network(
                  url,
                ),
              );
            },
            padding: const EdgeInsets.all(5.0),
          ),
        );
      default:
    }
    return Container();
  }

  void insertText(String text) {
    _textEditingController.insertText(text);

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _key.currentState?.bringIntoView(_textEditingController.selection.base);
    });
  }

  void sendMessage(String text) {
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(Message(content: text));
    });
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  TextInputType _getKeyboardType() {
    for (final KeyboardConfiguration element in _configurations) {
      if (element.keyboardType.name == _keyboardPanelType.toString()) {
        return element.keyboardType;
      }
    }
    return _configurations.first.keyboardType;
  }
}

class Message {
  Message({
    required this.content,
  }) : isMe = Random().nextBool();
  final bool isMe;
  final String content;
}
