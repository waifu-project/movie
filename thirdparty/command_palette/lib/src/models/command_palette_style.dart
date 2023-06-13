import 'dart:ui';

import 'package:flutter/material.dart';

/// Used to style a [CommandPalette]
class CommandPaletteStyle {
  /// Color that's used as the background of the non-selected action item.
  ///
  /// Defaults to `Theme.of(context).canvasColor` when not set
  final Color? actionColor;

  /// Colors that's used as the background of the selected action item;
  ///
  /// Defaults to `Theme.of(context).highlightColor` when not set
  final Color? selectedColor;

  /// Text style for the label of an action
  ///
  /// Defaults to (if it's available):
  /// ```
  /// Theme.of(context).primaryTextTheme.titleMedium?.copyWith(
  ///   color: Theme.of(context).colorScheme.onSurface,
  ///  )
  /// ```
  final TextStyle? actionLabelTextStyle;

  /// Text style for the parts of the label which're highlighted because of
  /// searching
  ///
  /// Defaults to (if it's available):
  /// ```
  /// Theme.of(context)
  ///   .primaryTextTheme
  ///   .titleMedium
  ///   ?.copyWith(
  ///       color: Theme.of(context).colorScheme.secondary,
  ///       fontWeight: FontWeight.w600,
  ///   )
  /// ```
  final TextStyle? highlightedLabelTextStyle;

  /// Text style for the description of an action
  ///
  /// Defaults to (if it's available):
  /// ```
  /// Theme.of(context).primaryTextTheme.titleSmall?.copyWith(
  ///   color: Theme.of(context).colorScheme.onSurface,
  ///  )
  /// ```
  final TextStyle? actionDescriptionTextStyle;

  /// Determines whether or not matching characters in action labels are
  /// highlighted while searching.
  ///
  /// Defaults to `true`
  final bool highlightSearchSubstring;

  /// Elevation of the command palette
  ///
  /// Defaults to `4.0`
  final double elevation;

  /// Border radius of the entire command palette. Includes the search bar and
  /// the contents.
  ///
  /// Defaults to
  /// ```
  /// BorderRadius.all(Radius.circular(5))
  /// ```
  final BorderRadiusGeometry borderRadius;

  /// The alignment of the text within the action labels
  ///
  /// Defaults to [TextAlign.left]
  final TextAlign actionLabelTextAlign;

  /// The color which is set behind the command palette when it's open
  ///
  /// Defaults to `Colors.black12`
  final Color commandPaletteBarrierColor;

  /// Filter to apply behind the command palette when it's open. It's used to set
  /// [ModalRoute.filter].
  final ImageFilter? barrierFilter;

  /// Decoration used for the text field
  ///
  /// Defaults to
  /// ```
  /// InputDecoration(
  ///   hintText: "Begin typing to search for something",
  ///   contentPadding: const EdgeInsets.all(8),
  /// ).applyDefaults(Theme.of(context).inputDecorationTheme)
  /// ```
  final InputDecoration? textFieldInputDecoration;

  /// Sets whether or not prefix text should be added to the text field when a
  /// nested action is selected. If a prefix (i.e. `prefix`, `prefixIcon`,
  /// or `prefixText`) is specified in `textFieldInputDecoration`, this option
  /// will be ignored.
  ///
  /// The text that is shown will be the label of the selected nested action.
  ///
  /// This defaults to true
  final bool prefixNestedActions;

  /// Color used for both the text and icons in the instructions bar.
  ///
  /// Defaults to the color of [actionLabelTextStyle] with an opacity of 84%
  final Color? instructionColor;

  const CommandPaletteStyle({
    this.actionColor,
    this.selectedColor,
    this.actionLabelTextStyle,
    this.highlightedLabelTextStyle,
    this.highlightSearchSubstring = true,
    this.actionDescriptionTextStyle,
    this.elevation = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.actionLabelTextAlign = TextAlign.left,
    this.commandPaletteBarrierColor = Colors.black12,
    this.textFieldInputDecoration,
    this.prefixNestedActions = true,
    this.instructionColor,
    this.barrierFilter,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommandPaletteStyle &&
        other.actionColor == actionColor &&
        other.selectedColor == selectedColor &&
        other.actionLabelTextStyle == actionLabelTextStyle &&
        other.highlightedLabelTextStyle == highlightedLabelTextStyle &&
        other.actionDescriptionTextStyle == actionDescriptionTextStyle &&
        other.highlightSearchSubstring == highlightSearchSubstring &&
        other.elevation == elevation &&
        other.borderRadius == borderRadius &&
        other.actionLabelTextAlign == actionLabelTextAlign &&
        other.commandPaletteBarrierColor == commandPaletteBarrierColor &&
        other.textFieldInputDecoration == textFieldInputDecoration &&
        other.prefixNestedActions == prefixNestedActions &&
        other.instructionColor == instructionColor &&
        other.barrierFilter == barrierFilter;
  }

  @override
  int get hashCode {
    return actionColor.hashCode ^
        selectedColor.hashCode ^
        actionLabelTextStyle.hashCode ^
        highlightedLabelTextStyle.hashCode ^
        actionDescriptionTextStyle.hashCode ^
        highlightSearchSubstring.hashCode ^
        elevation.hashCode ^
        borderRadius.hashCode ^
        actionLabelTextAlign.hashCode ^
        commandPaletteBarrierColor.hashCode ^
        textFieldInputDecoration.hashCode ^
        prefixNestedActions.hashCode ^
        instructionColor.hashCode ^
        barrierFilter.hashCode;
  }
}

const InputDecoration kDefaultInputDecoration = InputDecoration(
  hintText: "Begin typing to search for something",
  contentPadding: EdgeInsets.all(8),
);
