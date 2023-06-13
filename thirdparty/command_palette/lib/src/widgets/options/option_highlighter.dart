import 'package:command_palette/src/models/matched_command_palette_action.dart';
import 'package:flutter/material.dart';

/// Highlights the label of a command option
class OptionHighlighter extends StatelessWidget {
  final MatchedCommandPaletteAction action;
  final TextStyle textStyle;
  final TextStyle textStyleHighlight;
  final TextAlign textAlign;

  OptionHighlighter({
    Key? key,
    required this.action,
    required this.textAlign,
    required this.textStyle,
    required this.textStyleHighlight,
  })  : assert(action.matches != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> formattedText = [];

    int endOfLastSubString = 0;

    for (final match in action.matches!) {
      // print out all the non-highlighted text up to this point
      formattedText.add(
        TextSpan(
          text: action.label.substring(endOfLastSubString, match.start),
          style: textStyle,
        ),
      );

      // now print the highlighted text
      formattedText.add(
        TextSpan(
          text: action.label.substring(match.start, match.end),
          style: textStyleHighlight,
        ),
      );

      endOfLastSubString = match.end;
    }

    // if there is still some text at the very end, we'll print that out too.
    if (endOfLastSubString != action.label.length) {
      formattedText.add(
        TextSpan(
          text: action.label.substring(endOfLastSubString, action.label.length),
          style: textStyle,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: formattedText),
      textAlign: textAlign,
    );
  }
}
