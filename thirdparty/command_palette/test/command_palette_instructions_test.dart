import 'package:command_palette/command_palette.dart';
import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:command_palette/src/widgets/command_palette_instructions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "Go Back instruction will be displayed when nested action is selected",
    (WidgetTester tester) async {
      final action = CommandPaletteAction.nested(
        label: "Nest",
        childrenActions: [
          CommandPaletteAction.single(
            label: "Nested",
            onSelect: () {},
          )
        ],
      );
      CommandPaletteController controller = CommandPaletteController(
        [
          action,
        ],
        config: CommandPaletteConfig(showInstructions: true),
      );

      controller.currentlySelectedAction = action;

      await tester.pumpWidget(
        MyApp(controller: controller),
      );

      expect(find.text("to cancel selected action"), findsOneWidget);
    },
  );

  testWidgets(
    "Go Back instruction will not be displayed when no action is selected",
    (WidgetTester tester) async {
      CommandPaletteController controller = CommandPaletteController(
        [
          CommandPaletteAction.nested(
            label: "Nest",
            childrenActions: [
              CommandPaletteAction.single(
                label: "Nested",
                onSelect: () {},
              )
            ],
          ),
        ],
        config: CommandPaletteConfig(showInstructions: true),
      );

      await tester.pumpWidget(
        MyApp(controller: controller),
      );

      expect(find.text("to cancel selected action"), findsNothing);
    },
  );
}

class MyApp extends StatelessWidget {
  final CommandPaletteController controller;
  const MyApp({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommandPaletteControllerProvider(
        controller: controller,
        child: const CommandPaletteInstructions(),
      ),
    );
  }
}
