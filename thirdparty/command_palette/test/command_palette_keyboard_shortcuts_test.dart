import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/widgets/command_palette_modal.dart';

import 'utils.dart';

/// Tests here make sure that keyboard shortcuts work, and that their side
/// effects happen as intended.
void main() {
  group(
    "Default keyboard shortcuts",
    () {
      testWidgets(
        "Open and Close Palette",
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
          expect(find.byKey(kCommandPaletteModalKey), findsNothing);

          // send open shortcut
          await openPalette(tester);

          expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);

          await closePalette(tester);
          expect(find.byKey(kCommandPaletteModalKey), findsNothing);
        },
      );

      testWidgets(
        "Down arrow key",
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MyApp(
              builder: (context, style, action, isHighlighted, onSelected,
                  searchTerms) {
                return Text("${action.label}-$isHighlighted");
              },
              actions: [
                CommandPaletteAction.single(
                  label: "1",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "2",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "3",
                  onSelect: () {},
                ),
              ],
            ),
          );

          await openPalette(tester);

          // by default 1 will be highlighted. 2 won't be.
          expect(find.text("1-true"), findsOneWidget);
          expect(find.text("2-false"), findsOneWidget);
          expect(find.text("3-false"), findsOneWidget);

          // down arrow
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();

          // 2 will be highlighted now
          expect(find.text("1-false"), findsOneWidget);
          expect(find.text("2-true"), findsOneWidget);
          expect(find.text("3-false"), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(find.text("1-false"), findsOneWidget);
          expect(find.text("2-false"), findsOneWidget);
          expect(find.text("3-true"), findsOneWidget);

          // down wraps around
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(find.text("1-true"), findsOneWidget);
          expect(find.text("2-false"), findsOneWidget);
          expect(find.text("3-false"), findsOneWidget);

          await closePalette(tester);
        },
      );
      testWidgets(
        "Up arrow key",
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MyApp(
              builder: (context, style, action, isHighlighted, onSelected,
                  searchTerms) {
                return Text("${action.label}-$isHighlighted");
              },
              actions: [
                CommandPaletteAction.single(
                  label: "1",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "2",
                  onSelect: () {},
                ),
                CommandPaletteAction.single(
                  label: "3",
                  onSelect: () {},
                ),
              ],
            ),
          );

          await openPalette(tester);

          // by default 1 will be highlighted. 2 won't be.
          expect(find.text("1-true"), findsOneWidget);
          expect(find.text("2-false"), findsOneWidget);
          expect(find.text("3-false"), findsOneWidget);

          // up arrow, this will wrap around to 3
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();

          // 3 will be highlighted now
          expect(find.text("1-false"), findsOneWidget);
          expect(find.text("2-false"), findsOneWidget);
          expect(find.text("3-true"), findsOneWidget);

          // up arrow, this will move up to 2
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();
          expect(find.text("1-false"), findsOneWidget);
          expect(find.text("2-true"), findsOneWidget);
          expect(find.text("3-false"), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();
          expect(find.text("1-true"), findsOneWidget);
          expect(find.text("2-false"), findsOneWidget);
          expect(find.text("3-false"), findsOneWidget);

          await closePalette(tester);
        },
      );

      testWidgets(
        "Enter (Single Option)",
        (WidgetTester tester) async {
          bool action1Selected = false;
          await tester.pumpWidget(
            MyApp(
              actions: [
                CommandPaletteAction.single(
                  label: "Action 1",
                  onSelect: () {
                    action1Selected = true;
                  },
                ),
              ],
            ),
          );
          await openPalette(tester);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(action1Selected, true);

          // selecting a single action closes the palette
          expect(find.byKey(kCommandPaletteModalKey), findsNothing);
        },
      );

      testWidgets(
        "Enter (Nested Option)",
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MyApp(
              actions: [
                CommandPaletteAction.nested(
                  label: "Action 1",
                  childrenActions: [
                    CommandPaletteAction.single(
                      label: "Nested Action 1",
                      onSelect: () {},
                    ),
                  ],
                ),
                CommandPaletteAction.single(
                  label: "Action 2",
                  onSelect: () {},
                ),
              ],
            ),
          );
          await openPalette(tester);
          await tester.pumpAndSettle();

          expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);

          expect(find.text("Action 1"), findsOneWidget);
          expect(find.text("Action 2"), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          // palette still open
          expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);

          // only child option is shown
          expect(find.text("Nested Action 1"), findsOneWidget);
          expect(find.text("Action 1"), findsNothing);
          expect(find.text("Action 2"), findsNothing);

          await closePalette(tester);
        },
      );

      testWidgets(
        "Backspace (from nested item)",
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MyApp(
              actions: [
                CommandPaletteAction.nested(
                  label: "Action 1",
                  childrenActions: [
                    CommandPaletteAction.single(
                      label: "Nested Action 1",
                      onSelect: () {},
                    ),
                  ],
                ),
                CommandPaletteAction.single(
                  label: "Action 2",
                  onSelect: () {},
                ),
              ],
            ),
          );
          await openPalette(tester);
          await tester.pumpAndSettle();

          expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          await tester.pumpAndSettle();

          expect(find.text("Action 1"), findsOneWidget);
          expect(find.text("Action 2"), findsOneWidget);
          await closePalette(tester);
        },
      );

      testWidgets(
        "Backspace (text)",
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
          await openPalette(tester);
          await tester.pumpAndSettle();

          // enter text
          await tester.enterText(find.byType(TextField), "A");
          await tester.pumpAndSettle();

          // text should be there
          expect(find.widgetWithText(TextField, "A"), findsOneWidget);

          // backspace deletes a character
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          await tester.pumpAndSettle();

          // character should be gone
          expect(find.widgetWithText(TextField, ""), findsOneWidget);

          await closePalette(tester);
        },
      );
    },
  );

  group(
    "Custom Keyboard Shortcuts",
    () {
      testWidgets(
        "Custom Open",
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MyApp(
              openKeySet: const SingleActivator(
                LogicalKeyboardKey.keyJ,
                alt: true,
              ),
              actions: [
                CommandPaletteAction.single(
                  label: "Action 1",
                  onSelect: () {},
                ),
              ],
            ),
          );

          await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
          await tester.pumpAndSettle();
          expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);

          await closePalette(tester); // escape always closes

          // default shortcuts shouldn't work
          await openPalette(tester);
          expect(find.byKey(kCommandPaletteModalKey), findsNothing);
        },
      );

      testWidgets(
        "Custom Close",
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MyApp(
              closeKeySet: const SingleActivator(
                LogicalKeyboardKey.keyJ,
                alt: true,
              ),
              actions: [
                CommandPaletteAction.single(
                  label: "Action 1",
                  onSelect: () {},
                ),
              ],
            ),
          );
          await openPalette(tester);
          expect(find.byKey(kCommandPaletteModalKey), findsOneWidget);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.alt);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.alt);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
          await tester.pumpAndSettle();
          expect(find.byKey(kCommandPaletteModalKey), findsNothing);
        },
      );
    },
  );
}

class MyApp extends StatelessWidget {
  final List<CommandPaletteAction> actions;
  final ActionBuilder? builder;
  final ShortcutActivator? openKeySet;
  final ShortcutActivator? closeKeySet;

  const MyApp({
    Key? key,
    required this.actions,
    this.builder,
    this.openKeySet,
    this.closeKeySet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommandPalette(
        actions: actions,
        config: CommandPaletteConfig(
          builder: builder,
          openKeySet: openKeySet,
          closeKeySet: closeKeySet,
          style: const CommandPaletteStyle(
            // have to turn highlighting off in order to find by text
            highlightSearchSubstring: false,
          ),
        ),
        child: const Scaffold(
          body: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
