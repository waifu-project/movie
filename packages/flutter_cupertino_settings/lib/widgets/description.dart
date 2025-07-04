part of flutter_cupertino_settings;

class CSDescription extends StatelessWidget {
  final String description;
  final String? fontFamily;

  const CSDescription(this.description, {Key? key, this.fontFamily}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7.5, 5, 5),
      color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: Text(
        description,
        style: basicTextStyle(context).copyWith(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          fontFamily: fontFamily,
          fontSize: CS_DESCRIPTION_FONT_SIZE,
          height: 1.1,
        ),
      ),
    );
  }
}
