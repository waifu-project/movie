import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/widgets/options/command_palette_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  Future<void> up(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
  }

  Future<void> down(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
  }

  testWidgets(
    "Wrap around scrolling works for large number of items",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          config: CommandPaletteConfig(),
          actions: List.generate(
            100,
            (index) => CommandPaletteAction.single(
              label: "Action $index",
              description: "This is action $index",
              leading: const Icon(Icons.abc),
              onSelect: () {},
            ),
          ),
        ),
      );

      await openPalette(tester);

      await up(tester);
      expect(find.text("Action 99", findRichText: true), findsOneWidget);

      await down(tester);
      expect(find.text("Action 0", findRichText: true), findsOneWidget);
    },
  );

  testWidgets(
    "Items will be visible during keyboard navigation",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          config: CommandPaletteConfig(),
          actions: List.generate(
            100,
            (index) => CommandPaletteAction.single(
              label: "Action $index",
              description: "This is action $index",
              leading: const Icon(Icons.abc),
              onSelect: () {},
            ),
          ),
        ),
      );

      await openPalette(tester);

      for (int selectedItem = 0; selectedItem < 100; selectedItem++) {
        expect(find.text("Action $selectedItem", findRichText: true),
            findsOneWidget);

        await down(tester);
      }

      await up(tester); // back to bottom

      for (int selectedItem = 99; selectedItem >= 0; selectedItem--) {
        expect(find.text("Action $selectedItem", findRichText: true),
            findsOneWidget);

        await up(tester);
      }
    },
  );

  testWidgets(
    "scrolling away and then using an arrow key changes position",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          config: CommandPaletteConfig(),
          actions: List.generate(
            100,
            (index) => CommandPaletteAction.single(
              label: "Action $index",
              description: "This is action $index",
              leading: const Icon(Icons.abc),
              onSelect: () {},
            ),
          ),
        ),
      );

      await openPalette(tester);

      // scroll to the latter half of the options list
      await tester.scrollUntilVisible(
        find.text("Action 65", findRichText: true),
        itemHeight,
        maxScrolls: 100,
        scrollable: find.byType(Scrollable).last,
      );

      await down(tester);
      expect(find.text("Action 1", findRichText: true), findsOneWidget);
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
        child: const Text('Hello World'),
      ),
    );
  }
}
