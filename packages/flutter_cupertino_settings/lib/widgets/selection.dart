part of flutter_cupertino_settings;

/// A selection view
/// Allows to select between multiple items
/// Every item is represented by a String
///
/// If an item is selected, onSelected is called with its index
///
/// eg:
/// items = ["hello","world","flutter"]
/// select "world"
///
/// onSelected(1)

class CSSelection<T> extends StatelessWidget {
  final List<CSSelectionItem<T>> items;
  final void Function(T selected) onSelected;
  final T? currentSelection;
  final double fontSize;

  const CSSelection({Key? key, 
    required this.items,
    required this.onSelected,
    this.currentSelection,
    this.fontSize = CS_TITLE_FONT_SIZE,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map<Widget>((item) => createItem(context, item)).toList(),
    );
  }

  Widget createItem(BuildContext context, CSSelectionItem<T> item) {
    final text = Text(item.text,
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: fontSize,
        ));
    final textWidget = item.subtitle == null
        ? text
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            text,
            SizedBox(height: 2),
            Text(item.subtitle!,
                style: basicTextStyle(context).copyWith(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: CS_HEADER_FONT_SIZE))
          ]);
    return CSWidget(
      CupertinoButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onSelected(item.value);
        },
        pressedOpacity: 1.0,
        padding: const EdgeInsets.fromLTRB(4, 8, 2, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: textWidget),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                CupertinoIcons.check_mark,
                color: item.value == currentSelection
                    ? CupertinoColors.activeBlue
                    : const Color(0x00000000),
                size: CS_CHECK_SIZE,
              ),
            ),
          ],
        ),
      ),
      addPaddingToBorder: items.last != item,
      showTopBorder: item.showTopBorder,
    );
  }
}

class CSSelectionItem<T> {
  final T value;
  final String text;
  final String? subtitle;
  final bool showTopBorder;

  const CSSelectionItem({
    required this.value,
    required this.text,
    this.subtitle,
    this.showTopBorder = false,
  });
}
