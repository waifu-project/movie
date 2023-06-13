import 'package:command_palette/command_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  testWidgets(
    "Prefix text is shown for nested action",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.nested(
              label: "Change Theme",
              description: "Change the color theme of the app",
              shortcut: ["ctrl", "t"],
              childrenActions: [
                CommandPaletteAction.single(
                  label: "Light",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "Dark",
                  onSelect: () {},
                ),
              ],
            ),
          ],
        ),
      );

      await openPalette(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // nested action's label should be displayed when it's the selected widget
      expect(find.text("Change Theme: "), findsOneWidget);

      // backing out of the nested widget will make the label go away
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(find.text("Change Theme: "), findsNothing);
    },
  );
}

class MyApp extends StatelessWidget {
  final List<CommandPaletteAction> actions;

  const MyApp({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommandPalette(
        actions: actions,
        config: CommandPaletteConfig(
            builder: (context, style, action, isHighlighted, onSelected,
                searchTerms) {
              return Text(action.label);
            },
            style: const CommandPaletteStyle(
                highlightedLabelTextStyle: TextStyle(color: Colors.pink))),
        child: const Scaffold(
          body: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
