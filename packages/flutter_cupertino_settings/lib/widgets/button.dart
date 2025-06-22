part of flutter_cupertino_settings;

/// A button-cell inside [CupertinoSettings]
/// 3 different types are available (they only affect the design):
/// [CSButtonType.DESTRUCTIVE] Red and centered
/// [CSButtonType.DEFAULT] Blue and left aligned
/// [CSButtonType.DEFAULT_CENTER] Blue and centered
/// Provides the correct paddings and text properties
///
/// It is quite complex:
///
/// -- Widget
///   |- Flex
///     |- Expand
///       |- CupertinoButton
///         |- Container        (<--- For text-alignment)
///           |- Text
///
/// This "hack" is mandatory to archive that...
/// 1) The button can be aligned
/// 2) The entire row is touch-sensitive
class CSButton extends CSWidget {
  final CSButtonType buttonType;
  final String text;
  final VoidCallback pressed;
  final double fontSize;

  CSButton(
    this.buttonType,
    this.text,
    this.pressed, {Key? key, 
    CSWidgetStyle style = CS_DEFAULT_STYLE,
    this.fontSize = CS_TITLE_FONT_SIZE,
  }) : super(
          Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: pressed,
                  child: Container(
                    alignment: buttonType.alignment,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: buttonType.color,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
           key: key, style: style,
        );
}

/// Defines different types for [CSButton]
/// Specifies color and alignment
class CSButtonType {
  static const CSButtonType DESTRUCTIVE = CSButtonType(
    CupertinoColors.destructiveRed,
    AlignmentDirectional.center,
  );
  static const CSButtonType DEFAULT = CSButtonType(
    CupertinoColors.systemBlue,
    AlignmentDirectional.centerStart,
  );
  static const CSButtonType DEFAULT_CENTER = CSButtonType(
    CupertinoColors.systemBlue,
    AlignmentDirectional.center,
  );

  final Color color;
  final AlignmentGeometry alignment;

  const CSButtonType(this.color, this.alignment);
}
