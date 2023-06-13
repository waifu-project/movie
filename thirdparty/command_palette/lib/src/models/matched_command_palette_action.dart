import 'package:command_palette/command_palette.dart';

/// An action that was matched to the entered query. Contains both the action
/// itself and a list of the matches contained within
class MatchedCommandPaletteAction extends CommandPaletteAction {
  final List<FilterMatch>? matches;

  MatchedCommandPaletteAction(CommandPaletteAction action, this.matches)
      // ignore: deprecated_member_use_from_same_package
      : super(
          label: action.label,
          actionType: action.actionType,
          childrenActions: action.childrenActions,
          description: action.description,
          onSelect: action.onSelect,
          shortcut: action.shortcut,
          id: action.id,
          leading: action.leading,
        );
}
