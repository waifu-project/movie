import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/widgets/command_palette_instructions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  testWidgets(
    "Action Description is displayed",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              description: "This is action 1",
              onSelect: () {},
            ),
          ],
        ),
      );

      await openPalette(tester);

      expect(find.text("This is action 1"), findsOneWidget);

      await closePalette(tester);
    },
  );

  testWidgets(
    "Shortcuts are displayed",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              shortcut: ["ctrl", "a"],
              onSelect: () {},
            ),
          ],
        ),
      );

      await openPalette(tester);
      expect(find.text("CTRL"), findsOneWidget);
      expect(find.text("A"), findsOneWidget);

      await closePalette(tester);
    },
  );

  testWidgets(
    "Highlights are displayed",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              description: "This is action 1",
              onSelect: () {},
            ),
          ],
        ),
      );

      await openPalette(tester);

      await tester.enterText(find.byType(TextField), "tion");
      await tester.pumpAndSettle();

      // verify that the text exists, then find the underlying rich text widget
      expect(find.text("This is action 1"), findsOneWidget);
      final w = find
          .byWidgetPredicate((widget) =>
              widget is RichText &&
              widget.text is TextSpan &&
              ((widget.text as TextSpan).children?.length ?? 0) > 1)
          .evaluate()
          .first
          .widget;

      if (w is RichText) {
        final span = w.text;
        if (span is TextSpan) {
          final children = span.children;

          expect(children?.length, 3);

          // middle child is highlight, verify that
          expect(children![1].style?.color, Colors.pink);
        }
      }

      await closePalette(tester);
    },
  );

  testWidgets(
    "Leading icon is displayed",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              description: "This is action 1",
              leading: const Icon(Icons.abc),
              onSelect: () {},
            ),
          ],
        ),
      );

      await openPalette(tester);

      expect(find.byIcon(Icons.abc), findsOneWidget);

      await closePalette(tester);
    },
  );

  testWidgets(
    "show Instructions",
    (WidgetTester tester) async {
      // default config doesn't show instructions
      await tester.pumpWidget(
        MyApp(
          config: CommandPaletteConfig(),
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              description: "This is action 1",
              leading: const Icon(Icons.abc),
              onSelect: () {},
            ),
          ],
        ),
      );

      await openPalette(tester);
      expect(find.byType(CommandPaletteInstructions), findsNothing);
      await closePalette(tester);

      // setting flag will show instructions
      await tester.pumpWidget(
        MyApp(
          config: CommandPaletteConfig(showInstructions: true),
          actions: [
            CommandPaletteAction.single(
              label: "Action 1",
              description: "This is action 1",
              leading: const Icon(Icons.abc),
              onSelect: () {},
            ),
          ],
        ),
      );

      await openPalette(tester);
      expect(find.byType(CommandPaletteInstructions), findsOneWidget);
    },
  );
}

class MyApp extends StatelessWidget {
  final List<CommandPaletteAction> actions;
  final CommandPaletteConfig config;

  MyApp({
    Key? key,
    required this.actions,
    CommandPaletteConfig? config,
  })  : config = config ??
            CommandPaletteConfig(
              style: const CommandPaletteStyle(
                highlightedLabelTextStyle: TextStyle(color: Colors.pink),
              ),
            ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommandPalette(
        actions: actions,
        config: config,
        child: const Scaffold(
          body: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
