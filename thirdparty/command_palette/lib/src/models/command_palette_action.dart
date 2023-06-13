import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The different type of command palette
enum CommandPaletteActionType {
  /// A single action will call a callback when it is selected.
  single,

  /// Upon being selected a nested action will change the state of the command
  /// palette so that it only shows its children
  nested
}

/// Action that is presented in the command palette. These are the things the
/// user will be presented with to choose from
class CommandPaletteAction {
  /// The "primary" text of the action. This will be used by the searching
  /// algorithm to find this action.
  final String label;

  /// Optional description which'll be displayed under the [label], if the
  /// default builder is used.
  final String? description;

  /// Specifies what type of action this is
  final CommandPaletteActionType actionType;

  /// Required when [actionType] set to [CommandPaletteActionType.single]. This
  /// function is called when the action is selected
  VoidCallback? onSelect;

  /// Required when [actionType] set to [CommandPaletteActionType.nested]. These are
  /// the actions that will be displayed when this action is selected
  List<CommandPaletteAction>? childrenActions;

  /// For widgets that exist inside of a nested action, this points to their
  /// parent action
  CommandPaletteAction? _parent;

  /// Returns the parent of this action. Null indicates that it's a top-level
  /// action
  CommandPaletteAction? getParent() => _parent;

  /// List of strings representing the keyboard shortcut to invoke the action.
  ///
  /// Note that this doesn't set any handlers for shortcuts, but just adds a
  /// visual indicator.
  List<String>? shortcut;

  /// The id of an action should be used to uniquely identify the action.
  /// Whatever type is specified should be comparable.
  ///
  /// The primary purpose of the ID is to be able to open to a specific nested
  /// action.
  Object? id;

  /// Optional widget that will be placed at the start of the action widget.
  /// Intended to be an [Icon], but really anything could suffice.
  ///
  /// When using the default option builder, the leading widget is given 8.0
  /// padding to the right
  Widget? leading;

  @Deprecated("Prefer using the named constructors '.single' or '.nested'")
  CommandPaletteAction({
    required this.label,
    this.description,
    required this.actionType,
    this.onSelect,
    this.childrenActions,
    this.shortcut,
    this.id,
    this.leading,
  }) : assert((actionType == CommandPaletteActionType.single &&
                onSelect != null) ||
            (actionType == CommandPaletteActionType.nested &&
                (childrenActions?.isNotEmpty ?? false))) {
    // give all our children "us" as a parent.
    if (actionType == CommandPaletteActionType.nested) {
      for (final child in childrenActions!) {
        child._parent = this;
      }
    }
  }

  CommandPaletteAction.single({
    required this.label,
    this.description,
    required this.onSelect,
    this.shortcut,
    this.id,
    this.leading,
  }) : actionType = CommandPaletteActionType.single;

  CommandPaletteAction.nested({
    required this.label,
    this.description,
    required this.childrenActions,
    this.shortcut,
    this.id,
    this.leading,
  }) : actionType = CommandPaletteActionType.nested {
    // give all our children "us" as a parent.
    for (final child in childrenActions!) {
      child._parent = this;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommandPaletteAction &&
        other.label == label &&
        other.description == description &&
        other.actionType == actionType &&
        other.onSelect == onSelect &&
        listEquals(other.childrenActions, childrenActions) &&
        listEquals(other.shortcut, shortcut);
  }

  @override
  int get hashCode {
    return label.hashCode ^
        description.hashCode ^
        actionType.hashCode ^
        onSelect.hashCode ^
        childrenActions.hashCode ^
        shortcut.hashCode;
  }
}
