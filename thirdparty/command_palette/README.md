# command_palette

git hash: e62a83e73483f7e7db5d2c900ed6fcf629636dae

[![pub package](https://img.shields.io/pub/v/command_palette.svg)](https://pub.dev/packages/command_palette)
[![flutter_tests](https://github.com/TNorbury/command_palette/workflows/CI/badge.svg)](https://github.com/TNorbury/command_palette/actions?query=workflow%3A%22ci%22)
[![codecov](https://codecov.io/gh/TNorbury/command_palette/branch/main/graph/badge.svg?token=TKS5WR5D7A)](https://codecov.io/gh/TNorbury/command_palette)
[![style: flutter lints](https://img.shields.io/badge/style-flutter_lints-40c4ff.svg)](https://pub.dev/packages/flutter_lints)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
A Flutter widget that allows you to bring up a command palette, seen in programs like Visual Studio Code and Slack.
Allowing you to provide users with a convenient way to perform all sorts of actions related to your app.

![A gif showing a demo of the command palette. Showcasing filtering, sub-options, and text highlighting](https://raw.githubusercontent.com/TNorbury/command_palette/main/readme_assets/demo2.gif)

## Features

-   Access the command palette via a keyboard shortcut, or programmatically.
-   Define a custom list of actions for the user and define the callbacks for each.
-   Use the default styling or build your own custom list items.
-   Use your own filtering logic
-   Use throughout your entire app, or just in certain sections!
-   Support for keyboardless apps too!

## Getting started

To install run the following command:

```
flutter pub install command_palette
```

or add `command_palette` to your pubspec.yaml

## Usage

Start by placing the Command Palette widget in your widget tree:

```dart
import 'package:command_palette/command_palette.dart';

//...
CommandPalette(
  actions: [
    CommandPaletteAction(
      label: "Goto Home Page",
      actionType: CommandPaletteActionType.single,
      onSelect: () {
        // go to home page, or perform some other sorta action
      }
    ),
    CommandPaletteAction(
      id: "change-theme",
      label: "Change Theme",
      actionType: CommandPaletteActionType.nested,
      description: "Change the color theme of the app",
      shortcut: ["ctrl", "t"],
      childrenActions: [
        CommandPaletteAction(
          label: "Light",
          actionType: CommandPaletteActionType.single,
          onSelect: () {
            setState(() {
              themeMode = ThemeMode.light;
            });
          },
        ),
        CommandPaletteAction(
          label: "Dark",
          actionType: CommandPaletteActionType.single,
          onSelect: () {
            setState(() {
              themeMode = ThemeMode.dark;
            });
          },
        ),
      ],
    ),
  ],
  child: Text("Use a keyboard shortcut to open the palette up!"),
)
//...
```

### Opening Without a Keyboard

Want to allow devices that don't have a keyboard to open the palette, just use the handy InheritedWidget!

```dart
CommandPalette.of(context).open();
```

### Creating a custom filter

One of the configuration options is `filter`, which allows you to define your own custom filtering logic. The return type of this function is `List<CommandPaletteAction>`. With that in mind there is one thing I'd like to make you aware of before implementing your own: There is a sub class of CommandPaletteAction called [`MatchedCommandPaletteAction`](https://github.com/TNorbury/command_palette/blob/main/lib/src/models/matched_command_palette_action.dart). The only difference between this sub class and it's super class is it has a list of [`FilterMatch`es](https://github.com/TNorbury/command_palette/blob/main/lib/src/utils/filter.dart), which indicates the parts of the action label (this can be any string, but it's advisable to match against the label) that were matched against some part of the query. By using this subclass with the default builder, you can get enhanced sub-string high lighting.


### Opening to a nested action

To open up a nested action directly (e.g. You want to have a "Set User" button, that will open the palette with the Set User nested action already selected), you can use the following method:

```dart
CommandPalette.of(context).openToAction(actionId);
```
Where `actionId` is a value which matches the `id` of a `CommandPaletteAction`. An `id` can be any object, primitives work best, but if you use a custom object, be sure to override the the `==` operator.

## Additional information

Have a feature request, or some questions? Come on down to the [discussions tab](https://github.com/TNorbury/command_palette/discussions).

Find a bug or want to open a pull request? Feel free to do so, any and all contributions are welcome and appreciated!

### Note about the version

While I feel confident that this package is ready to use in a real world app. I'm keeping the version below 1.0.0 for the time being incase there is any major changes I'd like to make before I settle down into something.
