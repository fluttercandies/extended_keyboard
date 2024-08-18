import 'package:extended_image/extended_image.dart';
import 'package:extended_keyboard/extended_keyboard.dart';
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
  emoji,
  image,
}

@FFRoute(
  name: 'fluttercandies://ChatDemo',
  routeName: 'ChatDemo',
  description: 'Show how to build chat list quickly',
  exts: <String, dynamic>{
    'order': 0,
    'group': 'Simple',
  },
)
class ChatDemo extends StatefulWidget {
  const ChatDemo({Key? key}) : super(key: key);

  @override
  State<ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<ChatDemo> {
  KeyboardPanelType _keyboardPanelType = KeyboardPanelType.emoji;
  final GlobalKey<ExtendedTextFieldState> _key =
      GlobalKey<ExtendedTextFieldState>();
  final TextEditingController _textEditingController = TextEditingController();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();
  late TuChongRepository imageList = TuChongRepository(maxLength: 100);
  @override
  Widget build(BuildContext context) {
    return KeyboardBuilder(
      safeAreaBottom: true,
      builder: (BuildContext context, double? keyboardHeight) {
        return _buildCustomKeyboard(context, keyboardHeight);
      },
      body: Column(children: <Widget>[
        const Spacer(),
        Row(
          children: <Widget>[
            const SizedBox(width: 10),
            Expanded(
              child: ExtendedTextField(
                key: _key,
                specialTextSpanBuilder: _mySpecialTextSpanBuilder,
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Input something',
                ),
                strutStyle: const StrutStyle(),
              ),
            ),
            KeyboardTypeBuilder(
              builder: (
                BuildContext context,
                KeyboardTypeController controller,
              ) =>
                  Row(
                children: <Widget>[
                  ToggleButton(
                    builder: (bool active) => Icon(
                      Icons.sentiment_very_satisfied,
                      color: active ? Colors.orange : null,
                    ),
                    activeChanged: (bool active) {
                      _keyboardPanelType = KeyboardPanelType.emoji;
                      if (active) {
                        controller.showKeyboard();
                      } else {
                        controller.hideKeyboard();
                      }
                    },
                    active: controller.isCustom &&
                        _keyboardPanelType == KeyboardPanelType.emoji,
                  ),
                  ToggleButton(
                    builder: (bool active) => Icon(
                      Icons.image,
                      color: active ? Colors.orange : null,
                    ),
                    activeChanged: (bool active) {
                      _keyboardPanelType = KeyboardPanelType.image;
                      if (active) {
                        controller.showKeyboard();
                      } else {
                        controller.hideKeyboard();
                      }
                    },
                    active: controller.isCustom &&
                        _keyboardPanelType == KeyboardPanelType.image,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildCustomKeyboard(
    BuildContext context,
    double? keyboardHeight,
  ) {
    keyboardHeight ??= 300;
    switch (_keyboardPanelType) {
      case KeyboardPanelType.emoji:
        return SizedBox(
          height: keyboardHeight,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0),
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
          ),
        );
      case KeyboardPanelType.image:
        return SizedBox(
          height: keyboardHeight,
          child: LoadingMoreList<TuChongItem>(
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
                    insertText(
                      "<img src='$url'  width='${item.imageSize.width}' height='${item.imageSize.height}'/>",
                    );
                  },
                  child: ExtendedImage.network(
                    url,
                  ),
                );
              },
              padding: const EdgeInsets.all(5.0),
            ),
          ),
        );
      default:
    }
    return Container();
  }

  void insertText(String text) {
    final TextEditingValue value = _textEditingController.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textEditingController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textEditingController.value = TextEditingValue(
          text: text,
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)));
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _key.currentState?.bringIntoView(_textEditingController.selection.base);
    });
  }
}
