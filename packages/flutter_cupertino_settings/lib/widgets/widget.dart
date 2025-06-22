part of flutter_cupertino_settings;

/// Used to display a widget of any kind in [CupertinoSettings]
/// It provices the correct height, color and border to create the intended look
/// The optional [alignment] attribute allows to specify the aligment inside the container
/// The optional [style] attribute allows to specify a style (e.g. an Icon)
class CSWidget extends StatelessWidget {
  final Widget widget;
  final AlignmentGeometry? alignment;
  final double height;
  final CSWidgetStyle style;
  final bool addPaddingToBorder;
  final bool showTopBorder;

  const CSWidget(
    this.widget, {Key? key, 
    this.alignment,
    this.height = CS_ITEM_HEIGHT,
    this.style = CS_DEFAULT_STYLE,
    this.addPaddingToBorder = false,
    this.showTopBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child;
    EdgeInsets padding;

    //style.icon
    if (style.icon != null) {
      padding = CS_ICON_PADDING;
      child = Row(
        children: <Widget>[
          Container(
            padding: CS_ICON_PADDING,
            child: style.icon,
          ),
          Expanded(child: widget)
        ],
      );
    } else {
      child = widget;
      padding = CS_ITEM_PADDING;
    }

    return Container(
      alignment: alignment,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        border: Border(
          top: showTopBorder
              ? BorderSide(
                  color: CupertinoColors.opaqueSeparator.resolveFrom(context),
                )
              : BorderSide.none,
        ),
      ),
      constraints: const BoxConstraints(minHeight: 42),
      // height: height,
      padding: EdgeInsets.only(
        left: addPaddingToBorder ? padding.left : 0,
      ),
      child: Container(
        padding: padding.copyWith(
          left: addPaddingToBorder ? 2 : padding.left + 2,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.opaqueSeparator.resolveFrom(context),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Defines style attributes that can be applied to every [CSWidget]
class CSWidgetStyle {
  final Icon? icon;

  const CSWidgetStyle({this.icon});
}

enum ItemType { single, list, listLast }
