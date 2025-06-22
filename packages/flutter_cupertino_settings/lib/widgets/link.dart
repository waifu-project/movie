part of flutter_cupertino_settings;

/// Provides a button for navigation
class CSLink extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? detail;
  final VoidCallback? onPressed;
  final double titleFontSize;
  final double subTitleFontSize;
  final CSWidgetStyle style;
  final bool addPaddingToBorder;
  final bool showTopBorder;
  final Widget? trailing;
  final CellType cellType;

  const CSLink({
    required this.title,
    this.onPressed,
    this.subtitle,
    this.detail,
    this.style = CS_DEFAULT_STYLE,
    this.titleFontSize = CS_TITLE_FONT_SIZE,
    this.subTitleFontSize = CS_SUBTITLE_FONT_SIZE,
    this.addPaddingToBorder = true,
    this.showTopBorder = false,
    this.trailing,
    this.cellType = CellType.defaultStyle,
  });

  @override
  Widget build(BuildContext context) {
    final showSubtitle = (cellType == CellType.subtitleDetailStyle ||
            cellType == CellType.subtitleStyle) &&
        subtitle != null &&
        subtitle!.isNotEmpty;
    final showDetail = (cellType == CellType.subtitleDetailStyle ||
            cellType == CellType.detailRightStyle) &&
        detail != null &&
        detail!.isNotEmpty;

    return CSWidget(
      CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: basicTextStyle(context).copyWith(
                      color: CupertinoColors.label.resolveFrom(context),
                      fontSize: titleFontSize,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showSubtitle) const SizedBox(height: 2),
                  if (showSubtitle)
                    Text(
                      subtitle!,
                      style: basicTextStyle(context).copyWith(
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                        fontSize: subTitleFontSize,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                ],
              ),
            ),
            if (showDetail) ...[
              Text(
                detail!,
                style: basicTextStyle(context).copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: titleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
              const SizedBox(width: 4),
            ],
            Padding(
              padding: const EdgeInsets.only(left: 1.0, right: 2.0),
              child: trailing ??
                  Icon(
                    CupertinoIcons.right_chevron,
                    color: CupertinoColors.secondaryLabel
                        .resolveFrom(context)
                        .withValues(alpha: .4),
                    size: CS_CHEVRON_SIZE,
                  ),
            ),
          ],
        ),
      ),
      style: style,
      addPaddingToBorder: addPaddingToBorder,
      showTopBorder: showTopBorder,
    );
  }
}

enum CellType {
  /// Default Style with optional widget on left side and left-aligned title
  defaultStyle,

  /// Left-aligned title and left-aligned subtitle below
  subtitleStyle,

  /// Left-aligned title, left-aligned subtitle below and right-aligned detail
  subtitleDetailStyle,

  /// Left-aligned title and right-aligned detail
  detailRightStyle,

  /// right-aligned title and left-aligned detail
  detailLeftStyle,
}
