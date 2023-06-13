import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:command_palette/src/widgets/keyboard_key_icon.dart';
import 'package:flutter/material.dart';

/// Basic instructions for command palette use
class CommandPaletteInstructions extends StatelessWidget {
  const CommandPaletteInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommandPaletteController controller =
        CommandPaletteControllerProvider.of(context);
    final outline = Theme.of(context).dividerColor;
    var color = controller.style.instructionColor;
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: controller.style.actionColor,
        border: Border(
          top: BorderSide(color: outline),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Wrap(
              runSpacing: 4,
              children: [
                _KeyboardInstruction(
                  icons: [
                    KeyboardKeyIcon(
                      icon: Icons.keyboard_return,
                      color: color,
                    ),
                  ],
                  instruction: "to select",
                ),
                _KeyboardInstruction(
                  icons: [
                    KeyboardKeyIcon(
                      icon: Icons.arrow_upward,
                      color: color,
                    ),
                    KeyboardKeyIcon(
                      icon: Icons.arrow_downward,
                      color: color,
                    ),
                  ],
                  instruction: "to navigate",
                ),
                if (controller.currentlySelectedAction != null)
                  _KeyboardInstruction(
                    icons: [
                      KeyboardKeyIcon(
                        icon: Icons.keyboard_backspace,
                        color: color,
                      ),
                    ],
                    instruction: "to cancel selected action",
                  ),
                _KeyboardInstruction(
                  icons: [
                    KeyboardKeyIcon(
                      iconString: "esc",
                      color: color,
                    ),
                  ],
                  instruction: "to close",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardInstruction extends StatelessWidget {
  final List<KeyboardKeyIcon> icons;
  final String instruction;
  const _KeyboardInstruction({
    Key? key,
    required this.icons,
    required this.instruction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommandPaletteController controller =
        CommandPaletteControllerProvider.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final icon in icons) icon,
          Flexible(
            child: Text(
              instruction,
              style: controller.style.actionLabelTextStyle?.merge(
                TextStyle(
                  color: controller.style.instructionColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
