import 'package:command_palette/src/controller/command_palette_controller.dart';
import 'package:flutter/material.dart';

/// Creates an icon which represents a keyboard key.
/// This is done either with existing [IconData] which represents the key, or
/// with a [String]
class KeyboardKeyIcon extends StatelessWidget {
  final IconData? icon;
  final String? iconString;
  final Color? color;
  const KeyboardKeyIcon({
    Key? key,
    this.icon,
    this.iconString,
    this.color,
  })  : assert((icon != null && iconString == null) ||
            (icon == null && iconString != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    CommandPaletteController controller =
        CommandPaletteControllerProvider.of(context);
    final outline = Theme.of(context).dividerColor;

    TextStyle? style = controller.style.actionDescriptionTextStyle;
    if (color != null) {
      style = style?.merge(TextStyle(color: color));
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        border: Border.all(color: outline),
        borderRadius: BorderRadius.circular(5),
      ),
      child: icon != null
          ? Icon(
              icon,
              size: controller.style.actionLabelTextStyle?.fontSize,
              color: color,
            )
          : Text(
              iconString!.toUpperCase(),
              style: style,
            ),
    );
  }
}
