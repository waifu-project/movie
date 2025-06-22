import 'package:flutter/widgets.dart';

const kScrollDuration = Duration(milliseconds: 420);
const kScrollSize = 240;

void scrollUp(ScrollController cx) {
  var curr = cx.offset;
  if (curr == 0) return;
  var exec = curr - kScrollSize;
  if (exec < 0) exec = 0;
  cx.animateTo(exec, duration: kScrollDuration, curve: Curves.ease);
}

void scrollDown(ScrollController cx) {
  var curr = cx.offset;
  var max = cx.position.maxScrollExtent;
  if (curr == max) return;
  var exec = curr + kScrollSize;
  if (exec > max) exec = max;
  cx.animateTo(exec, duration: kScrollDuration, curve: Curves.ease);
}
