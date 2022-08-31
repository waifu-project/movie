import 'package:flutter/material.dart';

import '../style.dart';

Map<String, String> namedColors = {
  "White": "#FFFFFF",
  "Silver": "#C0C0C0",
  "Gray": "#808080",
  "Black": "#000000",
  "Red": "#FF0000",
  "Maroon": "#800000",
  "Yellow": "#FFFF00",
  "Olive": "#808000",
  "Lime": "#00FF00",
  "Green": "#008000",
  "Aqua": "#00FFFF",
  "Teal": "#008080",
  "Blue": "#0000FF",
  "Navy": "#000080",
  "Fuchsia": "#FF00FF",
  "Purple": "#800080",
};

class Context<T> {
  T data;

  Context(this.data);
}

// This class is a workaround so that both an image
// and a link can detect taps at the same time.
class MultipleTapGestureDetector extends InheritedWidget {
  final void Function()? onTap;

  const MultipleTapGestureDetector({
    Key? key,
    required Widget child,
    required this.onTap,
  }) : super(key: key, child: child);

  static MultipleTapGestureDetector? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MultipleTapGestureDetector>();
  }

  @override
  bool updateShouldNotify(MultipleTapGestureDetector oldWidget) => false;
}

class CustomBorderSide {
  CustomBorderSide({
    this.color = const Color(0xFF000000),
    this.width = 1.0,
    this.style = BorderStyle.none,
  }) : assert(width >= 0.0);

  Color? color;
  double width;
  BorderStyle style;
}

extension TextTransformUtil on String? {
  String? transformed(TextTransform? transform) {
    if (this == null) return null;
    if (transform == TextTransform.uppercase) {
      return this!.toUpperCase();
    } else if (transform == TextTransform.lowercase) {
      return this!.toLowerCase();
    } else if (transform == TextTransform.capitalize) {
      final stringBuffer = StringBuffer();

      var capitalizeNext = true;
      for (final letter in this!.toLowerCase().codeUnits) {
        // UTF-16: A-Z => 65-90, a-z => 97-122.
        if (capitalizeNext && letter >= 97 && letter <= 122) {
          stringBuffer.writeCharCode(letter - 32);
          capitalizeNext = false;
        } else {
          // UTF-16: 32 == space, 46 == period
          if (letter == 32 || letter == 46) capitalizeNext = true;
          stringBuffer.writeCharCode(letter);
        }
      }

      return stringBuffer.toString();
    } else {
      return this;
    }
  }
}