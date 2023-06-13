# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.7.3 - 2023-05-12
### Changed
- Upgrade to Flutter 3.10.0

## 0.7.2 - 2023-03-29
### Fixed
- Use action description style for the action description

## 0.7.1 - 2023-01-25
### Changed
- Create two named constructors for actions: `CommandPaletteAction.single` and `CommandPaletteAction.nested`. These handle the setting of the `actionType` and makes the required parameters for each explicit. The unnamed constructor has been marked as deprecated, but I have no plans to remove anytime soon.
- upgrade to Flutter 3.7.0 and update deprecations in style

## 0.7.0 - 2023-01-22
### Added
- Scroll to highlighted action

### Changed
- default item builder is now fixed height

## 0.6.1 - 2022-12-15
### Added
- Added `CommandPaletteStyle.barrierFilter`, which is an optional `ImageFilter` which can be used to add an effect (usually a blurring) behind the command palette when it's open

### Changed
- The default value of `CommandPaletteStyle.borderRadius` has been changed to `BorderRadius.all(Radius.circular(5))`

### Fixed
- `CommandPaletteStyle.borderRadius` now correctly applies to the border of the entire modal, and not just the part with the actions/instructions.

## 0.6.0 - 2022-12-10
### Fixed
- Semi-Breaking: Changed the type of `CommandPaletteConfig.openKeySet` and `CommandPaletteConfig.closeKeySet` from `LogicalKeySet` to `ShortcutActivator` (note: `LogicalKeySet` already implements `ShortcutActivator`, so existing custom shortcuts should still work, but a proposed solution is discussed below). This was done to fix an issue on Web builds for MacOS (discussed [here](https://github.com/TNorbury/command_palette/issues/22)). If you don't set custom values for the open and close key sets (or if you're not targeting Web), then no change will be required on your part. But if you are, the following change is suggested to make sure everything works well: If you're opening the palette with a keyboard shortcut, such as CTRL/CMD+U, then you could go from `LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyU)`/`LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyU)` to `SingleActivator(LogicalKeyboardKey.keyU, control: true)`/`SingleActivator(LogicalKeyboardKey.keyU, meta: true)`. This also changes how the command palette control shortcuts (Up/down/enter/backspace) are handled (from `LogicalKeySet` to `SingleActivator`). This should make things a bit cleaner on my end, and more stable going forward.
- Escape query correctly so that single a backslash doesn't cause filtering to crash

## 0.5.1 - 2022-12-02
### Added
- Optional `leading` widget for `CommandPaletteAction`s which will display a Widget at the left-side of the different command palette options
- exporting new widget 'KeyboardKeyIcon', this is the widget used to create the Keyboard Key Icons for the instructions bar and the shortcuts for each action
- Added flag, `showInstructions`, to `CommandPaletteConfig`, which when set to true, will show the basic instructions for using the command palette, navigation, selection, and closing.

### Changed
- Flutter 3.3.7

## 0.5.0 - 2022-07-20
### Added
- Open to nested action via `CommandPalette.of(context).openToAction(actionId)`

### Changed
- When a nested action is selected, the label of that action will prefix the command palette text field. This can be enabled by setting `prefixNestedActions` to true (this is also the current default) in `CommandPaletteStyle`

### Fixed
- BREAKING: default open key is now platform dependent. Previously it was always Ctrl+K, but now it will check if the platform is MacOS (this includes Web running on Mac) and if so will change the default open key to Command. While this change does make things function as I originally intended, this is changing default behavior so I'm considering this a breaking change

## 0.4.1 - 2022-06-09
### Added
- allow the setting of size (height, width) and position (top, bottom, left, right) of the command palette modal via the CommandPaletteConfig class

## 0.4.0 - 2022-06-09
### Changed
- Support Flutter 3

## 0.3.1 - 2022-06-09
### Fixed
- specify supported platforms explicitly
- use kIsWeb to stop error from being thrown when platform is checked

## 0.3.0 - 2022-02-26
### Changed
- Change default alignment of action text to better support all screen sizes

### Fixed
- Remove ListView padding that was creating blank spaces on smaller screens
- On-screen virtual keyboards that don't have a proper enter button were unable to select an action. This should be fixed now

## 0.2.0 - 2022-02-03
### Changed
- Flutter 2.10.0
- BREAKING: The configuration for the command palette is now set by a CommandPaletteConfig object that is passed to the CommandPalette constructor. To migrate, wrap all the arguments in the CommandPalette constructor that aren't actions, child, or key, in a CommandPaletteConfig constructor and pass that to the config argument
- Now using a fuzzy search implementation. This should improve search results. This also includes an improved sub-string highlighter. Expect the behavior to be the same as VSCode's command palette, as the logic is an adaptation of what's used there.

## 0.1.1 - 2021-11-03
### Fixed
- command palette state is now reset upon closure of palette

## 0.1.0 - 2021-11-03
### Added
- initial release