import 'dart:ui';

import 'package:flutter/material.dart';

import 'html_parser.dart';
import 'src/css_parser.dart';

///This class represents all the available CSS attributes
///for this package.
class Style {
  /// CSS attribute "`background-color`"
  ///
  /// Inherited: no,
  /// Default: Colors.transparent,
  Color? backgroundColor;

  /// CSS attribute "`color`"
  ///
  /// Inherited: yes,
  /// Default: unspecified,
  Color? color;

  /// CSS attribute "`direction`"
  ///
  /// Inherited: yes,
  /// Default: TextDirection.ltr,
  TextDirection? direction;

  /// CSS attribute "`display`"
  ///
  /// Inherited: no,
  /// Default: unspecified,
  Display? display;

  /// CSS attribute "`font-family`"
  ///
  /// Inherited: yes,
  /// Default: Theme.of(context).style.textTheme.body1.fontFamily
  String? fontFamily;


  /// The list of font families to fall back on when a glyph cannot be found in default font family.
  ///
  /// Inherited: yes,
  /// Default: null
  List<String>? fontFamilyFallback;


  /// CSS attribute "`font-feature-settings`"
  ///
  /// Inherited: yes,
  /// Default: normal
  List<FontFeature>? fontFeatureSettings;

  /// CSS attribute "`font-size`"
  ///
  /// Inherited: yes,
  /// Default: FontSize.medium
  FontSize? fontSize;

  /// CSS attribute "`font-style`"
  ///
  /// Inherited: yes,
  /// Default: FontStyle.normal,
  FontStyle? fontStyle;

  /// CSS attribute "`font-weight`"
  ///
  /// Inherited: yes,
  /// Default: FontWeight.normal,
  FontWeight? fontWeight;

  /// CSS attribute "`height`"
  ///
  /// Inherited: no,
  /// Default: Unspecified (null),
  double? height;

  /// CSS attribute "`letter-spacing`"
  ///
  /// Inherited: yes,
  /// Default: normal (0),
  double? letterSpacing;

  /// CSS attribute "`list-style-type`"
  ///
  /// Inherited: yes,
  /// Default: ListStyleType.DISC
  ListStyleType? listStyleType;

  /// CSS attribute "`list-style-position`"
  ///
  /// Inherited: yes,
  /// Default: ListStylePosition.OUTSIDE
  ListStylePosition? listStylePosition;

  /// CSS attribute "`padding`"
  ///
  /// Inherited: no,
  /// Default: EdgeInsets.zero
  EdgeInsets? padding;

  /// CSS attribute "`margin`"
  ///
  /// Inherited: no,
  /// Default: EdgeInsets.zero
  EdgeInsets? margin;

  /// CSS attribute "`text-align`"
  ///
  /// Inherited: yes,
  /// Default: TextAlign.start,
  TextAlign? textAlign;

  /// CSS attribute "`text-decoration`"
  ///
  /// Inherited: no,
  /// Default: TextDecoration.none,
  TextDecoration? textDecoration;

  /// CSS attribute "`text-decoration-color`"
  ///
  /// Inherited: no,
  /// Default: Current color
  Color? textDecorationColor;

  /// CSS attribute "`text-decoration-style`"
  ///
  /// Inherited: no,
  /// Default: TextDecorationStyle.solid,
  TextDecorationStyle? textDecorationStyle;

  /// Loosely based on CSS attribute "`text-decoration-thickness`"
  ///
  /// Uses a percent modifier based on the font size.
  ///
  /// Inherited: no,
  /// Default: 1.0 (specified by font size)
  // TODO(Sub6Resources): Possibly base this more closely on the CSS attribute.
  double? textDecorationThickness;

  /// CSS attribute "`text-shadow`"
  ///
  /// Inherited: yes,
  /// Default: none,
  List<Shadow>? textShadow;

  /// CSS attribute "`vertical-align`"
  ///
  /// Inherited: no,
  /// Default: VerticalAlign.BASELINE,
  VerticalAlign? verticalAlign;

  /// CSS attribute "`white-space`"
  ///
  /// Inherited: yes,
  /// Default: WhiteSpace.NORMAL,
  WhiteSpace? whiteSpace;

  /// CSS attribute "`width`"
  ///
  /// Inherited: no,
  /// Default: unspecified (null)
  double? width;

  /// CSS attribute "`word-spacing`"
  ///
  /// Inherited: yes,
  /// Default: normal (0)
  double? wordSpacing;

  /// CSS attribute "`line-height`"
  ///
  /// Supported values: double values
  ///
  /// Unsupported values: normal, 80%, ..
  ///
  /// Inherited: no,
  /// Default: Unspecified (null),
  LineHeight? lineHeight;

  //TODO modify these to match CSS styles
  String? before;
  String? after;
  Border? border;
  Alignment? alignment;
  Widget? markerContent;

  /// MaxLine
  ///
  ///
  ///
  ///
  int? maxLines;

  /// TextOverflow
  ///
  ///
  ///
  ///
  TextOverflow? textOverflow;

  TextTransform? textTransform;

  Style({
    this.backgroundColor = Colors.transparent,
    this.color,
    this.direction,
    this.display,
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontFeatureSettings,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.height,
    this.lineHeight,
    this.letterSpacing,
    this.listStyleType,
    this.listStylePosition,
    this.padding,
    this.margin,
    this.textAlign,
    this.textDecoration,
    this.textDecorationColor,
    this.textDecorationStyle,
    this.textDecorationThickness,
    this.textShadow,
    this.verticalAlign,
    this.whiteSpace,
    this.width,
    this.wordSpacing,
    this.before,
    this.after,
    this.border,
    this.alignment,
    this.markerContent,
    this.maxLines,
    this.textOverflow,
    this.textTransform = TextTransform.none,
  }) {
    if (alignment == null &&
        (display == Display.BLOCK || display == Display.LIST_ITEM)) {
      alignment = Alignment.centerLeft;
    }
  }

  static Map<String, Style> fromThemeData(ThemeData theme) => {
    'h1': Style.fromTextStyle(theme.textTheme.displayLarge!),
    'h2': Style.fromTextStyle(theme.textTheme.displayMedium!),
    'h3': Style.fromTextStyle(theme.textTheme.displaySmall!),
    'h4': Style.fromTextStyle(theme.textTheme.headlineMedium!),
    'h5': Style.fromTextStyle(theme.textTheme.headlineSmall!),
    'h6': Style.fromTextStyle(theme.textTheme.titleLarge!),
    'body': Style.fromTextStyle(theme.textTheme.bodyMedium!),
  };

  static Map<String, Style> fromCss(String css, OnCssParseError? onCssParseError) {
    final declarations = parseExternalCss(css, onCssParseError);
    Map<String, Style> styleMap = {};
    declarations.forEach((key, value) {
      styleMap[key] = declarationsToStyle(value);
    });
    return styleMap;
  }

  TextStyle generateTextStyle() {
    return TextStyle(
      backgroundColor: backgroundColor,
      color: color,
      decoration: textDecoration,
      decorationColor: textDecorationColor,
      decorationStyle: textDecorationStyle,
      decorationThickness: textDecorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontFeatures: fontFeatureSettings,
      fontSize: fontSize?.size,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: textShadow,
      wordSpacing: wordSpacing,
      height: lineHeight?.size ?? 1.0,
      //TODO background
      //TODO textBaseline
    );
  }

  @override
  String toString() {
    return "Style";
  }

  Style merge(Style other) {
    return copyWith(
      backgroundColor: other.backgroundColor,
      color: other.color,
      direction: other.direction,
      display: other.display,
      fontFamily: other.fontFamily,
      fontFamilyFallback: other.fontFamilyFallback,
      fontFeatureSettings: other.fontFeatureSettings,
      fontSize: other.fontSize,
      fontStyle: other.fontStyle,
      fontWeight: other.fontWeight,
      height: other.height,
      lineHeight: other.lineHeight,
      letterSpacing: other.letterSpacing,
      listStyleType: other.listStyleType,
      listStylePosition: other.listStylePosition,
      padding: other.padding,
      //TODO merge EdgeInsets
      margin: other.margin,
      //TODO merge EdgeInsets
      textAlign: other.textAlign,
      textDecoration: other.textDecoration,
      textDecorationColor: other.textDecorationColor,
      textDecorationStyle: other.textDecorationStyle,
      textDecorationThickness: other.textDecorationThickness,
      textShadow: other.textShadow,
      verticalAlign: other.verticalAlign,
      whiteSpace: other.whiteSpace,
      width: other.width,
      wordSpacing: other.wordSpacing,

      before: other.before,
      after: other.after,
      border: other.border,
      //TODO merge border
      alignment: other.alignment,
      markerContent: other.markerContent,
      maxLines: other.maxLines,
      textOverflow: other.textOverflow,
      textTransform: other.textTransform,
    );
  }

  Style copyOnlyInherited(Style child) {
    FontSize? finalFontSize = child.fontSize != null ?
      fontSize != null && child.fontSize?.units == "em" ?
        FontSize(child.fontSize!.size! * fontSize!.size!) : child.fontSize
      : fontSize != null && fontSize!.size! < 0 ?
        FontSize.percent(100) : fontSize;
    LineHeight? finalLineHeight = child.lineHeight != null ?
      child.lineHeight?.units == "length" ?
        LineHeight(child.lineHeight!.size! / (finalFontSize == null ? 14 : finalFontSize.size!) * 1.2) : child.lineHeight
      : lineHeight;
    return child.copyWith(
      backgroundColor: child.backgroundColor != Colors.transparent ?
        child.backgroundColor : backgroundColor,
      color: child.color ?? color,
      direction: child.direction ?? direction,
      display: display == Display.NONE ? display : child.display,
      fontFamily: child.fontFamily ?? fontFamily,
      fontFamilyFallback: child.fontFamilyFallback ?? fontFamilyFallback,
      fontFeatureSettings: child.fontFeatureSettings ?? fontFeatureSettings,
      fontSize: finalFontSize,
      fontStyle: child.fontStyle ?? fontStyle,
      fontWeight: child.fontWeight ?? fontWeight,
      lineHeight: finalLineHeight,
      letterSpacing: child.letterSpacing ?? letterSpacing,
      listStyleType: child.listStyleType ?? listStyleType,
      listStylePosition: child.listStylePosition ?? listStylePosition,
      textAlign: child.textAlign ?? textAlign,
      textDecoration: TextDecoration.combine(
          [child.textDecoration ?? TextDecoration.none,
            textDecoration ?? TextDecoration.none]),
      textShadow: child.textShadow ?? textShadow,
      whiteSpace: child.whiteSpace ?? whiteSpace,
      wordSpacing: child.wordSpacing ?? wordSpacing,
      maxLines: child.maxLines ?? maxLines,
      textOverflow: child.textOverflow ?? textOverflow,
      textTransform: child.textTransform ?? textTransform,
    );
  }

  Style copyWith({
    Color? backgroundColor,
    Color? color,
    TextDirection? direction,
    Display? display,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    List<FontFeature>? fontFeatureSettings,
    FontSize? fontSize,
    FontStyle? fontStyle,
    FontWeight? fontWeight,
    double? height,
    LineHeight? lineHeight,
    double? letterSpacing,
    ListStyleType? listStyleType,
    ListStylePosition? listStylePosition,
    EdgeInsets? padding,
    EdgeInsets? margin,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
    Color? textDecorationColor,
    TextDecorationStyle? textDecorationStyle,
    double? textDecorationThickness,
    List<Shadow>? textShadow,
    VerticalAlign? verticalAlign,
    WhiteSpace? whiteSpace,
    double? width,
    double? wordSpacing,
    String? before,
    String? after,
    Border? border,
    Alignment? alignment,
    Widget? markerContent,
    int? maxLines,
    TextOverflow? textOverflow,
    TextTransform? textTransform,
    bool? beforeAfterNull,
  }) {
    return Style(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      color: color ?? this.color,
      direction: direction ?? this.direction,
      display: display ?? this.display,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      fontFeatureSettings: fontFeatureSettings ?? this.fontFeatureSettings,
      fontSize: fontSize ?? this.fontSize,
      fontStyle: fontStyle ?? this.fontStyle,
      fontWeight: fontWeight ?? this.fontWeight,
      height: height ?? this.height,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      listStyleType: listStyleType ?? this.listStyleType,
      listStylePosition: listStylePosition ?? this.listStylePosition,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      textAlign: textAlign ?? this.textAlign,
      textDecoration: textDecoration ?? this.textDecoration,
      textDecorationColor: textDecorationColor ?? this.textDecorationColor,
      textDecorationStyle: textDecorationStyle ?? this.textDecorationStyle,
      textDecorationThickness:
          textDecorationThickness ?? this.textDecorationThickness,
      textShadow: textShadow ?? this.textShadow,
      verticalAlign: verticalAlign ?? this.verticalAlign,
      whiteSpace: whiteSpace ?? this.whiteSpace,
      width: width ?? this.width,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      before: beforeAfterNull == true ? null : before ?? this.before,
      after: beforeAfterNull == true ? null : after ?? this.after,
      border: border ?? this.border,
      alignment: alignment ?? this.alignment,
      markerContent: markerContent ?? this.markerContent,
      maxLines: maxLines ?? this.maxLines,
      textOverflow: textOverflow ?? this.textOverflow,
      textTransform: textTransform ?? this.textTransform,
    );
  }

  Style.fromTextStyle(TextStyle textStyle) {
    backgroundColor = textStyle.backgroundColor;
    color = textStyle.color;
    textDecoration = textStyle.decoration;
    textDecorationColor = textStyle.decorationColor;
    textDecorationStyle = textStyle.decorationStyle;
    textDecorationThickness = textStyle.decorationThickness;
    fontFamily = textStyle.fontFamily;
    fontFamilyFallback = textStyle.fontFamilyFallback;
    fontFeatureSettings = textStyle.fontFeatures;
    fontSize = FontSize(textStyle.fontSize);
    fontStyle = textStyle.fontStyle;
    fontWeight = textStyle.fontWeight;
    letterSpacing = textStyle.letterSpacing;
    textShadow = textStyle.shadows;
    wordSpacing = textStyle.wordSpacing;
    lineHeight = LineHeight(textStyle.height ?? 1.2);
    textTransform = TextTransform.none;
  }
}

enum Display {
  BLOCK,
  INLINE,
  INLINE_BLOCK,
  LIST_ITEM,
  NONE,
}

class FontSize {
  final double? size;
  final String units;

  const FontSize(this.size, {this.units = ""});

  /// A percentage of the parent style's font size.
  factory FontSize.percent(double percent) {
    return FontSize(percent / -100.0, units: "%");
  }

  factory FontSize.em(double? em) {
    return FontSize(em, units: "em");
  }

  factory FontSize.rem(double rem) {
    return FontSize(rem * 16 - 2, units: "rem");
  }
  // These values are calculated based off of the default (`medium`)
  // being 14px.
  //
  // TODO(Sub6Resources): This seems to override Flutter's accessibility text scaling.
  //
  // Negative values are computed during parsing to be a percentage of
  // the parent style's font size.
  static const xxSmall = FontSize(7.875);
  static const xSmall = FontSize(8.75);
  static const small = FontSize(11.375);
  static const medium = FontSize(14.0);
  static const large = FontSize(15.75);
  static const xLarge = FontSize(21.0);
  static const xxLarge = FontSize(28.0);
  static const smaller = FontSize(-0.83);
  static const larger = FontSize(-1.2);
}

class LineHeight {
  final double? size;
  final String units;

  const LineHeight(this.size, {this.units = ""});

  factory LineHeight.percent(double percent) {
    return LineHeight(percent / 100.0 * 1.2, units: "%");
  }

  factory LineHeight.em(double em) {
    return LineHeight(em * 1.2, units: "em");
  }

  factory LineHeight.rem(double rem) {
    return LineHeight(rem * 1.2, units: "rem");
  }

  factory LineHeight.number(double num) {
    return LineHeight(num * 1.2, units: "number");
  }

  static const normal = LineHeight(1.2);
}

class ListStyleType {
  final String text;
  final String type;
  final Widget? widget;

  const ListStyleType(this.text, {this.type = "marker", this.widget});

  factory ListStyleType.fromImage(String url) => ListStyleType(url, type: "image");

  factory ListStyleType.fromWidget(Widget widget) => ListStyleType("", widget: widget, type: "widget");

  static const LOWER_ALPHA = ListStyleType("LOWER_ALPHA");
  static const UPPER_ALPHA = ListStyleType("UPPER_ALPHA");
  static const LOWER_LATIN = ListStyleType("LOWER_LATIN");
  static const UPPER_LATIN = ListStyleType("UPPER_LATIN");
  static const CIRCLE = ListStyleType("CIRCLE");
  static const DISC = ListStyleType("DISC");
  static const DECIMAL = ListStyleType("DECIMAL");
  static const LOWER_ROMAN = ListStyleType("LOWER_ROMAN");
  static const UPPER_ROMAN = ListStyleType("UPPER_ROMAN");
  static const SQUARE = ListStyleType("SQUARE");
  static const NONE = ListStyleType("NONE");
}

enum ListStylePosition {
  OUTSIDE,
  INSIDE,
}

enum TextTransform {
  uppercase,
  lowercase,
  capitalize,
  none,
}

enum VerticalAlign {
  BASELINE,
  SUB,
  SUPER,
}

enum WhiteSpace {
  NORMAL,
  PRE,
}
