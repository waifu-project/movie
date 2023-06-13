// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:command_palette/src/widgets/options/command_palette_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../command_palette.dart';

final _defaultOpenKeySet = SingleActivator(LogicalKeyboardKey.keyK,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
    control: defaultTargetPlatform != TargetPlatform.macOS);
const _defaultCloseKeySet = SingleActivator(LogicalKeyboardKey.escape);

/// Configuration options for the command palette
class CommandPaletteConfig {
  /// Text that's displayed in the command palette when nothing has been entered
  final String hintText;

  /// Used to filter which actions are displayed based upon the currently
  /// entered text of the search bar
  final ActionFilter filter;

  /// Used to build the actions which're displayed when the command palette is
  /// open
  ///
  /// For an idea on how to builder your own custom builder, see
  /// [kDefaultBuilder]
  final ActionBuilder builder;

  /// How long it takes for the command palette to be opened or closed.
  ///
  /// Defaults to 150 ms
  final Duration transitionDuration;

  /// Curves used when fading the command palette in and out.
  ///
  /// Defaults to [Curves.linear]
  final Curve transitionCurve;

  /// Provides options to style the look of the command palette.
  ///
  /// Note for development: Changes to style while the command palette is open
  /// will require the command palette to be closed and reopened.
  final CommandPaletteStyle? style;

  /// The set of keys used to open the command palette.
  ///
  /// Defaults to Ctrl-/Cmd- C
  final ShortcutActivator openKeySet;

  /// The set of keys used to close the command palette.
  ///
  /// Please note that at this time escape will always close the command
  /// palette.
  /// Regardless of if it's set or not. This is something defined at the
  /// App-level. If you want to prevent this, see: https://stackoverflow.com/questions/63763478/disable-escape-key-navigation-in-flutter-web
  ///
  /// Defaults to Esc.
  final ShortcutActivator closeKeySet;

  /// The offset of the modal from the top of the screen.
  ///
  /// If null, this will become equal to 1/8 of the height of the viewport
  final double? top;

  /// The offset of the modal from the bottom of the screen
  final double? bottom;

  /// The offset of the modal from the left of the screen
  ///
  /// If null, this will become equal to 1/8 of the width of the viewport
  final double? left;

  /// The offset of the modal from the right of the screen
  final double? right;

  /// The height of the modal.
  ///
  /// If null this will become equal to 6/8 of the height of the viewport
  final double? height;

  /// The width of the modal.
  ///
  /// If null this will become equal to 6/8 of the width of the viewport
  final double? width;

  /// Whether or not to show the instructions bar at the bottom of the command
  /// palette modal, under all the options.
  /// The current instructions tell the user how to user the modal with their
  /// keyboard
  ///
  /// The current instructions are:
  /// * enter/return: to select
  /// * up/down arrow: to navigate
  /// * escape: to close
  ///
  /// When a nested action is selected:
  /// * backspace: to cancel selected action
  final bool showInstructions;

  CommandPaletteConfig({
    ActionFilter? filter,
    Key? key,
    ActionBuilder? builder,
    ShortcutActivator? openKeySet,
    ShortcutActivator? closeKeySet,
    this.hintText = "Begin typing to search for something",
    this.transitionDuration = const Duration(milliseconds: 150),
    this.transitionCurve = Curves.linear,
    this.style,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.height,
    this.width,
    this.showInstructions = false,
  })  : filter = filter ?? kDefaultFilter,
        builder = builder ?? kDefaultBuilder,
        openKeySet = openKeySet ?? _defaultOpenKeySet,
        closeKeySet = closeKeySet ?? _defaultCloseKeySet;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommandPaletteConfig &&
        other.hintText == hintText &&
        other.filter == filter &&
        other.builder == builder &&
        other.transitionDuration == transitionDuration &&
        other.transitionCurve == transitionCurve &&
        other.style == style &&
        other.openKeySet == openKeySet &&
        other.closeKeySet == closeKeySet &&
        other.top == top &&
        other.bottom == bottom &&
        other.left == left &&
        other.right == right &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode {
    return hintText.hashCode ^
        filter.hashCode ^
        builder.hashCode ^
        transitionDuration.hashCode ^
        transitionCurve.hashCode ^
        style.hashCode ^
        openKeySet.hashCode ^
        closeKeySet.hashCode ^
        top.hashCode ^
        bottom.hashCode ^
        left.hashCode ^
        right.hashCode ^
        height.hashCode ^
        width.hashCode;
  }
}
