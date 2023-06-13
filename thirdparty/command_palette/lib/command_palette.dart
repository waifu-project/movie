library command_palette;

import 'package:flutter/material.dart';

import 'src/models/command_palette_action.dart';
import 'src/models/command_palette_style.dart';

export 'src/command_palette.dart';
export 'src/models/command_palette_action.dart';
export 'src/models/matched_command_palette_action.dart';
export 'src/models/command_palette_style.dart';
export 'src/models/command_palette_config.dart';
export 'src/utils/filter.dart';
export 'src/widgets/keyboard_key_icon.dart';

/// Defines the type of function to be used for filtering command palette
/// actions.
/// Given [query] and [allActions], the function should determine the subset of
/// actions to return based on the function
typedef ActionFilter = List<CommandPaletteAction> Function(
    String query, List<CommandPaletteAction> allActions);

/// Builder used for the action options.
/// Provides the following arguments:
/// * [style]: The style provided to the command palette
/// * [action]: The action we're building a widget for
/// * [isHighlighted]: Whether or not the action is the currently highlighted
///     one (selected by the cursor)
/// * [onSelected]: Callback that's to be called when the action is clicked on
/// * [searchTerms]: Terms used to search. Taken from the text entered into the
///     text field, splitting on space.
typedef ActionBuilder = Widget Function(
  BuildContext context,
  CommandPaletteStyle style,
  CommandPaletteAction action,
  bool isHighlighted,
  VoidCallback onSelected,
  List<String> searchTerms,
);
