import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:command_palette/src/widgets/command_palette_instructions.dart';
import 'package:command_palette/src/widgets/options/option_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';

const double itemHeight = 52;

/// Displays all the available [CommandPaletteAction] options based upon various
/// filtering criteria.
/// Also displays [CommandPaletteInstructions] if that's enabled
class CommandPaletteBody extends StatefulWidget {
  const CommandPaletteBody({
    Key? key,
  }) : super(key: key);

  @override
  State<CommandPaletteBody> createState() => _CommandPaletteBodyState();
}

class _CommandPaletteBodyState extends State<CommandPaletteBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final idx = CommandPaletteControllerProvider.of(context).highlightedAction;
    if (_scrollController.hasClients) {
      final scrollViewHeight = _scrollController.position.viewportDimension;
      final scrollViewTopOffset = _scrollController.offset;
      final scrollViewBottomOffset = scrollViewTopOffset + scrollViewHeight;

      final selectedItemTop = idx * itemHeight;
      final selectedItemBottom = selectedItemTop + itemHeight;

      double posToScrollTo = -1;
      if (selectedItemTop < scrollViewTopOffset) {
        posToScrollTo = selectedItemTop;
      } else if (selectedItemBottom > scrollViewBottomOffset) {
        // align bottom of item to bottom
        posToScrollTo = selectedItemBottom - scrollViewHeight;
      }

      if (posToScrollTo != -1) {
        _scrollController.jumpTo(posToScrollTo);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommandPaletteController controller =
        CommandPaletteControllerProvider.of(context);
    List<CommandPaletteAction> filteredActions =
        controller.getFilteredActions();
    final borderRadius =
        controller.style.borderRadius.resolve(Directionality.of(context));

    return Material(
      elevation: controller.style.elevation,
      borderRadius: BorderRadius.only(
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              itemCount: filteredActions.length,
              itemBuilder: (context, index) {
                final CommandPaletteAction item = filteredActions[index];

                return controller.config.builder(
                  context,
                  controller.style,
                  item,
                  controller.highlightedAction == index,
                  () => controller.handleAction(context, action: item),
                  controller.textEditingController.text.split(" "),
                );
              },
            ),
          ),
          if (controller.config.showInstructions)
            const CommandPaletteInstructions(),
        ],
      ),
    );
  }
}

class _DefaultItem extends StatelessWidget {
  final CommandPaletteStyle style;
  final CommandPaletteAction action;
  final bool isHighlighted;
  final VoidCallback onSelected;
  final List<String> searchTerms;
  const _DefaultItem({
    Key? key,
    required this.style,
    required this.action,
    required this.isHighlighted,
    required this.onSelected,
    required this.searchTerms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget label;

    // if highlighting the search substring is enabled, then we'll use one of the
    // two widgets for that
    if (style.highlightSearchSubstring) {
      // if the action is a MatchedCommandPaletteAction, then we'll use our
      // own highlighter here.
      if (action is MatchedCommandPaletteAction &&
          (action as MatchedCommandPaletteAction).matches != null) {
        label = OptionHighlighter(
          action: (action as MatchedCommandPaletteAction),
          textStyle: style.actionLabelTextStyle!,
          textAlign: style.actionLabelTextAlign,
          textStyleHighlight: style.highlightedLabelTextStyle!,
        );
      }
      // if it's just a generic action, then we'll use the 3rd party highlighter.
      // This likely means that the user made their own filtering solution.
      else {
        label = SubstringHighlight(
          text: action.label,
          textAlign: style.actionLabelTextAlign,
          terms: searchTerms,
          textStyle: style.actionLabelTextStyle!,
          textStyleHighlight: style.highlightedLabelTextStyle!,
        );
      }
    }
    // otherwise, just use a plain ol' text widget
    else {
      label = Text(
        action.label,
        textAlign: style.actionLabelTextAlign,
        style: style.actionLabelTextStyle!,
      );
    }

    Widget? shortcuts;
    if (action.shortcut != null) {
      shortcuts = Wrap(
        alignment: WrapAlignment.end,
        children: action.shortcut!
            .map<Widget>(
              (e) => KeyboardKeyIcon(
                iconString: e,
              ),
            )
            .toList(),
      );
    }

    final bool hasDescription = action.description != null;
    return Material(
      color: isHighlighted ? style.selectedColor : style.actionColor,
      child: SizedBox(
        height: itemHeight,
        child: InkWell(
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (action.leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: action.leading!,
                  ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Expanded(child: label),
                          ],
                        ),
                      ),
                      if (hasDescription)
                        Flexible(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  action.description!,
                                  textAlign: style.actionLabelTextAlign,
                                  style: style.actionDescriptionTextStyle,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (shortcuts != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: shortcuts,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Default builder of Actions.
/// Uses all the parameters, so this is a good place to look if you're wanting
/// to create your our custom builder
// ignore: prefer_function_declarations_over_variables
final ActionBuilder kDefaultBuilder = (
  BuildContext context,
  CommandPaletteStyle style,
  CommandPaletteAction action,
  bool isHighlighted,
  VoidCallback onSelected,
  List<String> searchTerms,
) =>
    _DefaultItem(
      action: action,
      style: style,
      isHighlighted: isHighlighted,
      onSelected: onSelected,
      searchTerms: searchTerms,
    );
