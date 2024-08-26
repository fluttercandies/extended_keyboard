# extended_keyboard

[![pub package](https://img.shields.io/pub/v/extended_keyboard.svg)](https://pub.dartlang.org/packages/extended_keyboard) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_keyboard)](https://github.com/fluttercandies/extended_keyboard/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: English| [中文简体](README-ZH.md)

Flutter plugin for create custom keyboards quickly.

- [extended\_keyboard](#extended_keyboard)
  - [Install](#install)
  - [Use](#use)
    - [SystemKeyboard](#systemkeyboard)
    - [KeyboardBuilder](#keyboardbuilder)
      - [KeyboardTypeBuilder](#keyboardtypebuilder)
      - [CustomKeyboardController](#customkeyboardcontroller)
      - [KeyboardBuilder](#keyboardbuilder-1)
    - [TextInputScope](#textinputscope)
      - [KeyboardBinding / KeyboardBindingMixin](#keyboardbinding--keyboardbindingmixin)
      - [KeyboardConfiguration](#keyboardconfiguration)
      - [TextInputScope](#textinputscope-1)


## Install

Run flutter pub add `extended_keyboard`, or add `extended_keyboard` to pubspec.yaml dependencies manually.

``` yaml
dependencies:
  extended_keyboard: ^latest_version
```

## Use

### SystemKeyboard

A singleton class that manages system keyboard height and provides functionality to handle keyboard layout changes.

``` yaml
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemKeyboard().init();
  runApp(const MyApp());
}
```
### KeyboardBuilder

if we want to close the keyboard without losing textfield focus, we can't use `SystemChannels.textInput.invokeMethod<void>('TextInput.hide')` any more. related issue https://github.com/flutter/flutter/issues/16863

Following code is a workaround.

``` dart
TextField(
  showCursor: true,
  readOnly: true,
)
```

#### KeyboardTypeBuilder

A widget that listens to changes in the `CustomKeyboardController` and builds a widget accordingly.

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

A controller for managing the keyboard type and notifying listeners.

* `KeyboardType` : The current keyboard type
* `isCustom` :  whether current keyboard is custom
* `showCustomKeyboard` : show the custom keyboard
* `hideCustomKeyboard` : hide the custom keyboard
* `showSystemKeyboard` : show the system keyboard (set readOnly to false， it works if the input is on hasFocus)
* `unfocus` : make the input lost focus and hide the system keyboard or custom keyboard

#### KeyboardBuilder

if `Scaffold` is used, make sure set `Scaffold.resizeToAvoidBottomInset` to false.

Using the `KeyboardBuilder` widget to encapsulate the area containing the input field allows for the creation of a custom keyboard layout within its `builder` callback. The `builder` function receives a parameter named `systemKeyboardHeight`, which represents the height of the last system keyboard displayed. This parameter can be utilized to set an appropriate height for your custom keyboard, ensuring a seamless and intuitive user experience.

| parameter                | description                                                                   | default  |
| ------------------------ | ----------------------------------------------------------------------------- | -------- |
| builder                  | A builder function that returns a widget based on the system keyboard height. | required |
| bodyBuilder              | The main body widget builder with a parameter `readOnly`                      | required |
| resizeToAvoidBottomInset | The same as `Scaffold.resizeToAvoidBottomInset`.                              | true     |
| controller               | The controller for the custom keyboard.                                       | null     |


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

You can directly use `KeyboardBinding` or mix the `KeyboardBindingMixin` into your `WidgetsFlutterBinding`.

``` yaml
Future<void> main() async {
  KeyboardBinding();
  await SystemKeyboard().init();
  runApp(const MyApp());
}
```

#### KeyboardConfiguration

This configuration includes how the keyboard should be built,
its animation durations, and how it should behave with respect to resizing.

| parameter                | description                                                                                                            | default                           |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| getKeyboardHeight        | Function that calculates the height of the custom keyboard.                                                            | required                          |
| builder                  | The main body widget.                                                                                                  | required                          |
| keyboardName             | The name of the keyboard                                                                                               | required                          |
| showDuration             | Duration for the keyboard's show animation.                                                                            | const Duration(milliseconds: 200) |
| hideDuration             | Duration for the keyboard's hide animation.                                                                            | const Duration(milliseconds: 200) |
| resizeToAvoidBottomInset | The same as `Scaffold.resizeToAvoidBottomInset`. if it's null, it's equal to `TextInputScope.resizeToAvoidBottomInset` | null                              |

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

if `Scaffold` is used, make sure set `Scaffold.resizeToAvoidBottomInset` to false.

| parameter                | description                                      | default  |
| ------------------------ | ------------------------------------------------ | -------- |
| body                     | The main body widget.                            | required |
| configurations           | A list of `KeyboardConfiguration`                | required |
| keyboardHeight           | The default height of the keyboard.              | 346      |
| resizeToAvoidBottomInset | The same as `Scaffold.resizeToAvoidBottomInset`. | true     |

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



 