import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/widgets/command_palette_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "Open and close the palette programmatically",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              onSelect: () {},
            ),
          ],
        ),
      );

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);

      closeCP();
      await tester.pumpAndSettle();
      expect(find.byKey(kCommandPaletteModalKey), findsNothing);
    },
  );

  testWidgets(
    "Open to nested action",
    (WidgetTester tester) async {
      String nestedActionId = "Nested Key";
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.single(
              id: "not-nested",
              label: "Action 1",
              onSelect: () {},
            ),
            CommandPaletteAction.nested(
              id: nestedActionId,
              label: "Nested Action",
              childrenActions: [
                CommandPaletteAction.single(
                  label: "I'm nested",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "Me too!",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "Me three!",
                  onSelect: () {},
                ),
              ],
            ),
          ],
        ),
      );

      CommandPalette.of(hackyContext!).openToAction(nestedActionId);
      await tester.pumpAndSettle();
      expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text("I'm nested"), findsOneWidget);
      expect(find.text("Me too!"), findsOneWidget);
      expect(find.text("Me three!"), findsOneWidget);

      // press the backspace to go back up
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(find.text("Action 1"), findsOneWidget);
      expect(find.text("Nested Action"), findsOneWidget);
    },
  );
}

// don't do this in the real world, very bad, just wanting to test
// functionality...
BuildContext? hackyContext;
void closeCP() {
  CommandPalette.of(hackyContext!).close();
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
                  searchTerms) =>
              Text(action.label),
        ),
        child: Builder(
          builder: (context) {
            hackyContext = context;
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    CommandPalette.of(context).open();
                  },
                  child: const Text("Open"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
