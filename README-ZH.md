# extended_keyboard

[![pub package](https://img.shields.io/pub/v/extended_keyboard.svg)](https://pub.dartlang.org/packages/extended_keyboard) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: [English](README.md) | 中文简体

用于快速创建自定义键盘的插件。

- [extended\_keyboard](#extended_keyboard)
  - [安装](#安装)
  - [使用](#使用)
    - [SystemKeyboard](#systemkeyboard)
    - [KeyboardBuilder](#keyboardbuilder)
      - [KeyboardTypeBuilder](#keyboardtypebuilder)
      - [CustomKeyboardController](#customkeyboardcontroller)
      - [KeyboardBuilder](#keyboardbuilder-1)
    - [TextInputScope](#textinputscope)
      - [KeyboardBinding / KeyboardBindingMixin](#keyboardbinding--keyboardbindingmixin)
      - [KeyboardConfiguration](#keyboardconfiguration)
      - [TextInputScope](#textinputscope-1)


## 安装

运行 flutter pub add `extended_keyboard`, 或者直接手动添加 `extended_keyboard` 到 pubspec.yaml 中的 dependencies.

``` yaml
dependencies:
  extended_keyboard: ^latest_version
```

## 使用

### SystemKeyboard

用于管理系统键盘的高度并提供处理键盘布局更改的功能。

``` yaml
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemKeyboard().init();
  runApp(const MyApp());
}
```
### KeyboardBuilder

如果我们想要关闭系统键盘，并且保持输入框的不丢失焦点，我们没法再使用 `SystemChannels.textInput.invokeMethod<void>('TextInput.hide')` 了. 相关问题 https://github.com/flutter/flutter/issues/16863

下面的代码是一种变通方案

``` dart
TextField(
  showCursor: true,
  readOnly: true,
)
```

#### KeyboardTypeBuilder

用于监听 `KeyboardType` 改变的组件，并且提供 `CustomKeyboardController` 来控制自定义键盘的开关。

``` dart
   KeyboardTypeBuilder(
     builder: (
       BuildContext context,
       CustomKeyboardController controller,
     ) =>
         ToggleButton(
       builder: (bool active) => Icon(
         Icons.sentiment_very_satisfied,
         color: active ? Colors.orange : null,
       ),
       activeChanged: (bool active) {
         _keyboardPanelType = KeyboardPanelType.emoji;
          if (active) {
            controller.showCustomKeyboard();
          } else {
            controller.hideCustomKeyboard();
          }
       },
       active: controller.isCustom &&
           _keyboardPanelType == KeyboardPanelType.emoji,
     ),
   ),
```

#### CustomKeyboardController

用于通知 `KeyboardType` 改变，并且控制自定义键盘的开关。

* `KeyboardType` : 当前键盘的类型
* `isCustom` :  是否是自定义键盘
* `showCustomKeyboard` : 打开自定义键盘
* `hideCustomKeyboard` : 关闭自定义键盘
* `showSystemKeyboard` : 打开系统键盘 (通过将 readOnly 设置成 false)
* `unfocus` : 使输入框失去焦点, 并且关闭系统和自定义键盘

#### KeyboardBuilder

如果使用 `Scaffold`，请确保将 `Scaffold.resizeToAvoidBottomInset` 设置为 `false`。

使用 `KeyboardBuilder` 小部件来封装包含输入字段的区域，允许在其 `builder` 回调中创建自定义键盘布局。`builder` 函数接收一个名为 `systemKeyboardHeight` 的参数，该参数表示最后显示的系统键盘的高度。此参数可用于为您的自定义键盘设置适当的高度，从而确保无缝且直观的用户体验。

| parameter                | description                                        | default  |
| ------------------------ | -------------------------------------------------- | -------- |
| builder                  | 一个构建器函数，它根据系统键盘高度返回一个小部件。 | required |
| bodyBuilder              | 一个带 `readOnly` 参数的组件回调                   | required |
| resizeToAvoidBottomInset | 跟 `Scaffold.resizeToAvoidBottomInset` 作用一致    | true     |
| controller               | 自定义键盘控制器                                   | null     |


``` dart
  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(title: const Text('ChatDemo(KeyboardBuilder)')),
    body: SafeArea(
      bottom: true,
      child: KeyboardBuilder(
        resizeToAvoidBottomInset: true,
        builder: (BuildContext context, double? systemKeyboardHeight) {
          return Container();
        },
        bodyBuilder: (bool readOnly) => Column(children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  readOnly: readOnly, 
                  showCursor: true,
                  onTap: () {
                    _customKeyboardController.showSystemKeyboard();
                  },
                ),
              ),
              KeyboardTypeBuilder(
                builder: (
                  BuildContext context,
                  CustomKeyboardController controller,
                ) =>
                    ToggleButton(
                  builder: (bool active) => Icon(
                    Icons.sentiment_very_satisfied,
                    color: active ? Colors.orange : null,
                  ),
                  activeChanged: (bool active) {
                    _keyboardPanelType = KeyboardPanelType.emoji;
                    if (active) {
                      controller.showCustomKeyboard();
                    } else {
                      controller.hideCustomKeyboard();
                    }
                  },
                  active: controller.isCustom &&
                      _keyboardPanelType == KeyboardPanelType.emoji,
                ),
              ),
            ],
          ),
        ]),
      ),
    ),
  );
```

![img](https://github.com/fluttercandies/flutter_candies/blob/master/gif/extended_keyboard/chat_demo.gif)

[Full Demo](https://github.com/fluttercandies/extended_keyboard/blob/main/example/lib/src/pages/chat_demo.dart)

### TextInputScope

#### KeyboardBinding / KeyboardBindingMixin

你可以直接使用 `KeyboardBinding` ，或者将 `KeyboardBindingMixin` 混入到你的 `WidgetsFlutterBinding` 中。

``` yaml
Future<void> main() async {
  KeyboardBinding();
  await SystemKeyboard().init();
  runApp(const MyApp());
}
```

#### KeyboardConfiguration

这个配置包括键盘应该如何构建，它的动画持续时间，它的名字。

| parameter                | description                                                                                                              | default                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------- |
| getKeyboardHeight        | 返回自定义键盘的高度                                                                                                     | required                          |
| builder                  | 包含输入框的主体                                                                                                         | required                          |
| keyboardName             | 自定义键盘的名字                                                                                                         | required                          |
| showDuration             | 自定义键盘打开的时间                                                                                                     | const Duration(milliseconds: 200) |
| hideDuration             | 自定义键盘隐藏的时间                                                                                                     | const Duration(milliseconds: 200) |
| resizeToAvoidBottomInset | 跟 `Scaffold.resizeToAvoidBottomInset` 一样的意思. 如果它不设置，将和 `TextInputScope.resizeToAvoidBottomInset` 的值相同 | null                              |

``` dart
  KeyboardConfiguration(
    getKeyboardHeight: (double? systemKeyboardHeight) =>
        systemKeyboardHeight ?? 346,
    builder: () {
      return Container();
    },
    keyboardName: 'custom_number1',
    resizeToAvoidBottomInset: true,
  ),
```


#### TextInputScope

如果使用 `Scaffold`，请确保将 `Scaffold.resizeToAvoidBottomInset` 设置为 `false`。

| parameter                | description                                        | default  |
| ------------------------ | -------------------------------------------------- | -------- |
| body                     | 包含输入框的主体                                   | required |
| configurations           | 自定义键盘配置                                     | required |
| keyboardHeight           | 默认的自定义键盘高度                               | 346      |
| resizeToAvoidBottomInset | 跟 `Scaffold.resizeToAvoidBottomInset` 的意思一样. | true     |

``` dart
  late List<KeyboardConfiguration> _configurations;
  @override
  void initState() {
    super.initState();
    _configurations = <KeyboardConfiguration>[
      KeyboardConfiguration(
        getKeyboardHeight: (double? systemKeyboardHeight) =>
            systemKeyboardHeight ?? 346,
        builder: () {
          return Container();
        },
        keyboardName: 'custom_number',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextInputDemo'),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: true,
        child: TextInputScope(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: <Widget>[
                TextField(
                  keyboardType: _configurations[0].keyboardType,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        'The keyboardType is ${_configurations[0].keyboardType.name}',
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
```

![img](https://github.com/fluttercandies/flutter_candies/blob/master/gif/extended_keyboard/text_input_demo.gif)

[Full Demo](https://github.com/fluttercandies/extended_keyboard/blob/main/example/lib/src/pages/text_input_demo.dart)

![img](https://github.com/fluttercandies/flutter_candies/blob/master/gif/extended_keyboard/chat_demo1.gif)

[Full Demo](https://github.com/fluttercandies/extended_keyboard/blob/main/example/lib/src/pages/chat_demo1.dart)

 