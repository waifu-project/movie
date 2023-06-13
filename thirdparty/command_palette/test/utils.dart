import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openPalette(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
  await tester.pumpAndSettle();
}

Future<void> closePalette(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
}
